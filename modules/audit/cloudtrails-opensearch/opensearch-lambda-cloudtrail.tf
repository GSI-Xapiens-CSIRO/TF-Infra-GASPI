# opensearch-lambda-cloudtrail.tf

# Lambda Insights configuration
locals {
  lambda_insights_versions = {
    "us-east-1"      = "29"
    "us-east-2"      = "29"
    "us-west-1"      = "29"
    "us-west-2"      = "29"
    "ap-southeast-1" = "29"
    "ap-southeast-2" = "29"
    "ap-southeast-3" = "29"
    # ap-southeast-3 not yet supported for Lambda Insights
  }

  # Use conditional to handle unsupported regions
  lambda_insights_layer_arn = contains(keys(local.lambda_insights_versions), var.aws_region) ? "arn:aws:lambda:${var.aws_region}:${var.aws_account_id_destination}:layer:LambdaInsightsExtension:${local.lambda_insights_versions[var.aws_region]}" : null
}


# Create build directory
resource "null_resource" "create_build_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/build/lambda ${path.module}/build/layer"
  }
}

# Build Lambda layer
resource "null_resource" "build_layer" {
  depends_on = [null_resource.create_build_dir]

  provisioner "local-exec" {
    command = <<EOF
      cd ${path.module}
      python -m venv venv
      source venv/bin/activate
      pip install -r requirements.txt --target build/layer/python
      cd build/layer
      zip -r ../lambda_layer_cloudtrail.zip python/
      deactivate
      rm -rf ${path.module}/venv
    EOF
  }

  # Trigger rebuild if layer contents change
  triggers = {
    requirements_hash = filesha256("${path.module}/requirements.txt")
  }
}

# Lambda layer for dependencies
resource "aws_lambda_layer_version" "cloudtrail_dependencies" {
  filename            = "${path.module}/build/lambda_layer_cloudtrail.zip"
  layer_name          = "genomic-cloudtrail-dependencies-${var.aws_account_id_destination}"
  description         = "Dependencies for CloudTrail processing Lambda function"
  compatible_runtimes = ["python3.12"]

  # Ensure consistent hash calculation
  source_code_hash = fileexists("${path.module}/build/lambda_layer_cloudtrail.zip") ? filebase64sha256("${path.module}/build/lambda_layer_cloudtrail.zip") : null

  depends_on = [null_resource.build_layer]
}

# --------------------------------------------------------------------------
#  Lambda Function
# --------------------------------------------------------------------------
# Lambda Function Code
data "archive_file" "cloudtrail_processor" {
  type        = "zip"
  source_file = "${path.module}/src/opensearch_handler.py"
  output_path = "${path.module}/build/lambda/cloudtrail_processor.zip"
}

# Build Lambda function
resource "null_resource" "build_function" {
  depends_on = [null_resource.create_build_dir]

  provisioner "local-exec" {
    command = <<EOF
      cp ${path.module}/src/opensearch_handler.py ${path.module}/build/lambda/
      cd ${path.module}/build/lambda
      zip cloudtrail_processor.zip opensearch_handler.py
    EOF
  }

  # Trigger rebuild if layer contents change
  triggers = {
    source_hash = filesha256("${path.module}/src/opensearch_handler.py")
  }
}

# Lambda function
resource "aws_lambda_function" "cloudtrail_processor" {
  filename      = "${path.module}/build/lambda/cloudtrail_processor.zip"
  function_name = "genomic-cloudtrail-processor-${var.aws_account_id_destination}"
  description   = "Capture all CloudTrail logs to Kinesis and send to OpenSearch"
  role          = aws_iam_role.lambda_transform.arn
  handler       = "opensearch_handler.handler"
  runtime       = "python3.12"
  timeout       = 120
  memory_size   = 256

  # This ensures the function is updated when the code changes
  source_code_hash = fileexists(data.archive_file.cloudtrail_processor.output_path) ? data.archive_file.cloudtrail_processor.output_base64sha256 : null
  layers = [
    aws_lambda_layer_version.cloudtrail_dependencies.arn,
  ]

  # vpc_config {
  #   subnet_ids         = var.private_subnet_ids
  #   security_group_ids = [aws_security_group.lambda.id]
  # }

  environment {
    variables = {
      OPENSEARCH_DOMAIN_ENDPOINT = aws_opensearch_domain.cloudtrail.endpoint
      REGION                     = var.aws_region
      LOG_LEVEL                  = upper(var.environment[local.env])
      ERROR_SNS_TOPIC            = aws_sns_topic.cloudtrail_alerts.arn
      PYTHONWARNINGS             = "ignore:Unverified HTTPS request"
    }
  }

  tracing_config {
    mode = "Active" # Enables X-Ray tracing
  }

  tags = merge(
    local.common_tags,
    {
      Name      = "CloudTrail Log Processor"
      Function  = "Log Processing and Index Management"
      UpdatedAt = timestamp()
    }
  )

  depends_on = [
    null_resource.build_function,
    aws_opensearch_domain.cloudtrail,
    aws_cloudwatch_log_group.cloudtrail_processor,
    aws_iam_role_policy.lambda_transform,
    aws_iam_role_policy_attachment.lambda_logging
  ]
}

# --------------------------------------------------------------------------
#  Lambda Permissions to access OpenSearch
# --------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_firehose" {
  statement_id  = "AllowExecutionFromFirehoseStream" # Changed from AllowExecutionFromFirehose
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudtrail_processor.function_name
  principal     = "firehose.amazonaws.com"
  source_arn    = aws_kinesis_firehose_delivery_stream.opensearch.arn

  depends_on = [
    aws_lambda_function.cloudtrail_processor,
    aws_kinesis_firehose_delivery_stream.opensearch
  ]
}

# Update this permission with specific statement ID and source ARN
resource "aws_lambda_permission" "allow_firehose_invoke" {
  statement_id   = "AllowExecutionFromFirehoseAccount" # Changed from AllowExecutionFromFirehose
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.cloudtrail_processor.function_name
  principal      = "firehose.amazonaws.com"
  source_account = var.aws_account_id_destination
  source_arn     = aws_kinesis_firehose_delivery_stream.opensearch.arn # Added source_arn

  depends_on = [
    aws_lambda_function.cloudtrail_processor,
    aws_kinesis_firehose_delivery_stream.opensearch
  ]
}
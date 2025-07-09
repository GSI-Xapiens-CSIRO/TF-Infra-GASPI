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

# Enhanced Lambda layer build process
resource "null_resource" "build_layer" {
  depends_on = [null_resource.create_build_dir]

  provisioner "local-exec" {
    command = <<EOF
      cd ${path.module}
      rm -rf venv build/layer build/lambda_layer_cloudtrail.zip

      # Create virtual environment
      python3 -m venv venv
      source venv/bin/activate

      # Upgrade pip and install wheel for better compatibility
      pip install --upgrade pip setuptools wheel

      # Install dependencies with all subdependencies
      pip install -r requirements.txt --target build/layer/python --no-cache-dir --force-reinstall

      # FIXED: Explicitly install missing dependencies that might not be auto-resolved
      pip install idna>=3.4 charset-normalizer>=3.3.0 certifi>=2023.0.0 urllib3>=1.26.0 --target build/layer/python --no-cache-dir --force-reinstall

      # Clean up unnecessary files to reduce layer size
      find build/layer/python -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
      find build/layer/python -name "*.pyc" -delete 2>/dev/null || true
      find build/layer/python -name "*.pyo" -delete 2>/dev/null || true
      find build/layer/python -type d -name "*.dist-info" -exec rm -rf {} + 2>/dev/null || true
      find build/layer/python -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true

      # Create the layer zip
      cd build/layer
      zip -r ../lambda_layer_cloudtrail.zip python/ -x "*.pyc" "*/__pycache__/*" "*.pyo" "*/*.dist-info/*" "*/*.egg-info/*"

      # Cleanup
      cd ${path.module}
      deactivate 2>/dev/null || true
      rm -rf venv
    EOF
  }

  triggers = {
    requirements_hash = filesha256("${path.module}/requirements.txt")
    timestamp         = timestamp()
  }
}

# Archive file for layer to ensure consistent hashing
data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "${path.module}/build/layer"
  output_path = "${path.module}/build/lambda_layer_cloudtrail.zip"

  depends_on = [null_resource.build_layer]
}

# Lambda layer with enhanced error handling
resource "aws_lambda_layer_version" "cloudtrail_dependencies" {
  filename            = "${path.module}/build/lambda_layer_cloudtrail.zip"
  layer_name          = "genomic-cloudtrail-dependencies-${var.aws_account_id_destination}"
  description         = "Dependencies for CloudTrail processing Lambda function - Fixed IDNA issue"
  compatible_runtimes = ["python3.12"]

  # Use data archive file for consistent hashing
  source_code_hash = data.archive_file.lambda_layer.output_base64sha256

  depends_on = [null_resource.build_layer]

  lifecycle {
    replace_triggered_by = [
      null_resource.build_layer
    ]
  }
}

# --------------------------------------------------------------------------
#  Lambda Function
# --------------------------------------------------------------------------
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
      rm -f cloudtrail_processor.zip
      zip cloudtrail_processor.zip opensearch_handler.py
    EOF
  }

  triggers = {
    source_hash = filesha256("${path.module}/src/opensearch_handler.py")
  }
}

# Lambda function with better dependency management
resource "aws_lambda_function" "cloudtrail_processor" {
  filename      = data.archive_file.cloudtrail_processor.output_path
  function_name = "genomic-cloudtrail-processor-${var.aws_account_id_destination}"
  description   = "Capture all CloudTrail logs to Kinesis and send to OpenSearch with intelligent batching - Fixed Dependencies"
  role          = aws_iam_role.lambda_transform.arn
  handler       = "opensearch_handler.handler"
  runtime       = "python3.12"
  timeout       = 900  # 15 minutes
  memory_size   = 3008 # 3GB

  # This ensures the function is updated when the code changes
  source_code_hash = data.archive_file.cloudtrail_processor.output_base64sha256

  layers = [
    aws_lambda_layer_version.cloudtrail_dependencies.arn,
  ]

  # Add reserved concurrency to prevent overwhelming OpenSearch
  reserved_concurrent_executions = var.environment[local.env] == "prod" ? 10 : 5

  environment {
    variables = {
      OPENSEARCH_DOMAIN_ENDPOINT = aws_opensearch_domain.cloudtrail.endpoint
      REGION                     = var.aws_region
      ENVIRONMENT                = var.environment[local.env]
      LOG_LEVEL                  = upper(var.environment[local.env])
      ERROR_SNS_TOPIC            = aws_sns_topic.cloudtrail_alerts.arn
      PYTHONWARNINGS             = "ignore:Unverified HTTPS request"

      # Batching configuration variables
      OPENSEARCH_BATCH_SIZE          = var.opensearch_batch_size
      OPENSEARCH_MAX_REQUEST_SIZE_MB = var.opensearch_max_request_size_mb
      ENABLE_BATCH_SPLITTING         = "true"

      # Add Python path to ensure all modules are found
      PYTHONPATH = "/opt/python:/var/runtime:/var/task"
    }
  }

  tracing_config {
    mode = "Active" # Enables X-Ray tracing
  }

  # Add dead letter queue for failed batches
  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  tags = merge(
    local.common_tags,
    {
      Name      = "CloudTrail Log Processor with Batching"
      Function  = "Log Processing and Index Management"
      Version   = "1.4.35" # Updated version
      UpdatedAt = timestamp()
    }
  )

  depends_on = [
    null_resource.build_function,
    aws_opensearch_domain.cloudtrail,
    aws_cloudwatch_log_group.cloudtrail_processor,
    aws_iam_role_policy.lambda_transform,
    aws_iam_role_policy_attachment.lambda_logging,
    aws_lambda_layer_version.cloudtrail_dependencies
  ]
}

# --------------------------------------------------------------------------
#  Dead Letter Queue for Failed Batches
# --------------------------------------------------------------------------
resource "aws_sqs_queue" "lambda_dlq" {
  name                       = "genomic-cloudtrail-lambda-dlq-${var.aws_account_id_destination}"
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = 60

  tags = merge(
    local.common_tags,
    {
      Name = "Lambda DLQ for failed batches"
    }
  )
}

# --------------------------------------------------------------------------
#  CloudWatch Monitoring
# --------------------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "batch_errors" {
  name           = "opensearch-batch-errors"
  pattern        = "ERROR" # Simple pattern
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "BatchErrors"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}

# --------------------------------------------------------------------------
#  Lambda Permissions to access OpenSearch
# --------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_firehose" {
  statement_id  = "AllowExecutionFromFirehoseStream"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudtrail_processor.function_name
  principal     = "firehose.amazonaws.com"
  source_arn    = aws_kinesis_firehose_delivery_stream.opensearch.arn

  depends_on = [
    aws_lambda_function.cloudtrail_processor,
    aws_kinesis_firehose_delivery_stream.opensearch
  ]
}

resource "aws_lambda_permission" "allow_firehose_invoke" {
  statement_id   = "AllowExecutionFromFirehoseAccount"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.cloudtrail_processor.function_name
  principal      = "firehose.amazonaws.com"
  source_account = var.aws_account_id_destination
  source_arn     = aws_kinesis_firehose_delivery_stream.opensearch.arn

  depends_on = [
    aws_lambda_function.cloudtrail_processor,
    aws_kinesis_firehose_delivery_stream.opensearch
  ]
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Update Firehose configuration
resource "aws_kinesis_firehose_delivery_stream" "opensearch" {
  name        = "genomic-cloudtrail-kinesis-opensearch-${var.aws_account_id_destination}"
  destination = "opensearch"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.cloudtrail.arn
    role_arn           = aws_iam_role.kinesis_firehose_opensearch.arn
  }

  opensearch_configuration {
    domain_arn            = aws_opensearch_domain.cloudtrail.arn
    role_arn              = aws_iam_role.kinesis_firehose_opensearch.arn
    index_name            = "logs-cloudtrail-*"
    index_rotation_period = "OneWeek" # NoRotation, OneHour, OneDay, OneWeek, OneMonth

    # vpc_config {
    #   subnet_ids         = slice(var.private_subnet_ids, 0, 2)
    #   security_group_ids = [aws_security_group.firehose.id]
    #   role_arn           = aws_iam_role.firehose_vpc.arn
    # }

    buffering_interval = 60
    buffering_size     = 50
    retry_duration     = 300

    processing_configuration {
      enabled = true
      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.cloudtrail_processor.arn}:$LATEST"
        }
        parameters {
          parameter_name  = "RoleArn"
          parameter_value = aws_iam_role.kinesis_firehose_opensearch.arn
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "3"
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "60"
        }
      }
    }

    s3_backup_mode = "FailedDocumentsOnly"

    s3_configuration {
      role_arn            = aws_iam_role.kinesis_firehose_opensearch.arn
      bucket_arn          = aws_s3_bucket.cloudtrail.arn
      prefix              = "cloudtrail-opensearch/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
      error_output_prefix = "errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
      buffering_size      = 10
      buffering_interval  = 400
      compression_format  = "GZIP"
    }

  }

  # server_side_encryption {
  #   enabled  = true
  #   key_type = "AWS_OWNED_CMK"
  # }

  depends_on = [
    aws_opensearch_domain.cloudtrail,
    aws_iam_role_policy.firehose_vpc,
    aws_iam_role_policy.kinesis_firehose_opensearch,
    aws_security_group.firehose
  ]

  tags = local.common_tags

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      # opensearch_configuration.0.vpc_config,
      opensearch_configuration.0.processing_configuration,
      tags,
      name
    ]
  }
}

resource "aws_kinesis_stream" "cloudtrail" {
  name             = "genomic-cloudtrail-kinesis-stream-${var.aws_account_id_destination}"
  shard_count      = var.environment[local.env] == "production" ? 4 : 2 # Increased shards
  retention_period = 72                                                 # Increased retention

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  encryption_type = "KMS"
  kms_key_id      = aws_kms_key.cloudtrail.arn

  tags = merge(
    local.common_tags,
    {
      Name = "genomic-cloudtrail-stream-${var.aws_account_id_destination}"
    }
  )
}

resource "aws_kinesis_firehose_delivery_stream" "cloudtrail_logs" {
  name        = "genomic-cloudtrail-to-s3-${var.aws_account_id_destination}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_firehose_to_s3.arn
    bucket_arn = aws_s3_bucket.cloudtrail.arn
    prefix     = "CloudWatchLogs/AWSLogs/${var.aws_account_id_destination}/CloudTrail/"

    buffering_size     = 64
    buffering_interval = 60
    compression_format = "GZIP"

    error_output_prefix = "errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/${aws_kinesis_firehose_delivery_stream.opensearch.name}"
      log_stream_name = "S3Delivery"
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "genomic-cloudtrail-to-s3-${var.aws_account_id_destination}"
      Description = "Kinesis Firehose for CloudTrail logs delivery"
    }
  )
}

resource "aws_vpc_endpoint" "firehose" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.kinesis-firehose"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = slice(var.private_subnet_ids, 0, 2)
  security_group_ids  = [aws_security_group.firehose.id]
  private_dns_enabled = true

  tags = local.common_tags
}

# IAM Role for Firehose VPC Access
resource "aws_iam_role" "firehose_vpc" {
  name = "genomic-cloudtrail-firehose-vpc-role-${var.aws_account_id_destination}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

# IAM Policy for Firehose VPC Access
resource "aws_iam_role_policy" "firehose_vpc" {
  name = "genomic-cloudtrail-firehose-vpc-policy"
  role = aws_iam_role.firehose_vpc.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcEndpoints",
          "ec2:DeleteNetworkInterface",
          "ec2:CreateNetworkInterfacePermission"
        ]
        Resource = "*"
      }
    ]
  })
}

# Additional VPC Endpoint Policy for Firehose
resource "aws_iam_role_policy" "firehose_vpc_endpoint" {
  name = "genomic-cloudtrail-firehose-vpc-endpoint-policy"
  role = aws_iam_role.firehose_vpc.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterfacePermission"
        ]
        Resource = [
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id_destination}:network-interface/*"
        ]
        Condition = {
          StringEquals = {
            "ec2:AuthorizedService" : "firehose.amazonaws.com"
          }
          ArnEquals = {
            "ec2:Subnet" : [for subnet in slice(var.private_subnet_ids, 0, 2) :
              "arn:aws:ec2:${var.aws_region}:${var.aws_account_id_destination}:subnet/${subnet}"
            ]
          }
        }
      }
    ]
  })
}
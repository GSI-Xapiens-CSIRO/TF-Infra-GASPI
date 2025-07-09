locals {
  # CloudWatch Logs filter pattern for CloudTrail events
  # filter_pattern = <<PATTERN
  # [version, useridentity.type, useridentity.principalid, useridentity.arn, useridentity.accountid, useridentity.accesskeyid, useridentity.username, useridentity.sessioncontext.attributes.mfaauthenticated, useridentity.sessioncontext.attributes.creationdate, useridentity.sessioncontext.sessionissuer.type, useridentity.sessioncontext.sessionissuer.principalid, useridentity.sessioncontext.sessionissuer.arn, useridentity.sessioncontext.sessionissuer.accountid, useridentity.sessioncontext.sessionissuer.username, eventtime, eventsource, eventname, awsregion, sourceipaddress, useragent, errorcode, errormessage, requestparameters, responseelements, requestid, eventid, resources.*.resourcetype, resources.*.resourcename, resources.*.resourcearn, eventtype, apiversion, readonly, recipientaccountid]
  # --- OR ---
  # [eventVersion, userIdentity, eventTime, eventSource, eventName, awsRegion, sourceIPAddress, userAgent, errorCode, errorMessage, requestParameters, responseElements, requestID, eventID, readOnly, eventType, apiVersion, managementEvent, eventCategory, tlsDetails, recipientAccountId, sharedEventID, resources, sessionCredentialFromConsole]
  # PATTERN
  filter_pattern = "" # no_filter
}

# IAM Role for CloudWatch Logs access
resource "aws_iam_role" "cloudwatch_logs" {
  name        = "genomic-cloudtrail-cloudwatch-logs-role"
  description = "IAM role for CloudWatch Logs access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "logs.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = local.common_tags
}

# Enhanced IAM Policy for CloudWatch Logs
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name = "genomic-cloudtrail-cloudwatch-logs-policy"
  role = aws_iam_role.cloudwatch_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetLogGroupFields",
          "logs:GetQueryResults"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.cloudtrail.arn}:*",
          "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [aws_kms_key.cloudtrail.arn]
      }
    ]
  })
}

# CloudTrail to CloudWatch Logs Policy
resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "genomic-cloudtrail-to-cloudwatch-policy"
  role = aws_iam_role.cloudtrail_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

# CloudWatch Log Group for Lambda function
resource "aws_iam_role_policy" "lambda_cloudwatch" {
  name = "genomic-cloudtrail-lambda-cloudwatch-policy"
  role = aws_iam_role.lambda_transform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:DescribeStream",
          "kinesis:ListShards"
        ]
        Resource = aws_kinesis_stream.cloudtrail.arn
      },
      {
        Effect = "Allow"
        Action = [
          "es:*",
          "opensearch:*"
        ]
        Resource = [
          aws_opensearch_domain.cloudtrail.arn,
          "${aws_opensearch_domain.cloudtrail.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.cloudtrail.arn,
          "${aws_s3_bucket.cloudtrail.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/lambda/*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/cloudtrail/*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/kinesisfirehose/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id_destination}:function:genomic-cloudtrail-processor-${var.aws_account_id_destination}"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [aws_kms_key.cloudtrail.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/lambda/*:*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/lambda/genomic-cloudtrail-processor-${var.aws_account_id_destination}:*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/lambda/genomic-cloudtrail-processor-${var.aws_account_id_destination}:log-stream:*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/cloudtrail/*:*"
        ]
      }
    ]
  })
}

# Add VPC access permissions if needed
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_transform.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Attach AWS Lambda basic execution role
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_transform.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "cloudtrail_processor" {
  name              = "/aws/lambda/genomic-cloudtrail-processor-${var.aws_account_id_destination}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.cloudtrail.arn

  tags = merge(
    local.common_tags,
    {
      DataRetention = var.log_retention_days
      LogType       = "CloudTrail"
    }
  )

  depends_on = [aws_kms_key.cloudtrail]
}

resource "aws_cloudwatch_log_resource_policy" "cloudtrail" {
  policy_name = "genomic-cloudtrail-logs-${var.aws_account_id_destination}"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutLogEventsBatch"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail_processor.arn}:*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutLogEventsBatch"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
        ]
      }
    ]
  })
}

# Update CloudWatch to Kinesis IAM role permissions
resource "aws_iam_role" "cloudwatch_to_kinesis" {
  name = "cloudwatch-to-kinesis-role-${var.aws_account_id_destination}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Policy for CloudWatch to Kinesis
resource "aws_iam_role_policy" "cloudwatch_to_kinesis" {
  name = "cloudwatch-to-kinesis-policy"
  role = aws_iam_role.cloudwatch_to_kinesis.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecordBatch",
          "kinesis:DescribeStream",
          "kinesis:ListShards"
        ]
        Resource = [aws_kinesis_stream.cloudtrail.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = [aws_kms_key.cloudtrail.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutSubscriptionFilter",
          "logs:DeleteSubscriptionFilter"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/lambda/sbeacon-*:*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/lambda/svep-*:*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/cloudtrail/*:*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/kinesisfirehose/*:*"
        ]
      }
    ]
  })
}

# Role for Firehose to S3
resource "aws_iam_role" "firehose_to_s3" {
  name = "firehose-to-s3-role-${var.aws_account_id_destination}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Policy for Firehose to S3
resource "aws_iam_role_policy" "firehose_to_s3" {
  name = "firehose-to-s3-policy"
  role = aws_iam_role.firehose_to_s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.cloudtrail.arn,
          "${aws_s3_bucket.cloudtrail.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [aws_kms_key.cloudtrail.arn]
      }
    ]
  })
}

# Role for Firehose to OpenSearch
resource "aws_iam_role" "firehose_opensearch" {
  name = "firehose-opensearch-role-${var.aws_account_id_destination}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Policy for Firehose to OpenSearch
resource "aws_iam_role_policy" "firehose_opensearch" {
  name = "firehose-opensearch-policy"
  role = aws_iam_role.firehose_opensearch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:DescribeElasticsearchDomain",
          "es:DescribeElasticsearchDomains",
          "es:DescribeElasticsearchDomainConfig",
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpGet",
          "opensearch:DescribeDomain",
          "opensearch:DescribeDomains",
          "opensearch:DescribeDomainConfig",
          "opensearch:ESHttpPost",
          "opensearch:ESHttpPut",
          "opensearch:ESHttpGet"
        ]
        Resource = [
          aws_opensearch_domain.cloudtrail.arn,
          "${aws_opensearch_domain.cloudtrail.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Resource = [aws_lambda_function.cloudtrail_processor.arn]
      }
    ]
  })
}
# IAM Role for Lambda function
resource "aws_iam_role" "lambda_transform" {
  name        = "genomic-cloudtrail-lambda-transform-${var.aws_account_id_destination}"
  description = "IAM role for Lambda function to transform CloudTrail logs with batching support"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Enhanced Lambda permissions for OpenSearch with batching
resource "aws_iam_role_policy" "lambda_transform" {
  name = "genomic-cloudtrail-lambda-transform-policy"
  role = aws_iam_role.lambda_transform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id_destination}:function:genomic-cloudtrail-processor-${var.aws_account_id_destination}*"
      },
      {
        Effect = "Allow"
        Action = [
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:DescribeStream",
          "kinesis:ListShards",
          "kinesis:DescribeStreamSummary",
          "kinesis:ListStreamConsumers"
        ]
        Resource = "${aws_kinesis_stream.cloudtrail.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/lambda/*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/cloudtrail/*"
        ]
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
          "sts:GetCallerIdentity",
          "sts:GetSessionToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Resource = "*"
      },
      {
        # NEW: SQS permissions for Dead Letter Queue
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = "arn:aws:sqs:${var.aws_region}:${var.aws_account_id_destination}:genomic-cloudtrail-lambda-dlq-${var.aws_account_id_destination}"
      },
      {
        # NEW: CloudWatch custom metrics permissions
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = [
              "GenomicServices/OpenSearch",
              "AWS/Lambda"
            ]
          }
        }
      },
      {
        # NEW: SNS permissions for error notifications
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.cloudtrail_alerts.arn
      }
    ]
  })
}

# --------------------------------------------------------------------------
#  Lambda VPC Execution Role
# --------------------------------------------------------------------------
# VPC Access Policy
# resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
#   role       = aws_iam_role.lambda_transform.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }

# --------------------------------------------------------------------------
#  Lambda Basic Execution Role
# --------------------------------------------------------------------------
# CloudWatch Logs Policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_transform.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --------------------------------------------------------------------------
#  Lambda Insight Role
# --------------------------------------------------------------------------
# IAM permissions for Lambda Insights
resource "aws_iam_role_policy_attachment" "lambda_insights" {
  role       = aws_iam_role.lambda_transform.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

# --------------------------------------------------------------------------
#  Lambda X-Ray Execution Role
# --------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_xray_execution" {
  role       = aws_iam_role.lambda_transform.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# --------------------------------------------------------------------------
#  KMS Key Policy for Firehose Delivery Stream
# --------------------------------------------------------------------------
resource "aws_iam_role_policy" "firehose_kms" {
  name = "firehose-kms-policy"
  role = aws_iam_role.kinesis_firehose_opensearch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = [aws_kms_key.cloudtrail.arn]
      }
    ]
  })
}

# --------------------------------------------------------------------------
# CloudWatch Monitoring
# --------------------------------------------------------------------------
resource "aws_iam_role" "cloudwatch_monitoring" {
  name = "genomic-cloudtrail-monitoring-${var.aws_account_id_destination}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "events.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "cloudwatch_monitoring" {
  name = "genomic-cloudtrail-monitoring-policy"
  role = aws_iam_role.cloudwatch_monitoring.id

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
          "logs:FilterLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/lambda/*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/cloudtrail/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.cloudtrail_alerts.arn
      }
    ]
  })
}
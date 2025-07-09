# iam.tf
# ==========================================================================
#  IAM Configuration for CloudTrail Module
# --------------------------------------------------------------------------
#  Description:
#    IAM Roles and Policies for CloudTrail and CloudWatch integration
# ==========================================================================

# --------------------------------------------------------------------------
#  S3 Bucket Policy
# --------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailMultiRegionWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${var.aws_account_id_destination}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
          StringLike = {
            "aws:SourceArn" = "arn:aws:cloudtrail:*:${var.aws_account_id_destination}:trail/genomic-services-trail-${var.aws_account_id_destination}"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${var.aws_account_id_destination}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${var.aws_account_id_destination}:trail/genomic-services-trail-${var.aws_account_id_destination}"
          }
        }
      },
      {
        Sid       = "AllowSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.cloudtrail.arn,
          "${aws_s3_bucket.cloudtrail.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# --------------------------------------------------------------------------
#  CloudTrail Role
# --------------------------------------------------------------------------
resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "genomic-cloudtrail-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_policy" {
  name = "genomic-cloudtrail-cloudwatch-policy"
  role = aws_iam_role.cloudtrail_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      },
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.cloudtrail.arn}",
          "${aws_s3_bucket.cloudtrail.arn}/*"
        ]
      },
      {
        Sid    = "AllowKMSEncryption"
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.cloudtrail.arn
      },
      {
        Sid    = "AllowLambdaInspection"
        Effect = "Allow"
        Action = [
          "lambda:ListFunctions",
          "lambda:GetFunction",
          "lambda:ListTags"
        ]
        Resource = [
          "arn:aws:lambda:${var.aws_region}:${var.aws_account_id_destination}:function:sbeacon-*",
          "arn:aws:lambda:${var.aws_region}:${var.aws_account_id_destination}:function:svep-*"
        ]
      }
      ## Bucket Policy ##
      # {
      #   Sid    = "AWSCloudTrailAclCheck"
      #   Effect = "Allow"
      #   Principal = {
      #     Service = "cloudtrail.amazonaws.com"
      #   }
      #   Action   = "s3:GetBucketAcl"
      #   Resource = aws_s3_bucket.cloudtrail.arn
      # },
      # {
      #   Sid    = "AWSCloudTrailMultiRegionWrite"
      #   Effect = "Allow"
      #   Principal = {
      #     Service = "cloudtrail.amazonaws.com"
      #   }
      #   Action   = "s3:PutObject"
      #   Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${var.aws_account_id_destination}/*"
      #   Condition = {
      #     StringEquals = {
      #       "s3:x-amz-acl" = "bucket-owner-full-control"
      #     }
      #     StringLike = {
      #       "aws:SourceArn" = "arn:aws:cloudtrail:*:${var.aws_account_id_destination}:trail/genomic-services-trail-${var.aws_account_id_destination}"
      #     }
      #   }
      # },
      # {
      #   Sid    = "AWSCloudTrailWrite"
      #   Effect = "Allow"
      #   Principal = {
      #     Service = "cloudtrail.amazonaws.com"
      #   }
      #   Action   = "s3:PutObject"
      #   Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${var.aws_account_id_destination}/*"
      #   Condition = {
      #     StringEquals = {
      #       "s3:x-amz-acl"  = "bucket-owner-full-control"
      #       "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${var.aws_account_id_destination}:trail/genomic-services-trail-${var.aws_account_id_destination}"
      #     }
      #   }
      # },
      # {
      #   Sid       = "AllowSSLRequestsOnly"
      #   Effect    = "Deny"
      #   Principal = "*"
      #   Action    = "s3:*"
      #   Resource = [
      #     aws_s3_bucket.cloudtrail.arn,
      #     "${aws_s3_bucket.cloudtrail.arn}/*"
      #   ]
      #   Condition = {
      #     Bool = {
      #       "aws:SecureTransport" = "false"
      #     }
      #   }
      # }
    ]
  })
}

resource "aws_iam_role" "cloudtrail" {
  name = "genomic-cloudtrail-role-${var.aws_account_id_destination}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# --------------------------------------------------------------------------
#  CloudTrail Policy
# --------------------------------------------------------------------------
resource "aws_iam_role_policy" "cloudtrail" {
  name = "genomic-cloudtrail-policy"
  role = aws_iam_role.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      },
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.cloudtrail.arn}",
          "${aws_s3_bucket.cloudtrail.arn}/*"
        ]
      },
      {
        Sid    = "AllowKMSEncryption"
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.cloudtrail.arn
      },
      {
        Sid    = "AllowLambdaInspection"
        Effect = "Allow"
        Action = [
          "lambda:ListFunctions",
          "lambda:GetFunction",
          "lambda:ListTags"
        ]
        Resource = [
          "arn:aws:lambda:${var.aws_region}:${var.aws_account_id_destination}:function:sbeacon-*",
          "arn:aws:lambda:${var.aws_region}:${var.aws_account_id_destination}:function:svep-*"
        ]
      }
    ]
  })
}

# --------------------------------------------------------------------------
#  CloudWatch Role
# --------------------------------------------------------------------------
resource "aws_iam_role" "cloudwatch" {
  name = "genomic-cloudwatch-role-${var.aws_account_id_destination}"

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

# --------------------------------------------------------------------------
#  CloudWatch Policy
# --------------------------------------------------------------------------
resource "aws_iam_role_policy" "cloudwatch" {
  name = "genomic-cloudwatch-policy"
  role = aws_iam_role.cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutMetricFilter",
          "logs:PutRetentionPolicy",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetLogGroupFields",
          "logs:GetQueryResults"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id_destination}:log-group:/aws/cloudtrail/*:*"
      },
      {
        Sid    = "AllowMetricOperations"
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowSNSPublish"
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.cloudtrail_alerts.arn
      }
    ]
  })
}

# Firehose to S3 Role
resource "aws_iam_role" "kinesis_firehose_to_s3" {
  name = "genomic-cloudtrail-kinesis-firehose-to-s3-role"

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

resource "aws_iam_role_policy" "kinesis_firehose_to_s3" {
  name = "genomic-cloudtrail-firehose-to-s3-policy"
  role = aws_iam_role.kinesis_firehose_to_s3.id

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
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = ["*"]
      },
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

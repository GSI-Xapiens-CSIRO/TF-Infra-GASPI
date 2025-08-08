# ==========================================================================
#  Module Core: cfn-s3-iam.tf
# --------------------------------------------------------------------------
#  Description
#    CloudFormation-Compatible S3 and IAM Configuration
# --------------------------------------------------------------------------
#    - KMS Keys for S3 and EBS encryption
#    - S3 Buckets with VPC endpoint policies
#    - SageMaker Execution Role
#    - IAM Policies
# ==========================================================================

# --------------------------------------------------------------------------
#  KMS Key for S3 Buckets
# --------------------------------------------------------------------------
resource "aws_kms_key" "s3_kms_key" {
  count                   = var.enable_sagemaker_studio ? 1 : 0
  provider                = aws.destination
  description             = "KMS key for S3 buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-policy-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow access for Key Users"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:sourceVpce" = aws_vpc_endpoint.s3[0].id
          }
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "kms-cmk-${local.project_name}"
  })
}

resource "aws_kms_alias" "s3_kms_alias" {
  count         = var.enable_sagemaker_studio ? 1 : 0
  provider      = aws.destination
  name          = "alias/kms-cmk-${local.project_name}"
  target_key_id = aws_kms_key.s3_kms_key[0].key_id
}

# --------------------------------------------------------------------------
#  KMS Key for SageMaker EBS
# --------------------------------------------------------------------------
resource "aws_kms_key" "sagemaker_kms_key" {
  count                   = var.enable_sagemaker_studio ? 1 : 0
  provider                = aws.destination
  description             = "Generated KMS Key for sagemaker Notebook's EBS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "allow-root-access-to-key"
    Statement = [
      {
        Sid    = "allow-root-to-delegate-actions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:DeleteAlias",
          "kms:DescribeKey",
          "kms:EnableKey",
          "kms:GetKeyPolicy",
          "kms:UpdateAlias",
          "kms:CreateAlias",
          "kms:GetKeyPolicy",
          "kms:CreateGrant",
          "kms:DisableKey",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:CancelKeyDeletion",
          "kms:ScheduleKeyDeletion",
          "kms:PutKeyPolicy",
          "kms:RevokeGrant",
          "kms:TagResource",
          "kms:UnTagResource",
          "kms:EnableKeyRotation",
          "kms:ListResourceTags"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "sagemaker-ebs-kms-${local.project_name}"
  })
}

resource "aws_kms_alias" "sagemaker_kms_alias" {
  count         = var.enable_sagemaker_studio ? 1 : 0
  provider      = aws.destination
  name          = "alias/sagemaker-anfw-kms"
  target_key_id = aws_kms_key.sagemaker_kms_key[0].key_id
}

# --------------------------------------------------------------------------
#  Data S3 Bucket
# --------------------------------------------------------------------------
resource "aws_s3_bucket" "data_bucket" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  bucket   = local.data_bucket_name

  tags = merge(local.tags, {
    Name = local.data_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "data_bucket_pab" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  bucket   = aws_s3_bucket.data_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_bucket_encryption" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  bucket   = aws_s3_bucket.data_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "data_bucket_policy" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  bucket   = aws_s3_bucket.data_bucket[0].id

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Deny"
        Resource = [
          "arn:aws:s3:::${local.data_bucket_name}/*",
          "arn:aws:s3:::${local.data_bucket_name}"
        ]
        Principal = "*"
        Condition = {
          StringNotEquals = {
            "aws:sourceVpce" = aws_vpc_endpoint.s3[0].id
          }
        }
      }
    ]
  })
}

# --------------------------------------------------------------------------
#  Model S3 Bucket
# --------------------------------------------------------------------------
resource "aws_s3_bucket" "model_bucket" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  bucket   = local.model_bucket_name

  tags = merge(local.tags, {
    Name = local.model_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "model_bucket_pab" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  bucket   = aws_s3_bucket.model_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "model_bucket_encryption" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  bucket   = aws_s3_bucket.model_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "model_bucket_policy" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  bucket   = aws_s3_bucket.model_bucket[0].id

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Deny"
        Resource = [
          "arn:aws:s3:::${local.model_bucket_name}/*",
          "arn:aws:s3:::${local.model_bucket_name}"
        ]
        Principal = "*"
        Condition = {
          StringNotEquals = {
            "aws:sourceVpce" = aws_vpc_endpoint.s3[0].id
          }
        }
      }
    ]
  })
}

# --------------------------------------------------------------------------
#  SageMaker Execution Role
# --------------------------------------------------------------------------
resource "aws_iam_role" "sagemaker_execution_role" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  name     = "${local.project_name}-${var.aws_region}-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${local.project_name}-sagemaker-execution-role"
  })
}

# --------------------------------------------------------------------------
#  SageMaker Execution Policy
# --------------------------------------------------------------------------
resource "aws_iam_policy" "sagemaker_execution_policy" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  name     = "${local.project_name}-sagemaker-execution-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker/*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-stream:*"
        ]
      },
      {
        Sid    = "CloudWatchMetricsAccess"
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:ListAliases"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.data_bucket_name}/*",
          "arn:aws:s3:::${local.data_bucket_name}",
          "arn:aws:s3:::${local.model_bucket_name}/*",
          "arn:aws:s3:::${local.model_bucket_name}"
        ]
      },
      {
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:SetRepositoryPolicy",
          "ecr:CompleteLayerUpload",
          "ecr:BatchDeleteImage",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "arn:aws:ecr:*:*:repository/*sagemaker*"
      },
      {
        Sid    = "PassRole"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "sagemaker.amazonaws.com"
          }
        }
      },
      {
        Sid    = "SageMakerAccess"
        Action = [
          "sagemaker:CreateTrainingJob",
          "sagemaker:CreateProcessingJob",
          "sagemaker:CreateModel",
          "sagemaker:CreateHyperParameterTuningJob"
        ]
        Resource = "*"
        Effect   = "Deny"
        Condition = {
          "Null" = {
            "sagemaker:VpcSubnets" = "true"
          }
        }
      },
      {
        Sid    = "SageMakerList"
        Action = [
          "sagemaker:Describe*",
          "sagemaker:List*"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Sid    = "SageMakerStudioSignedURLCreation"
        Action = "sagemaker:CreateApp"
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Sid    = "EC2Access"
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcEndpoints"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${local.project_name}-sagemaker-execution-policy"
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_execution_policy_attachment" {
  count      = var.enable_sagemaker_studio ? 1 : 0
  provider   = aws.destination
  role       = aws_iam_role.sagemaker_execution_role[0].name
  policy_arn = aws_iam_policy.sagemaker_execution_policy[0].arn
}
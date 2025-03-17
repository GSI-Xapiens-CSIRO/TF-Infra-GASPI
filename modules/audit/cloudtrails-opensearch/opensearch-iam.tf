# IAM Roles and Policies
resource "aws_iam_role" "kinesis_firehose_opensearch" {
  name        = "genomic-cloudtrail-kinesis-firehose-opensearch-role"
  description = "IAM role for Firehose to OpenSearch"

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

resource "aws_iam_role_policy" "kinesis_firehose_opensearch" {
  name = "genomic-cloudtrail-kinesis-firehose-opensearch-policy"
  role = aws_iam_role.kinesis_firehose_opensearch.id

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
        Resource = "*"
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
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Resource = [
          "${aws_lambda_function.cloudtrail_processor.arn}:*",
          aws_lambda_function.cloudtrail_processor.arn
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
          "ec2:CreateNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

## TODO: Don't change this IAM role. It is used by the Lambda function to transform CloudTrail logs and OpenSearch logging user"
resource "aws_opensearch_domain_policy" "main" {
  domain_name = aws_opensearch_domain.cloudtrail.domain_name

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.lambda_transform.arn,
            aws_iam_role.kinesis_firehose_opensearch.arn,
            aws_iam_role.opensearch_master_role.arn,
            aws_iam_role.opensearch_snapshot_role.arn,
            "arn:aws:iam::${var.aws_account_id_destination}:root"
          ]
        }
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
        Principal = {
          AWS = "*"
        }
        Action = [
          "es:*",
          "opensearch:*"
        ]
        Resource = [
          aws_opensearch_domain.cloudtrail.arn,
          "${aws_opensearch_domain.cloudtrail.arn}/*"
        ]
        ## Using IP-based access control ##
        ## Do not use this in production ##
        ## Do not use this if using VPC Endpoint (private subnet) ##
        # Condition = {
        #   IpAddress = {
        #     "aws:SourceIp" = var.allowed_ips # List of allowed IP addresses
        #   }
        # }
      },
    ]
  })
}


# Apply this using the OpenSearch API or through the AWS Console
# PUT _plugins/_security/api/rolesmapping/all_access
# {
#   "backend_roles": [
#     "arn:aws:iam::${account_id}:role/genomic-cloudtrail-lambda-transform-${account_id}",
#     "arn:aws:iam::${account_id}:role/genomic-cloudtrail-kinesis-firehose-opensearch-${account_id}"
#   ],
#   "hosts": [],
#   "users": ["${opensearch_master_user}"]
# }

# PUT _plugins/_security/api/rolesmapping/all_access
# {
#   "backend_roles": [
#     "arn:aws:iam::209479276142:role/genomic-cloudtrail-lambda-transform-209479276142",
#     "arn:aws:iam::209479276142:role/genomic-cloudtrail-kinesis-firehose-opensearch-209479276142"
#   ],
#   "hosts": [],
#   "users": ["gxc-admin"]
# }

#### IAM Roles for SAML Federation and Cognito Authentication ###
resource "aws_iam_role" "opensearch_saml" {
  name        = "opensearch-saml-federation-${var.aws_account_id_destination}"
  description = "IAM role for SAML federation to OpenSearch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id_destination}:saml-provider/AWSSSO"
        }
        Action = "sts:AssumeRoleWithSAML"
        Condition = {
          StringEquals = {
            "SAML:aud" = "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

######### Snapshot Bucket Policy #########
# Policy for allowing PassRole to OpenSearch
resource "aws_iam_policy" "opensearch_snapshot_pass_role" {
  name        = "opensearch-snapshot-pass-role-policy"
  description = "Policy to allow passing role to OpenSearch for snapshots"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:GetRole"
        ]
        Resource = [
          aws_iam_role.opensearch_snapshot_role.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "es:CreateRepository",
          "es:DescribeRepository",
          "es:ListRepositories",
          "es:DeleteRepository",
          "es:VerifyRepository",
          "opensearch:CreateRepository",
          "opensearch:DescribeRepository",
          "opensearch:ListRepositories",
          "opensearch:DeleteRepository",
          "opensearch:VerifyRepository"
        ]
        Resource = [
          "${aws_opensearch_domain.cloudtrail.arn}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the existing OpenSearch master user role
resource "aws_iam_role_policy_attachment" "opensearch_master_snapshot" {
  policy_arn = aws_iam_policy.opensearch_snapshot_pass_role.arn
  role       = aws_iam_role.opensearch_master_role.name
}

# Update OpenSearch snapshot role trust policy
resource "aws_iam_role" "opensearch_snapshot_role" {
  name = "opensearch-snapshot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "opensearch.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.opensearch_master_role.arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# OpenSearch master user role
resource "aws_iam_role" "opensearch_master_role" {
  name = "opensearch-master-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id_destination}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "opensearch_snapshot_policy" {
  name = "opensearch-snapshot-policy"
  role = aws_iam_role.opensearch_snapshot_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions"
        ]
        Resource = [
          "arn:aws:s3:::genomic-snapshot-${var.aws_account_id_destination}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          "arn:aws:s3:::genomic-snapshot-${var.aws_account_id_destination}/*"
        ]
      }
    ]
  })
}
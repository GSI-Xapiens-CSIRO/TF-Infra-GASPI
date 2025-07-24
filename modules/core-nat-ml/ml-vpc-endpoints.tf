# ==========================================================================
#  Module Core: ml-vpc-endpoints.tf
# --------------------------------------------------------------------------
#  Description
#    VPC Endpoints for Secure ML Workloads
# --------------------------------------------------------------------------
#    - S3 Gateway Endpoint
#    - SageMaker Interface Endpoints
#    - Essential AWS Service Endpoints
#    - EFS Interface Endpoint
# ==========================================================================

# --------------------------------------------------------------------------
#  S3 Gateway Endpoint (No additional charge)
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "s3_gateway" {
  count        = var.enable_sagemaker_studio ? 1 : 0
  provider     = aws.destination
  vpc_id       = aws_vpc.infra_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  vpc_endpoint_type = "Gateway"

  route_table_ids = compact([
    var.enable_sagemaker_studio && var.enable_network_firewall ? aws_route_table.sagemaker_rt_a[0].id : "",
    var.enable_sagemaker_studio && var.enable_network_firewall ? aws_route_table.sagemaker_rt_b[0].id : "",
    var.enable_sagemaker_studio && var.enable_network_firewall ? aws_route_table.sagemaker_rt_c[0].id : "",
    aws_route_table.nat_ec2_rt_private_a.id,
    aws_route_table.nat_ec2_rt_private_b.id,
    aws_route_table.nat_ec2_rt_private_c.id
  ])

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          "arn:aws:s3:::sagemaker-*",
          "arn:aws:s3:::sagemaker-*/*",
          "arn:aws:s3:::${var.coreinfra}-*",
          "arn:aws:s3:::${var.coreinfra}-*/*"
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalServiceName" = [
              "sagemaker.amazonaws.com"
            ]
          }
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-s3-gateway-endpoint"
    Purpose = "S3AccessForML"
  })
}

# --------------------------------------------------------------------------
#  SageMaker API Interface Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sagemaker_api" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.sagemaker.api"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids = [aws_security_group.vpc_endpoints[0].id]

  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "sagemaker:CreatePresignedDomainUrl",
          "sagemaker:DescribeDomain",
          "sagemaker:DescribeUserProfile",
          "sagemaker:DescribeApp",
          "sagemaker:ListApps",
          "sagemaker:ListDomains",
          "sagemaker:ListUserProfiles"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-sagemaker-api-endpoint"
    Purpose = "SageMakerAPIAccess"
  })
}

# --------------------------------------------------------------------------
#  SageMaker Runtime Interface Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sagemaker_runtime" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.sagemaker.runtime"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-sagemaker-runtime-endpoint"
    Purpose = "SageMakerRuntimeAccess"
  })
}

# --------------------------------------------------------------------------
#  SageMaker Studio Interface Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sagemaker_studio" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.sagemaker.studio"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-sagemaker-studio-endpoint"
    Purpose = "SageMakerStudioAccess"
  })
}

# --------------------------------------------------------------------------
#  ECR API Interface Endpoint (for container images)
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ecr_api" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-ecr-api-endpoint"
    Purpose = "ECRAccess"
  })
}

# --------------------------------------------------------------------------
#  ECR DKR Interface Endpoint (for Docker registry)
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ecr_dkr" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-ecr-dkr-endpoint"
    Purpose = "ECRDockerAccess"
  })
}

# --------------------------------------------------------------------------
#  CloudWatch Logs Interface Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "logs" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-logs-endpoint"
    Purpose = "CloudWatchLogs"
  })
}

# --------------------------------------------------------------------------
#  CloudWatch Monitoring Interface Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "monitoring" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.monitoring"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-monitoring-endpoint"
    Purpose = "CloudWatchMetrics"
  })
}

# --------------------------------------------------------------------------
#  STS Interface Endpoint (for IAM role assumption)
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sts" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-sts-endpoint"
    Purpose = "STSAccess"
  })
}

# --------------------------------------------------------------------------
#  EFS Interface Endpoint (for SageMaker file system)
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "efs" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.elasticfilesystem"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-efs-endpoint"
    Purpose = "EFSAccess"
  })
}

# --------------------------------------------------------------------------
#  KMS Interface Endpoint (for encryption)
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "kms" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  vpc_id            = aws_vpc.infra_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.kms"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.sagemaker_private_a[0].id,
    aws_subnet.sagemaker_private_b[0].id,
    aws_subnet.sagemaker_private_c[0].id
  ]

  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "sagemaker.${var.aws_region}.amazonaws.com",
              "s3.${var.aws_region}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-kms-endpoint"
    Purpose = "KMSAccess"
  })
}

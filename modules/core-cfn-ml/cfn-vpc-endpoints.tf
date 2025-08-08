# ==========================================================================
#  Module Core: cfn-vpc-endpoints.tf
# --------------------------------------------------------------------------
#  Description
#    CloudFormation-Compatible VPC Endpoints Configuration
# --------------------------------------------------------------------------
#    - VPC Endpoints Security Group
#    - S3 Gateway Endpoint
#    - SageMaker Interface Endpoints
#    - Supporting Service Endpoints
# ==========================================================================

# --------------------------------------------------------------------------
#  VPC Endpoints Security Group
# --------------------------------------------------------------------------
resource "aws_security_group" "vpc_endpoints_security_group" {
  count       = var.enable_sagemaker_studio ? 1 : 0
  provider    = aws.destination
  name        = "sg-vpce-${local.project_name}"
  description = "Allow TLS for VPC Endpoint"
  vpc_id      = aws_vpc.infra_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sagemaker_security_group[0].id]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr[local.env]]
    description = "Allow all traffic from the VPC"
  }

  tags = merge(local.tags, {
    Name = "sg-vpce-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  S3 Gateway Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "s3" {
  count           = var.enable_sagemaker_studio ? 1 : 0
  provider        = aws.destination
  vpc_id          = aws_vpc.infra_vpc.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.sagemaker_studio_route_table[0].id]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${local.data_bucket_name}",
          "arn:aws:s3:::${local.model_bucket_name}",
          "arn:aws:s3:::${local.data_bucket_name}/*",
          "arn:aws:s3:::${local.model_bucket_name}/*"
        ]
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "vpce-s3-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  SageMaker API Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sagemaker_api" {
  count               = var.enable_sagemaker_studio ? 1 : 0
  provider            = aws.destination
  vpc_id              = aws_vpc.infra_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.sagemaker.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.sagemaker_studio_subnet[0].id]
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "vpce-sagemaker-api-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  SageMaker Runtime Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sagemaker_runtime" {
  count               = var.enable_sagemaker_studio ? 1 : 0
  provider            = aws.destination
  vpc_id              = aws_vpc.infra_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.sagemaker.runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.sagemaker_studio_subnet[0].id]
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "vpce-sagemaker-runtime-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  SageMaker Notebook Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sagemaker_notebook" {
  count               = var.enable_sagemaker_studio ? 1 : 0
  provider            = aws.destination
  vpc_id              = aws_vpc.infra_vpc.id
  service_name        = "aws.sagemaker.${var.aws_region}.notebook"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.sagemaker_studio_subnet[0].id]
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "vpce-sagemaker-notebook-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  STS Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sts" {
  count               = var.enable_sagemaker_studio ? 1 : 0
  provider            = aws.destination
  vpc_id              = aws_vpc.infra_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.sagemaker_studio_subnet[0].id]
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "vpce-sts-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  CloudWatch Monitoring Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "cloudwatch" {
  count               = var.enable_sagemaker_studio ? 1 : 0
  provider            = aws.destination
  vpc_id              = aws_vpc.infra_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.monitoring"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.sagemaker_studio_subnet[0].id]
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "vpce-cloudwatch-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  CloudWatch Logs Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  count               = var.enable_sagemaker_studio ? 1 : 0
  provider            = aws.destination
  vpc_id              = aws_vpc.infra_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.sagemaker_studio_subnet[0].id]
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "vpce-cloudwatch-logs-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  ECR DKR Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.enable_sagemaker_studio ? 1 : 0
  provider            = aws.destination
  vpc_id              = aws_vpc.infra_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.sagemaker_studio_subnet[0].id]
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "vpce-ecr-dkr-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  ECR API Endpoint
# --------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.enable_sagemaker_studio ? 1 : 0
  provider            = aws.destination
  vpc_id              = aws_vpc.infra_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.sagemaker_studio_subnet[0].id]
  security_group_ids  = [aws_security_group.vpc_endpoints_security_group[0].id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "vpce-ecr-api-${local.project_name}"
  })
}
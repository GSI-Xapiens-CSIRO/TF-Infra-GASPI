# ==========================================================================
#  Module Core: cfn-subnets.tf
# --------------------------------------------------------------------------
#  Description
#    CloudFormation-Compatible Single-AZ Subnet Configuration
# --------------------------------------------------------------------------
#    - Firewall Subnet (single AZ)
#    - NAT Gateway Subnet (single AZ)
#    - SageMaker Studio Subnet (single AZ)
#    - CloudFormation-style naming and tagging
# ==========================================================================

# --------------------------------------------------------------------------
#  Firewall Subnets (Multi-AZ CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_subnet" "ml_firewall_subnet_a" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.firewall_subnet_a[local.env]
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "sn-${local.project_name}-firewall-a"
  })
}

resource "aws_subnet" "ml_firewall_subnet_b" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.firewall_subnet_b[local.env]
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "sn-${local.project_name}-firewall-b"
  })
}

resource "aws_subnet" "ml_firewall_subnet_c" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.firewall_subnet_c[local.env]
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "sn-${local.project_name}-firewall-c"
  })
}

# --------------------------------------------------------------------------
#  NAT Gateway Subnets (Multi-AZ CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_subnet" "ml_gateway_subnet_a" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.nat_public_a[local.env]
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "sn-${local.project_name}-nat-gateway-a"
  })
}

resource "aws_subnet" "ml_gateway_subnet_b" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.nat_public_b[local.env]
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "sn-${local.project_name}-nat-gateway-b"
  })
}

resource "aws_subnet" "ml_gateway_subnet_c" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.nat_public_c[local.env]
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "sn-${local.project_name}-nat-gateway-c"
  })
}

# Legacy single subnet for backward compatibility
resource "aws_subnet" "ml_gateway_subnet" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.nat_gateway_subnet_cidr[local.env]
  availability_zone       = local.primary_az
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "sn-${local.project_name}-nat-gateway"
  })
}

# --------------------------------------------------------------------------
#  SageMaker Studio Subnet (CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_subnet" "ml_sagemaker_studio_subnet" {
  count                   = var.enable_sagemaker_studio ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.sagemaker_subnet_cidr[local.env]
  availability_zone       = local.primary_az
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "sn-${local.project_name}-sagemaker-studio"
  })
}

# --------------------------------------------------------------------------
#  ML Security Groups (Always Created)
# --------------------------------------------------------------------------
resource "aws_security_group" "ml_vpc_security_group" {
  provider    = aws.destination
  name        = "ml-sg-vpc-${local.project_name}"
  description = "ML VPC Security Group for general ML workloads"
  vpc_id      = aws_vpc.infra_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr[local.env]]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "ml-sg-vpc-${local.project_name}"
  })
}

resource "aws_security_group" "ml_sagemaker_security_group" {
  count       = var.enable_sagemaker_studio ? 1 : 0
  provider    = aws.destination
  name        = "ml-sg-sagemaker-${local.project_name}"
  description = "security group for SageMaker notebook instance, training jobs and hosting endpoint"
  vpc_id      = aws_vpc.infra_vpc.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self      = true
  }

  tags = merge(local.tags, {
    Name = "ml-sg-sagemaker-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  SageMaker Security Group Self-Referencing Rule
# --------------------------------------------------------------------------
resource "aws_security_group_rule" "ml_sagemaker_self_reference" {
  count                    = var.enable_sagemaker_studio ? 1 : 0
  provider                 = aws.destination
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ml_sagemaker_security_group[0].id
  security_group_id        = aws_security_group.ml_sagemaker_security_group[0].id
}
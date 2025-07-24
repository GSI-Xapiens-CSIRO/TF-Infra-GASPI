# ==========================================================================
#  Module Core: ml-subnets.tf
# --------------------------------------------------------------------------
#  Description
#    ML Security Subnets for SageMaker Studio and Network Firewall
# --------------------------------------------------------------------------
#    - SageMaker Private Subnets
#    - Network Firewall Subnets
#    - NAT Gateway Public Subnets
#    - Enhanced Security Tags
# ==========================================================================

# --------------------------------------------------------------------------
#  ML Subnet Tags
# --------------------------------------------------------------------------
locals {
  tags_sagemaker_private_subnet = {
    ResourceGroup = "${var.environment[local.env]}-ML-SAGEMAKER"
    Purpose       = "SageMakerStudio"
    Security      = "Private"
  }

  tags_firewall_subnet = {
    ResourceGroup = "${var.environment[local.env]}-ML-FIREWALL"
    Purpose       = "NetworkFirewall"
    Security      = "Inspection"
  }

  tags_nat_public_subnet = {
    ResourceGroup = "${var.environment[local.env]}-ML-NAT"
    Purpose       = "NATGateway"
    Security      = "Public"
  }

  # SageMaker specific tags for ML workloads
  tags_ml_workload = {
    "sagemaker:studio-domain" = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.sagemaker_domain_name}"
    "ml-security:level"       = "restricted"
    "data-classification"     = "confidential"
  }

  # Network Firewall specific tags
  tags_firewall_inspection = {
    "firewall:inspection" = "enabled"
    "traffic-control"     = "strict"
    "ml-data-protection"  = "enabled"
  }
}

# --------------------------------------------------------------------------
#  SageMaker Private Subnets
# --------------------------------------------------------------------------
resource "aws_subnet" "sagemaker_private_a" {
  count                   = var.enable_sagemaker_studio ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.sagemaker_private_a[local.env]
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = merge(
    local.tags,
    local.tags_sagemaker_private_subnet,
    local.tags_ml_workload,
    {
      Name                              = "${var.coreinfra}-${var.workspace_env[local.env]}-private-${var.sagemaker_prefix}-${var.aws_region}a"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

resource "aws_subnet" "sagemaker_private_b" {
  count                   = var.enable_sagemaker_studio ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.sagemaker_private_b[local.env]
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = merge(
    local.tags,
    local.tags_sagemaker_private_subnet,
    local.tags_ml_workload,
    {
      Name                              = "${var.coreinfra}-${var.workspace_env[local.env]}-private-${var.sagemaker_prefix}-${var.aws_region}b"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

resource "aws_subnet" "sagemaker_private_c" {
  count                   = var.enable_sagemaker_studio ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.sagemaker_private_c[local.env]
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = false

  tags = merge(
    local.tags,
    local.tags_sagemaker_private_subnet,
    local.tags_ml_workload,
    {
      Name                              = "${var.coreinfra}-${var.workspace_env[local.env]}-private-${var.sagemaker_prefix}-${var.aws_region}c"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# --------------------------------------------------------------------------
#  Network Firewall Subnets
# --------------------------------------------------------------------------
resource "aws_subnet" "firewall_a" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.firewall_subnet_a[local.env]
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = merge(
    local.tags,
    local.tags_firewall_subnet,
    local.tags_firewall_inspection,
    {
      Name = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.firewall_prefix}-${var.aws_region}a"
    }
  )
}

resource "aws_subnet" "firewall_b" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.firewall_subnet_b[local.env]
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = merge(
    local.tags,
    local.tags_firewall_subnet,
    local.tags_firewall_inspection,
    {
      Name = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.firewall_prefix}-${var.aws_region}b"
    }
  )
}

resource "aws_subnet" "firewall_c" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.firewall_subnet_c[local.env]
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = false

  tags = merge(
    local.tags,
    local.tags_firewall_subnet,
    local.tags_firewall_inspection,
    {
      Name = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.firewall_prefix}-${var.aws_region}c"
    }
  )
}

# --------------------------------------------------------------------------
#  NAT Gateway Public Subnets (dedicated for ML traffic)
# --------------------------------------------------------------------------
resource "aws_subnet" "nat_public_a" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.nat_public_a[local.env]
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    local.tags_nat_public_subnet,
    {
      Name                     = "${var.coreinfra}-${var.workspace_env[local.env]}-public-nat-${var.aws_region}a"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "nat_public_b" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.nat_public_b[local.env]
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    local.tags_nat_public_subnet,
    {
      Name                     = "${var.coreinfra}-${var.workspace_env[local.env]}-public-nat-${var.aws_region}b"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "nat_public_c" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.nat_public_c[local.env]
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    local.tags_nat_public_subnet,
    {
      Name                     = "${var.coreinfra}-${var.workspace_env[local.env]}-public-nat-${var.aws_region}c"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

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
#  Firewall Subnet (CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_subnet" "firewall_subnet" {
  count                   = var.enable_network_firewall ? 1 : 0
  provider                = aws.destination
  vpc_id                  = aws_vpc.infra_vpc.id
  cidr_block              = var.firewall_subnet_cidr[local.env]
  availability_zone       = local.primary_az
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "sn-${local.project_name}-firewall"
  })
}

# --------------------------------------------------------------------------
#  NAT Gateway Subnet (CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_subnet" "nat_gateway_subnet" {
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
resource "aws_subnet" "sagemaker_studio_subnet" {
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
#  SageMaker Security Group (CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_security_group" "sagemaker_security_group" {
  count       = var.enable_sagemaker_studio ? 1 : 0
  provider    = aws.destination
  name        = "sg-sagemaker-${local.project_name}"
  description = "security group for SageMaker notebook instance, training jobs and hosting endpoint"
  vpc_id      = aws_vpc.infra_vpc.id

  tags = merge(local.tags, {
    Name = "sg-sagemaker-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  SageMaker Security Group Self-Referencing Rule
# --------------------------------------------------------------------------
resource "aws_security_group_rule" "sagemaker_self_reference" {
  count                    = var.enable_sagemaker_studio ? 1 : 0
  provider                 = aws.destination
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sagemaker_security_group[0].id
  security_group_id        = aws_security_group.sagemaker_security_group[0].id
}
# ==========================================================================
#  Module Core: cfn-routing.tf
# --------------------------------------------------------------------------
#  Description
#    CloudFormation-Compatible Routing Configuration
# --------------------------------------------------------------------------
#    - Route Tables (CloudFormation style)
#    - Route Table Associations
#    - Routes with Network Firewall endpoints
# ==========================================================================

# --------------------------------------------------------------------------
#  IGW Ingress Route Table
# --------------------------------------------------------------------------
resource "aws_route_table" "igw_ingress_route_table" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  tags = merge(local.tags, {
    Name = "rtb-${local.project_name}-igw"
  })
}

# --------------------------------------------------------------------------
#  Firewall Route Table
# --------------------------------------------------------------------------
resource "aws_route_table" "firewall_route_table" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  tags = merge(local.tags, {
    Name = "rtb-${local.project_name}-firewall"
  })
}

# --------------------------------------------------------------------------
#  NAT Gateway Route Table
# --------------------------------------------------------------------------
resource "aws_route_table" "nat_gateway_route_table" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  tags = merge(local.tags, {
    Name = "rtb-${local.project_name}-nat-gateway"
  })
}

# --------------------------------------------------------------------------
#  SageMaker Studio Route Table
# --------------------------------------------------------------------------
resource "aws_route_table" "sagemaker_studio_route_table" {
  count    = var.enable_sagemaker_studio ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  tags = merge(local.tags, {
    Name = "rtb-${local.project_name}-sagemaker"
  })
}

# --------------------------------------------------------------------------
#  Route Table Associations
# --------------------------------------------------------------------------
resource "aws_route_table_association" "igw_route_table_association" {
  count          = var.enable_network_firewall ? 1 : 0
  provider       = aws.destination
  route_table_id = aws_route_table.igw_ingress_route_table[0].id
  gateway_id     = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "firewall_subnet_route_table_association" {
  count          = var.enable_network_firewall ? 1 : 0
  provider       = aws.destination
  route_table_id = aws_route_table.firewall_route_table[0].id
  subnet_id      = aws_subnet.firewall_subnet[0].id
}

resource "aws_route_table_association" "nat_gateway_subnet_route_table_association" {
  count          = var.enable_network_firewall ? 1 : 0
  provider       = aws.destination
  route_table_id = aws_route_table.nat_gateway_route_table[0].id
  subnet_id      = aws_subnet.nat_gateway_subnet[0].id
}

resource "aws_route_table_association" "sagemaker_studio_route_table_association" {
  count          = var.enable_sagemaker_studio ? 1 : 0
  provider       = aws.destination
  route_table_id = aws_route_table.sagemaker_studio_route_table[0].id
  subnet_id      = aws_subnet.sagemaker_studio_subnet[0].id
}

# --------------------------------------------------------------------------
#  Routes
# --------------------------------------------------------------------------

# IGW Ingress Route - Traffic to NAT Gateway subnet goes through firewall
resource "aws_route" "igw_ingress_route" {
  count                  = var.enable_network_firewall ? 1 : 0
  provider               = aws.destination
  route_table_id         = aws_route_table.igw_ingress_route_table[0].id
  destination_cidr_block = var.nat_gateway_subnet_cidr[local.env]
  vpc_endpoint_id        = element(split(":", tolist(tolist(aws_networkfirewall_firewall.network_firewall[0].firewall_status[0].sync_states)[0].attachment)[0].endpoint_id), 1)
}

# Firewall Egress Route - Traffic to internet goes through IGW
resource "aws_route" "firewall_egress_route" {
  count                  = var.enable_network_firewall ? 1 : 0
  provider               = aws.destination
  route_table_id         = aws_route_table.firewall_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# NAT Gateway Egress Route - Traffic to internet goes through firewall
resource "aws_route" "nat_gateway_egress_route" {
  count                  = var.enable_network_firewall ? 1 : 0
  provider               = aws.destination
  route_table_id         = aws_route_table.nat_gateway_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = element(split(":", tolist(tolist(aws_networkfirewall_firewall.network_firewall[0].firewall_status[0].sync_states)[0].attachment)[0].endpoint_id), 1)
}

# SageMaker Egress Route - Traffic to internet goes through NAT Gateway
resource "aws_route" "sagemaker_egress_route" {
  count                  = var.enable_sagemaker_studio ? 1 : 0
  provider               = aws.destination
  route_table_id         = aws_route_table.sagemaker_studio_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[0].id
}
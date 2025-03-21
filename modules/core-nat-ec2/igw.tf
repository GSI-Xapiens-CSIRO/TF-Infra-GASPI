# ==========================================================================
#  Module Core: igw.tf
# --------------------------------------------------------------------------
#  Description
#    Internet Gateway for EC2
# --------------------------------------------------------------------------
#    - IGW Public Subnet
#    - Route Table Public Subnet from IGW
# ==========================================================================

# --------------------------------------------------------------------------
#  IGW Tags
# --------------------------------------------------------------------------
locals {
  tags_igw_rt_public = {
    ResourceGroup = "${var.environment[local.env]}-RT"
    Name          = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.igw_rt_prefix}"
  }

  tags_igw = {
    ResourceGroup = "${var.environment[local.env]}-IGW"
    Name          = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.igw_prefix}"
  }

  tags_ec2_rt_public = {
    ResourceGroup = "${var.environment[local.env]}-RT-EC2"
    Name          = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.ec2_rt_prefix}-public"
  }

  tags_ec2 = {
    ResourceGroup = "${var.environment[local.env]}-EC2"
    Name          = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.ec2_rt_prefix}-public"
  }
}

# --------------------------------------------------------------------------
#  IGW
# --------------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  tags = merge(local.tags, local.tags_igw, { Name = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.igw_prefix}" }, local.tags_elb)
}

## --------------------------------------------------------------------------
#  Route Table for IGW
# --------------------------------------------------------------------------
## EC2
resource "aws_route_table" "igw_ec2_rt_public_a" {
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Added (Peers)
  # propagating_vgws = [var.propagating_vgws[local.env]]

  # route {
  #   cidr_block                = var.cidr_block_vpc_peering[local.env]
  #   vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
  # }

  tags = merge(local.tags, local.tags_igw_rt_public, { Name = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.ec2_rt_prefix}-public-${var.aws_region}a" }, local.tags_elb)
}

resource "aws_route_table" "igw_ec2_rt_public_b" {
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Added (Peers)
  # propagating_vgws = [var.propagating_vgws[local.env]]

  # route {
  #   cidr_block                = var.cidr_block_vpc_peering[local.env]
  #   vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
  # }

  tags = merge(local.tags, local.tags_igw_rt_public, { Name = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.ec2_rt_prefix}-public-${var.aws_region}b" }, local.tags_elb)
}

resource "aws_route_table" "igw_ec2_rt_public_c" {
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Added (Peers)
  # propagating_vgws = [var.propagating_vgws[local.env]]

  # route {
  #   cidr_block                = var.cidr_block_vpc_peering[local.env]
  #   vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
  # }

  tags = merge(local.tags, local.tags_igw_rt_public, { Name = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.ec2_rt_prefix}-public-${var.aws_region}c" }, local.tags_elb)
}

# --------------------------------------------------------------------------
#  Route Table with Public Subnet
# --------------------------------------------------------------------------
## EC2
resource "aws_route_table_association" "igw_ec2_rt_public_1a" {
  provider       = aws.destination
  subnet_id      = aws_subnet.ec2_public_a.id
  route_table_id = aws_route_table.igw_ec2_rt_public_a.id
}

resource "aws_route_table_association" "igw_ec2_rt_public_1b" {
  provider       = aws.destination
  subnet_id      = aws_subnet.ec2_public_b.id
  route_table_id = aws_route_table.igw_ec2_rt_public_b.id
}

resource "aws_route_table_association" "igw_ec2_rt_public_1c" {
  provider       = aws.destination
  subnet_id      = aws_subnet.ec2_public_c.id
  route_table_id = aws_route_table.igw_ec2_rt_public_c.id
}

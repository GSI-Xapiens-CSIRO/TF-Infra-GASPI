# ==========================================================================
#  Module Core: ml-routing.tf (FIXED VERSION)
# --------------------------------------------------------------------------
#  Description
#    Routing Configuration for ML Security with Network Firewall
# --------------------------------------------------------------------------
#    - Fixed firewall endpoint extraction
#    - Fixed subnet CIDR references
#    - Conditional routing based on subnet availability
# ==========================================================================

# --------------------------------------------------------------------------
#  Data Sources for Firewall Endpoints
# --------------------------------------------------------------------------
data "aws_networkfirewall_firewall" "ml_security_firewall" {
  count = var.enable_network_firewall ? 1 : 0
  arn   = aws_networkfirewall_firewall.ml_security_firewall[0].arn

  depends_on = [aws_networkfirewall_firewall.ml_security_firewall]
}

# --------------------------------------------------------------------------
#  Fixed Locals for Firewall Endpoints
# --------------------------------------------------------------------------
locals {
  # Extract firewall endpoint IDs using correct iteration
  firewall_endpoints = var.enable_network_firewall && length(data.aws_networkfirewall_firewall.ml_security_firewall) > 0 ? {
    for sync_state in data.aws_networkfirewall_firewall.ml_security_firewall[0].firewall_status[0].sync_states :
    sync_state.availability_zone => sync_state.attachment[0].endpoint_id
    if sync_state.attachment != null && length(sync_state.attachment) > 0
  } : {}

  # Create endpoint list for fallback
  firewall_endpoint_list = var.enable_network_firewall && length(data.aws_networkfirewall_firewall.ml_security_firewall) > 0 ? [
    for sync_state in data.aws_networkfirewall_firewall.ml_security_firewall[0].firewall_status[0].sync_states :
    sync_state.attachment[0].endpoint_id
    if sync_state.attachment != null && length(sync_state.attachment) > 0
  ] : []

  # Map endpoints to specific AZs with fallback
  firewall_endpoint_az_a = try(local.firewall_endpoints["${var.aws_region}a"], length(local.firewall_endpoint_list) > 0 ? local.firewall_endpoint_list[0] : null)
  firewall_endpoint_az_b = try(local.firewall_endpoints["${var.aws_region}b"], length(local.firewall_endpoint_list) > 1 ? local.firewall_endpoint_list[1] : null)
  firewall_endpoint_az_c = try(local.firewall_endpoints["${var.aws_region}c"], length(local.firewall_endpoint_list) > 2 ? local.firewall_endpoint_list[2] : null)

  # Check if SageMaker subnets are created
  sagemaker_subnets_exist = var.enable_sagemaker_studio && var.enable_network_firewall
}

# --------------------------------------------------------------------------
#  Enhanced NAT Gateways for ML Traffic
# --------------------------------------------------------------------------
resource "aws_eip" "ml_nat_a" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  domain   = "vpc"

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-eip-ml-nat-a"
    Purpose = "MLNATGateway"
  })
}

resource "aws_eip" "ml_nat_b" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  domain   = "vpc"

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-eip-ml-nat-b"
    Purpose = "MLNATGateway"
  })
}

resource "aws_eip" "ml_nat_c" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  domain   = "vpc"

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-eip-ml-nat-c"
    Purpose = "MLNATGateway"
  })
}

resource "aws_nat_gateway" "ml_nat_a" {
  count         = var.enable_network_firewall ? 1 : 0
  provider      = aws.destination
  allocation_id = aws_eip.ml_nat_a[0].id
  subnet_id     = aws_subnet.nat_public_a[0].id

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-ml-nat-a"
    Purpose = "MLNATGateway"
    Zone    = "${var.aws_region}a"
  })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ml_nat_b" {
  count         = var.enable_network_firewall ? 1 : 0
  provider      = aws.destination
  allocation_id = aws_eip.ml_nat_b[0].id
  subnet_id     = aws_subnet.nat_public_b[0].id

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-ml-nat-b"
    Purpose = "MLNATGateway"
    Zone    = "${var.aws_region}b"
  })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ml_nat_c" {
  count         = var.enable_network_firewall ? 1 : 0
  provider      = aws.destination
  allocation_id = aws_eip.ml_nat_c[0].id
  subnet_id     = aws_subnet.nat_public_c[0].id

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-ml-nat-c"
    Purpose = "MLNATGateway"
    Zone    = "${var.aws_region}c"
  })

  depends_on = [aws_internet_gateway.igw]
}

# --------------------------------------------------------------------------
#  Route Tables for SageMaker Subnets (Private → Firewall)
# --------------------------------------------------------------------------
resource "aws_route_table" "sagemaker_rt_a" {
  count    = local.sagemaker_subnets_exist ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  # Route all internet traffic through Network Firewall
  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = local.firewall_endpoint_az_a
  }

  tags = merge(local.tags, {
    Name          = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.sagemaker_rt_prefix}-a"
    Purpose       = "SageMakerRouting"
    SecurityLevel = "High"
    Zone          = "${var.aws_region}a"
  })

  depends_on = [aws_networkfirewall_firewall.ml_security_firewall]
}

resource "aws_route_table" "sagemaker_rt_b" {
  count    = local.sagemaker_subnets_exist ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = local.firewall_endpoint_az_b
  }

  tags = merge(local.tags, {
    Name          = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.sagemaker_rt_prefix}-b"
    Purpose       = "SageMakerRouting"
    SecurityLevel = "High"
    Zone          = "${var.aws_region}b"
  })

  depends_on = [aws_networkfirewall_firewall.ml_security_firewall]
}

resource "aws_route_table" "sagemaker_rt_c" {
  count    = local.sagemaker_subnets_exist ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = local.firewall_endpoint_az_c
  }

  tags = merge(local.tags, {
    Name          = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.sagemaker_rt_prefix}-c"
    Purpose       = "SageMakerRouting"
    SecurityLevel = "High"
    Zone          = "${var.aws_region}c"
  })

  depends_on = [aws_networkfirewall_firewall.ml_security_firewall]
}

# --------------------------------------------------------------------------
#  Route Tables for Firewall Subnets (Firewall → NAT)
# --------------------------------------------------------------------------
resource "aws_route_table" "firewall_rt_a" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  # Route traffic from firewall to NAT gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ml_nat_a[0].id
  }

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.firewall_rt_prefix}-a"
    Purpose = "FirewallRouting"
    Zone    = "${var.aws_region}a"
  })
}

resource "aws_route_table" "firewall_rt_b" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ml_nat_b[0].id
  }

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.firewall_rt_prefix}-b"
    Purpose = "FirewallRouting"
    Zone    = "${var.aws_region}b"
  })
}

resource "aws_route_table" "firewall_rt_c" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ml_nat_c[0].id
  }

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-${var.firewall_rt_prefix}-c"
    Purpose = "FirewallRouting"
    Zone    = "${var.aws_region}c"
  })
}

# --------------------------------------------------------------------------
#  FIXED: Route Tables for NAT Public Subnets (NAT → Internet Gateway)
# --------------------------------------------------------------------------
resource "aws_route_table" "nat_public_rt_a" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  # Default route to internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # CONDITIONAL: Only add SageMaker routes if SageMaker subnets exist
  dynamic "route" {
    for_each = local.sagemaker_subnets_exist ? [
      {
        cidr_block = var.sagemaker_private_a[local.env]
        endpoint_id = local.firewall_endpoint_az_a
      },
      {
        cidr_block = var.sagemaker_private_b[local.env]
        endpoint_id = local.firewall_endpoint_az_a
      },
      {
        cidr_block = var.sagemaker_private_c[local.env]
        endpoint_id = local.firewall_endpoint_az_a
      }
    ] : []

    content {
      cidr_block      = route.value.cidr_block
      vpc_endpoint_id = route.value.endpoint_id
    }
  }

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-nat-public-rt-a"
    Purpose = "NATPublicRouting"
    Zone    = "${var.aws_region}a"
  })

  depends_on = [aws_networkfirewall_firewall.ml_security_firewall]
}

resource "aws_route_table" "nat_public_rt_b" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  dynamic "route" {
    for_each = local.sagemaker_subnets_exist ? [
      {
        cidr_block = var.sagemaker_private_a[local.env]
        endpoint_id = local.firewall_endpoint_az_b
      },
      {
        cidr_block = var.sagemaker_private_b[local.env]
        endpoint_id = local.firewall_endpoint_az_b
      },
      {
        cidr_block = var.sagemaker_private_c[local.env]
        endpoint_id = local.firewall_endpoint_az_b
      }
    ] : []

    content {
      cidr_block      = route.value.cidr_block
      vpc_endpoint_id = route.value.endpoint_id
    }
  }

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-nat-public-rt-b"
    Purpose = "NATPublicRouting"
    Zone    = "${var.aws_region}b"
  })

  depends_on = [aws_networkfirewall_firewall.ml_security_firewall]
}

resource "aws_route_table" "nat_public_rt_c" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  vpc_id   = aws_vpc.infra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  dynamic "route" {
    for_each = local.sagemaker_subnets_exist ? [
      {
        cidr_block = var.sagemaker_private_a[local.env]
        endpoint_id = local.firewall_endpoint_az_c
      },
      {
        cidr_block = var.sagemaker_private_b[local.env]
        endpoint_id = local.firewall_endpoint_az_c
      },
      {
        cidr_block = var.sagemaker_private_c[local.env]
        endpoint_id = local.firewall_endpoint_az_c
      }
    ] : []

    content {
      cidr_block      = route.value.cidr_block
      vpc_endpoint_id = route.value.endpoint_id
    }
  }

  tags = merge(local.tags, {
    Name    = "${var.coreinfra}-${var.workspace_env[local.env]}-nat-public-rt-c"
    Purpose = "NATPublicRouting"
    Zone    = "${var.aws_region}c"
  })

  depends_on = [aws_networkfirewall_firewall.ml_security_firewall]
}

# --------------------------------------------------------------------------
#  Route Table Associations
# --------------------------------------------------------------------------
# SageMaker Subnets (only if they exist)
resource "aws_route_table_association" "sagemaker_rt_assoc_a" {
  count          = local.sagemaker_subnets_exist ? 1 : 0
  provider       = aws.destination
  subnet_id      = aws_subnet.sagemaker_private_a[0].id
  route_table_id = aws_route_table.sagemaker_rt_a[0].id
}

resource "aws_route_table_association" "sagemaker_rt_assoc_b" {
  count          = local.sagemaker_subnets_exist ? 1 : 0
  provider       = aws.destination
  subnet_id      = aws_subnet.sagemaker_private_b[0].id
  route_table_id = aws_route_table.sagemaker_rt_b[0].id
}

resource "aws_route_table_association" "sagemaker_rt_assoc_c" {
  count          = local.sagemaker_subnets_exist ? 1 : 0
  provider       = aws.destination
  subnet_id      = aws_subnet.sagemaker_private_c[0].id
  route_table_id = aws_route_table.sagemaker_rt_c[0].id
}

# Firewall Subnets
resource "aws_route_table_association" "firewall_rt_assoc_a" {
  count          = var.enable_network_firewall ? 1 : 0
  provider       = aws.destination
  subnet_id      = aws_subnet.firewall_a[0].id
  route_table_id = aws_route_table.firewall_rt_a[0].id
}

resource "aws_route_table_association" "firewall_rt_assoc_b" {
  count          = var.enable_network_firewall ? 1 : 0
  provider       = aws.destination
  subnet_id      = aws_subnet.firewall_b[0].id
  route_table_id = aws_route_table.firewall_rt_b[0].id
}

resource "aws_route_table_association" "firewall_rt_assoc_c" {
  count          = var.enable_network_firewall ? 1 : 0
  provider       = aws.destination
  subnet_id      = aws_subnet.firewall_c[0].id
  route_table_id = aws_route_table.firewall_rt_c[0].id
}

# NAT Public Subnets
resource "aws_route_table_association" "nat_public_rt_assoc_a" {
  count          = var.enable_network_firewall ? 1 : 0
  provider       = aws.destination
  subnet_id      = aws_subnet.nat_public_a[0].id
  route_table_id = aws_route_table.nat_public_rt_a[0].id
}

resource "aws_route_table_association" "nat_public_rt_assoc_b" {
  count          = var.enable_network_firewall ? 1 : 0
  provider       = aws.destination
  subnet_id      = aws_subnet.nat_public_b[0].id
  route_table_id = aws_route_table.nat_public_rt_b[0].id
}

resource "aws_route_table_association" "nat_public_rt_assoc_c" {
  count          = var.enable_network_firewall ? 1 : 0
  provider       = aws.destination
  subnet_id      = aws_subnet.nat_public_c[0].id
  route_table_id = aws_route_table.nat_public_rt_c[0].id
}

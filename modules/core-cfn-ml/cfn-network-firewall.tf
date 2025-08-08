# ==========================================================================
#  Module Core: cfn-network-firewall.tf
# --------------------------------------------------------------------------
#  Description
#    CloudFormation-Compatible Network Firewall Configuration
# --------------------------------------------------------------------------
#    - Domain Allow Rule Group (CloudFormation style)
#    - Firewall Policy
#    - Network Firewall (single AZ)
#    - CloudWatch Logging
# ==========================================================================

# --------------------------------------------------------------------------
#  EIP for NAT Gateway
# --------------------------------------------------------------------------
resource "aws_eip" "nat_gateway_eip" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  domain   = "vpc"

  tags = merge(local.tags, {
    Name = "eip-${local.project_name}-nat"
  })
}

# --------------------------------------------------------------------------
#  Domain Allow Stateful Rule Group (CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_networkfirewall_rule_group" "domain_allow_stateful" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  capacity = 100
  name     = "domain-allow-${local.project_name}"
  type     = "STATEFUL"

  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.vpc_cidr[local.env]]
        }
      }
    }
    
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.allowed_domains
      }
    }
  }

  tags = merge(local.tags, {
    Name = "domain-allow-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  Firewall Policy (CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_networkfirewall_firewall_policy" "network_firewall_policy" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  name     = "network-firewall-policy-${local.project_name}"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:pass"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.domain_allow_stateful[0].arn
    }
  }

  tags = merge(local.tags, {
    Name = "network-firewall-policy-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  Network Firewall (CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_networkfirewall_firewall" "network_firewall" {
  count                                = var.enable_network_firewall ? 1 : 0
  provider                             = aws.destination
  name                                 = "network-firewall-${local.project_name}"
  firewall_policy_arn                  = aws_networkfirewall_firewall_policy.network_firewall_policy[0].arn
  vpc_id                               = aws_vpc.infra_vpc.id
  delete_protection                    = var.firewall_deletion_protection
  firewall_policy_change_protection    = false
  subnet_change_protection             = false

  subnet_mapping {
    subnet_id = aws_subnet.firewall_subnet[0].id
  }

  tags = merge(local.tags, {
    Name = "network-firewall-${local.project_name}"
  })
}



# --------------------------------------------------------------------------
#  NAT Gateway
# --------------------------------------------------------------------------
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.enable_network_firewall ? 1 : 0
  provider      = aws.destination
  allocation_id = aws_eip.nat_gateway_eip[0].id
  subnet_id     = aws_subnet.nat_gateway_subnet[0].id

  tags = merge(local.tags, {
    Name = "nat-gateway-${local.project_name}"
  })

  depends_on = [aws_internet_gateway.igw]
}
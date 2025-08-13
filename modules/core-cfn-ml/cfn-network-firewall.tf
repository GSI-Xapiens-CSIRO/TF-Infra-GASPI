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
#  EIP for NAT Gateway (Single)
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
#  ICMP Block Stateless Rule Group
# --------------------------------------------------------------------------
resource "aws_networkfirewall_rule_group" "icmp_block_stateless" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  capacity = 10
  name     = "icmp-block-${local.project_name}"
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1] # ICMP protocol
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }

  tags = merge(local.tags, {
    Name = "icmp-block-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  CIDR Stateless Rule Group
# --------------------------------------------------------------------------
resource "aws_networkfirewall_rule_group" "cidr_allow_stateless" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  capacity = 100
  name     = "cidr-allow-${local.project_name}"
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        dynamic "stateless_rule" {
          for_each = var.allowed_cidr_blocks
          iterator = cidr
          content {
            priority = 100 + cidr.key
            rule_definition {
              actions = ["aws:pass"]
              match_attributes {
                source {
                  address_definition = cidr.value
                }
              }
            }
          }
        }
      }
    }
  }

  tags = merge(local.tags, {
    Name = "cidr-allow-${local.project_name}"
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

    stateless_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.icmp_block_stateless[0].arn
      priority     = 1
    }

    stateless_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.cidr_allow_stateless[0].arn
      priority     = 100
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.domain_allow_stateful[0].arn
    }
  }

  tags = merge(local.tags, {
    Name = "network-firewall-policy-${local.project_name}"
  })
}

# --------------------------------------------------------------------------
#  Network Firewall (Multi-AZ CloudFormation style)
# --------------------------------------------------------------------------
resource "aws_networkfirewall_firewall" "network_firewall" {
  count                             = var.enable_network_firewall ? 1 : 0
  provider                          = aws.destination
  name                              = "network-firewall-${local.project_name}"
  firewall_policy_arn               = aws_networkfirewall_firewall_policy.network_firewall_policy[0].arn
  vpc_id                            = aws_vpc.infra_vpc.id
  delete_protection                 = var.firewall_deletion_protection
  firewall_policy_change_protection = false
  subnet_change_protection          = false

  subnet_mapping {
    subnet_id = aws_subnet.ml_firewall_subnet_a[0].id
  }

  subnet_mapping {
    subnet_id = aws_subnet.ml_firewall_subnet_b[0].id
  }

  subnet_mapping {
    subnet_id = aws_subnet.ml_firewall_subnet_c[0].id
  }

  tags = merge(local.tags, {
    Name = "network-firewall-${local.project_name}"
  })
}



# --------------------------------------------------------------------------
#  NAT Gateway (Single in Zone A)
# --------------------------------------------------------------------------
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.enable_network_firewall ? 1 : 0
  provider      = aws.destination
  allocation_id = aws_eip.nat_gateway_eip[0].id
  subnet_id     = aws_subnet.ml_gateway_subnet_a[0].id

  tags = merge(local.tags, {
    Name = "${local.project_name}-natgw"
  })

  depends_on = [aws_internet_gateway.igw]
}


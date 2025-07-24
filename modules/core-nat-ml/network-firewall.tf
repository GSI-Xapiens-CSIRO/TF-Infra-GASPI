# ==========================================================================
#  Module Core: network-firewall.tf
# --------------------------------------------------------------------------
#  Description
#    AWS Network Firewall for ML Security
# --------------------------------------------------------------------------
#    - Network Firewall Rule Groups - Domain Allow List
#    - Network Firewall Rule Groups - Domain Block List
#    - Network Firewall Policy
#    - CloudWatch Logs
#    - Corrected content matching patterns
# ==========================================================================

# --------------------------------------------------------------------------
#  Network Firewall Rule Groups - Domain Allow List
# --------------------------------------------------------------------------
resource "aws_networkfirewall_rule_group" "domain_allow_list" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  capacity = 100
  name     = "${var.coreinfra}-${var.workspace_env[local.env]}-domain-allow-list"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.allowed_domains
      }
    }
  }

  tags = merge(local.tags, {
    Name = "${var.coreinfra}-${var.workspace_env[local.env]}-domain-allow-list"
  })
}

# --------------------------------------------------------------------------
#  Network Firewall Rule Groups - Domain Block List
# --------------------------------------------------------------------------
resource "aws_networkfirewall_rule_group" "domain_block_list" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  capacity = 100
  name     = "${var.coreinfra}-${var.workspace_env[local.env]}-domain-block-list"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.blocked_domains
      }
    }
  }

  tags = merge(local.tags, {
    Name = "${var.coreinfra}-${var.workspace_env[local.env]}-domain-block-list"
  })
}

# --------------------------------------------------------------------------
#  Network Firewall Policy
# --------------------------------------------------------------------------
resource "aws_networkfirewall_firewall_policy" "ml_security_policy" {
  count    = var.enable_network_firewall ? 1 : 0
  provider = aws.destination
  name     = "${var.coreinfra}-${var.workspace_env[local.env]}-ml-security-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.domain_block_list[0].arn
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.domain_allow_list[0].arn
    }
  }

  tags = merge(local.tags, {
    Name = "${var.coreinfra}-${var.workspace_env[local.env]}-ml-security-policy"
  })
}

# --------------------------------------------------------------------------
#  Network Firewall
# --------------------------------------------------------------------------
resource "aws_networkfirewall_firewall" "ml_security_firewall" {
  count               = var.enable_network_firewall ? 1 : 0
  provider            = aws.destination
  name                = "${var.coreinfra}-${var.workspace_env[local.env]}-ml-security-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.ml_security_policy[0].arn
  vpc_id              = aws_vpc.infra_vpc.id
  delete_protection   = false # Set to false for testing

  dynamic "subnet_mapping" {
    for_each = var.enable_network_firewall ? [
      {
        subnet_id = aws_subnet.firewall_a[0].id
        az        = "${var.aws_region}a"
      },
      {
        subnet_id = aws_subnet.firewall_b[0].id
        az        = "${var.aws_region}b"
      },
      {
        subnet_id = aws_subnet.firewall_c[0].id
        az        = "${var.aws_region}c"
      }
    ] : []

    content {
      subnet_id = subnet_mapping.value.subnet_id
    }
  }

  tags = merge(local.tags, {
    Name = "${var.coreinfra}-${var.workspace_env[local.env]}-ml-security-firewall"
  })
}

# --------------------------------------------------------------------------
# CloudWatch Logs
# --------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "firewall_alert_logs" {
  count             = var.enable_network_firewall ? 1 : 0
  provider          = aws.destination
  name              = "/aws/networkfirewall/${var.coreinfra}-${var.workspace_env[local.env]}-alerts"
  retention_in_days = 30

  tags = merge(local.tags, {
    Name = "${var.coreinfra}-${var.workspace_env[local.env]}-firewall-alert-logs"
  })
}

resource "aws_cloudwatch_log_group" "firewall_flow_logs" {
  count             = var.enable_network_firewall ? 1 : 0
  provider          = aws.destination
  name              = "/aws/networkfirewall/${var.coreinfra}-${var.workspace_env[local.env]}-flows"
  retention_in_days = 14

  tags = merge(local.tags, {
    Name = "${var.coreinfra}-${var.workspace_env[local.env]}-firewall-flow-logs"
  })
}

resource "aws_networkfirewall_logging_configuration" "ml_security_logging" {
  count        = var.enable_network_firewall ? 1 : 0
  provider     = aws.destination
  firewall_arn = aws_networkfirewall_firewall.ml_security_firewall[0].arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_alert_logs[0].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }

    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_flow_logs[0].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.firewall_alert_logs,
    aws_cloudwatch_log_group.firewall_flow_logs
  ]
}

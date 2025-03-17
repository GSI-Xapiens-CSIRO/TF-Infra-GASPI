resource "aws_opensearch_domain" "cloudtrail" {
  domain_name    = "opensearch-${var.aws_account_id_destination}"
  engine_version = "OpenSearch_2.9"

  cluster_config {
    instance_type          = var.opensearch_instance_type
    instance_count         = var.opensearch_instance_count
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = 2
    }

    dedicated_master_enabled = var.environment[local.env] == "prod" ? true : false
    dedicated_master_type    = var.environment[local.env] == "prod" ? "m6g.large.search" : "t3.small.search"
    dedicated_master_count   = var.environment[local.env] == "prod" ? 3 : 2
  }

  # vpc_options {
  #   subnet_ids         = slice(var.private_subnet_ids, 0, 2)
  #   security_group_ids = [aws_security_group.opensearch.id]
  # }

  ebs_options {
    ebs_enabled = true
    volume_size = var.opensearch_volume_size
    volume_type = "gp3"
    iops        = 3000
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.cloudtrail.arn
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled = true
    ## Internal User Database ##
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.opensearch_master_user
      master_user_password = var.opensearch_master_password
    }
  }

  ## Using Cognito Users ##
  # cognito_options {
  #   enabled          = true
  #   user_pool_id     = aws_cognito_user_pool.opensearch.id
  #   identity_pool_id = aws_cognito_identity_pool.opensearch.id
  #   role_arn         = aws_iam_role.cognito_opensearch.arn
  # }

  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
    log_type                 = "INDEX_SLOW_LOGS"
    enabled                  = true
  }

  dynamic "auto_tune_options" {
    for_each = var.environment[local.env] == "prod" ? [1] : []
    content {
      desired_state = "ENABLED"
      maintenance_schedule {
        start_at = timeadd(timestamp(), "24h")
        duration {
          value = 2
          unit  = "HOURS"
        }
        cron_expression_for_recurrence = "cron(0 0 ? * 1 *)"
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name    = "genomic-cloudtrail-${var.aws_account_id_destination}"
      Service = "OpenSearch"
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.cloudtrail,
    aws_cloudwatch_log_resource_policy.cloudtrail,
    aws_security_group.opensearch
  ]

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      cluster_config,
      advanced_security_options,
      cognito_options,
    ]
  }
}

#### Cognito User Pool and Identity Pool ####
# Cognito User Pool
resource "aws_cognito_user_pool" "opensearch" {
  name = "opensearch-user-pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  mfa_configuration = "ON"

  software_token_mfa_configuration {
    enabled = true
  }

  tags = local.common_tags
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "opensearch" {
  name         = "opensearch-client"
  user_pool_id = aws_cognito_user_pool.opensearch.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
  refresh_token_validity        = 30
}

# Cognito Identity Pool
resource "aws_cognito_identity_pool" "opensearch" {
  identity_pool_name = "opensearch_identity_pool"

  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.opensearch.id
    provider_name           = aws_cognito_user_pool.opensearch.endpoint
    server_side_token_check = true
  }

  tags = local.common_tags
}

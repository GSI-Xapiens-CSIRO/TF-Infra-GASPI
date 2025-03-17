# ==========================================================================
#  Module S3 Logs: output.tf
# --------------------------------------------------------------------------
#  Description
#    Output Terraform Value
# --------------------------------------------------------------------------
#    - Bucket Properties
#    - Bucket Policy
#    - Lifecycle Rules
#    - Versioning Status
#    - Encryption Configuration
# ==========================================================================

output "bucket" {
  description = "The S3 bucket details"
  value = {
    id                   = aws_s3_bucket.logs.id
    arn                  = aws_s3_bucket.logs.arn
    domain_name          = aws_s3_bucket.logs.bucket_domain_name
    regional_domain_name = aws_s3_bucket.logs.bucket_regional_domain_name
  }
}

output "bucket_policy" {
  description = "The S3 bucket policy document"
  value = {
    id     = aws_s3_bucket_policy.logs.id
    policy = aws_s3_bucket_policy.logs.policy
  }
}

output "lifecycle_rules" {
  description = "The configured lifecycle rules"
  value = {
    for rule in aws_s3_bucket_lifecycle_configuration.logs.rule : rule.id => {
      prefix           = try(rule.filter.prefix, "")
      standard_ia_days = var.retention_config[split("-", rule.id)[0]].standard_ia_days
      glacier_days     = var.retention_config[split("-", rule.id)[0]].glacier_days
      expiration_days  = var.retention_config[split("-", rule.id)[0]].expiration_days
    }
  }
}

output "versioning_status" {
  description = "The versioning status of the bucket"
  value       = aws_s3_bucket_versioning.logs.versioning_configuration[0].status
}

output "encryption_configuration" {
  description = "The encryption configuration of the bucket"
  value = {
    algorithm = [for r in aws_s3_bucket_server_side_encryption_configuration.logs.rule : r.apply_server_side_encryption_by_default[0].sse_algorithm if true][0]
  }
}

output "allowed_accounts" {
  description = "List of accounts allowed to write to the bucket"
  value = {
    for account_id, config in var.allowed_account_ids : account_id => {
      account_id = config.account_id
      name       = config.name
      log_path   = "${aws_s3_bucket.logs.arn}/*/${config.name}/*"
    }
  }
}

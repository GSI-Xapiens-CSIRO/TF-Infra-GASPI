# ==========================================================================
#  Outputs: CloudTails Hub02
# --------------------------------------------------------------------------
#  Description:
#    Output values for CloudTails implementation
# --------------------------------------------------------------------------
#    - List Group
#    - List Policy
#    - List Role
#    - List User
# ==========================================================================

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = module.cloudtrail.cloudtrail_arn
}

output "cloudtrail_bucket" {
  description = "Name of the S3 bucket storing CloudTrail logs"
  value       = module.cloudtrail.cloudtrail_bucket
}

output "cloudtrail_log_group" {
  description = "Name of the CloudWatch Log Group for CloudTrail"
  value       = module.cloudtrail.cloudtrail_log_group
}

output "cloudtrail_kms_key_arn" {
  description = "ARN of the KMS key used for CloudTrail encryption"
  value       = module.cloudtrail.cloudtrail_kms_key_arn
}

output "cloudtrail_sns_topic_arn" {
  description = "ARN of the SNS topic for CloudTrail alerts"
  value       = module.cloudtrail.cloudtrail_sns_topic_arn
}

# output "athena_database" {
#   description = "Name of the Athena database for CloudTrail analysis"
#   value       = module.cloudtrail.athena_database
# }

output "cloudwatch_log_groups_sbeacon" {
  description = "List of CloudWatch log groups for Lambda functions"
  value       = module.cloudtrail.cloudwatch_log_groups_sbeacon
}

output "cloudwatch_log_groups_svep" {
  description = "List of CloudWatch log groups for Lambda functions"
  value       = module.cloudtrail.cloudwatch_log_groups_svep
}

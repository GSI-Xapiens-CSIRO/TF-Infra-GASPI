# ==========================================================================
#  209479276142 - CloudTrail Only: output.tf
# --------------------------------------------------------------------------
#  Description:
#    Output Terraform Value
# --------------------------------------------------------------------------
#    - CloudTrail Info
#    - S3 Bucket Info
#    - KMS Key Info
# ==========================================================================

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = module.cloudtrail_only.cloudtrail_arn
}

output "cloudtrail_name" {
  description = "CloudTrail name"
  value       = module.cloudtrail_only.cloudtrail_name
}

output "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  value       = module.cloudtrail_only.s3_bucket_name
}

output "kms_key_id" {
  description = "KMS key ID for CloudTrail encryption"
  value       = module.cloudtrail_only.kms_key_id
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = module.cloudtrail_only.cloudwatch_log_group_name
}
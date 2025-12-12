# ==========================================================================
#  Module CloudTrail Only: output.tf
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
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_name" {
  description = "CloudTrail name"
  value       = aws_cloudtrail.main.name
}

output "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.arn
}

output "kms_key_id" {
  description = "KMS key ID for CloudTrail encryption"
  value       = aws_kms_key.cloudtrail.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN for CloudTrail encryption"
  value       = aws_kms_key.cloudtrail.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}
output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.genomic_trail.arn
}

output "cloudtrail_bucket" {
  description = "Name of the S3 bucket storing CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_log_group" {
  description = "Name of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_kms_key_arn" {
  description = "ARN of the KMS key used for CloudTrail encryption"
  value       = aws_kms_key.cloudtrail.arn
}

output "cloudtrail_sns_topic_arn" {
  description = "ARN of the SNS topic for CloudTrail alerts"
  value       = aws_sns_topic.cloudtrail_alerts.arn
}

output "cloudwatch_log_groups_sbeacon" {
  description = "List of CloudWatch log groups for Lambda functions"
  value = [
    for func in local.genomic_services.sbeacon.functions : "/aws/lambda/sbeacon-backend-${func}"
  ]
}

output "cloudwatch_log_groups_svep" {
  description = "List of CloudWatch log groups for Lambda functions"
  value = [
    for func in local.genomic_services.svep.functions : "/aws/lambda/svep-backend-${func}"
  ]
}

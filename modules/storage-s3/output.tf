output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "Domain name of the bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "storage_metrics_id" {
  description = "ID of storage metrics configuration"
  value       = aws_s3_bucket_metric.main.id
}

output "intelligent_tiering_config_id" {
  description = "ID of intelligent tiering configuration"
  value       = aws_s3_bucket_intelligent_tiering_configuration.main.id
}
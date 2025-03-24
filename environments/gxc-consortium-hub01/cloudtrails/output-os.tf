# OpenSearch Configuration Outputs
output "opensearch_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = module.cloudtrail.opensearch_endpoint
}

output "opensearch_domain_endpoint" {
  description = "The domain-specific endpoint used to submit index, search, and data upload requests to OpenSearch"
  value       = module.cloudtrail.opensearch_domain_endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "The domain-specific endpoint for OpenSearch Dashboards access"
  value       = module.cloudtrail.opensearch_dashboard_endpoint
}

output "opensearch_domain_arn" {
  description = "The ARN of the OpenSearch domain"
  value       = module.cloudtrail.opensearch_domain_arn
}

output "opensearch_domain_name" {
  description = "The name of the OpenSearch domain"
  value       = module.cloudtrail.opensearch_domain_name
}

# Kinesis Configuration Outputs
output "kinesis_firehose_name" {
  description = "Name of the Kinesis Firehose delivery stream"
  value       = module.cloudtrail.kinesis_firehose_name
}

# IAM Role Outputs
output "kinesis_firehose_opensearch_role_arn" {
  description = "The ARN of the IAM role used by Kinesis Firehose"
  value       = module.cloudtrail.kinesis_firehose_opensearch_role_arn
}

output "kinesis_firehose_stream_name" {
  description = "The name of the Kinesis stream receiving CloudTrail logs"
  value       = module.cloudtrail.kinesis_firehose_stream_name
}

output "kinesis_firehose_stream_arn" {
  description = "The ARN of the Kinesis stream"
  value       = module.cloudtrail.kinesis_firehose_stream_arn
}

# Lambda Configuration Outputs
output "lambda_function_name" {
  description = "The name of the Lambda function transforming CloudTrail logs"
  value       = module.cloudtrail.lambda_function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.cloudtrail.lambda_function_arn
}

# VPC Configuration Outputs
output "vpc_security_group_id" {
  description = "The ID of the security group used for OpenSearch VPC access"
  value       = module.cloudtrail.vpc_security_group_id
}

# CloudWatch Integration Outputs
# output "cloudwatch_kinesis_firehose_role_arn" {
#   description = "The ARN of the IAM role used for CloudWatch to Kinesis integration"
#   value       = module.cloudtrail.cloudwatch_kinesis_firehose_role_arn
# }

# Monitoring URLs
output "cloudwatch_monitoring_url" {
  description = "URL for CloudWatch monitoring dashboard"
  value       = module.cloudtrail.cloudwatch_monitoring_url
}

output "opensearch_dashboard_url" {
  description = "URL for OpenSearch Dashboards access"
  value       = module.cloudtrail.opensearch_dashboard_url
}

# Configuration Summary
output "configuration_summary" {
  description = "Summary of key configuration parameters"
  value = {
    region             = module.cloudtrail.configuration_summary.region
    environment        = module.cloudtrail.configuration_summary.environment
    opensearch_version = module.cloudtrail.configuration_summary.opensearch_version
    instance_type      = module.cloudtrail.configuration_summary.instance_type
    instance_count     = module.cloudtrail.configuration_summary.instance_count
    volume_size        = module.cloudtrail.configuration_summary.volume_size
    retention_period   = module.cloudtrail.configuration_summary.retention_period
    encryption_enabled = module.cloudtrail.configuration_summary.encryption_enabled
    vpc_enabled        = module.cloudtrail.configuration_summary.vpc_enabled
  }
}

output "opensearch_credentials" {
  description = "OpenSearch access credentials"
  value = {
    username               = module.cloudtrail.opensearch_credentials.username
    password               = module.cloudtrail.opensearch_credentials.password
    password_ssm_parameter = module.cloudtrail.opensearch_credentials.password_ssm_parameter
  }
  sensitive = true
}

# Separate outputs for easy access
output "opensearch_master_user" {
  description = "OpenSearch master username"
  value       = module.cloudtrail.opensearch_master_user
}

output "opensearch_password_parameter" {
  description = "SSM Parameter name storing the OpenSearch master password"
  value       = module.cloudtrail.opensearch_password_parameter
}

# Command output to help users retrieve the password
output "password_retrieval_command" {
  description = "AWS CLI command to retrieve the OpenSearch password"
  value       = module.cloudtrail.password_retrieval_command
}

output "opensearch_monitoring_url" {
  description = "URL for OpenSearch monitoring dashboard"
  value       = module.cloudtrail.opensearch_monitoring_url
}

output "metrics_url" {
  description = "URL for CloudWatch metrics"
  value       = module.cloudtrail.metrics_url
}

output "log_group_url" {
  description = "URL for CloudWatch log group"
  value       = module.cloudtrail.log_group_url
}
# OpenSearch Configuration Outputs
output "opensearch_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = aws_opensearch_domain.cloudtrail.endpoint
}

output "opensearch_domain_endpoint" {
  description = "The domain-specific endpoint used to submit index, search, and data upload requests to OpenSearch"
  value       = aws_opensearch_domain.cloudtrail.endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "The domain-specific endpoint for OpenSearch Dashboards access"
  value       = aws_opensearch_domain.cloudtrail.dashboard_endpoint
}

output "opensearch_domain_arn" {
  description = "The ARN of the OpenSearch domain"
  value       = aws_opensearch_domain.cloudtrail.arn
}

output "opensearch_domain_name" {
  description = "The name of the OpenSearch domain"
  value       = aws_opensearch_domain.cloudtrail.domain_name
}

# Kinesis Configuration Outputs
output "kinesis_firehose_name" {
  description = "Name of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.opensearch.name
}

# IAM Role Outputs
output "kinesis_firehose_opensearch_role_arn" {
  description = "The ARN of the IAM role used by Kinesis Firehose"
  value       = aws_iam_role.kinesis_firehose_opensearch.arn
}


output "kinesis_firehose_stream_name" {
  description = "The name of the Kinesis stream receiving CloudTrail logs"
  value       = aws_kinesis_stream.cloudtrail.name
}

output "kinesis_firehose_stream_arn" {
  description = "The ARN of the Kinesis stream"
  value       = aws_kinesis_stream.cloudtrail.arn
}

# Lambda Configuration Outputs
output "lambda_function_name" {
  description = "The name of the Lambda function transforming CloudTrail logs"
  value       = aws_lambda_function.cloudtrail_processor.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.cloudtrail_processor.arn
}

# VPC Configuration Outputs
output "vpc_security_group_id" {
  description = "The ID of the security group used for OpenSearch VPC access"
  value       = aws_security_group.opensearch.id
}

# Monitoring URLs
output "cloudwatch_monitoring_url" {
  description = "URL for CloudWatch monitoring dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=genomic-cloudtrail-${var.aws_account_id_destination}"
}

output "opensearch_dashboard_url" {
  description = "URL for OpenSearch Dashboards access"
  value       = "https://${aws_opensearch_domain.cloudtrail.dashboard_endpoint}/_dashboards"
}

# Configuration Summary
output "configuration_summary" {
  description = "Summary of key configuration parameters"
  value = {
    region             = var.aws_region
    environment        = var.environment[local.env]
    opensearch_version = aws_opensearch_domain.cloudtrail.engine_version
    instance_type      = var.opensearch_instance_type
    instance_count     = var.opensearch_instance_count
    volume_size        = var.opensearch_volume_size
    retention_period   = var.log_retention_days
    encryption_enabled = true
    vpc_enabled        = true
  }
}

output "opensearch_credentials" {
  description = "OpenSearch access credentials"
  value = {
    username               = var.opensearch_master_user
    password               = var.opensearch_master_password != null ? "Using provided password" : "Using generated password"
    password_ssm_parameter = aws_ssm_parameter.opensearch_master_password.name
  }
  sensitive = true
}

# Separate outputs for easy access
output "opensearch_master_user" {
  description = "OpenSearch master username"
  value       = var.opensearch_master_user
}

output "opensearch_password_parameter" {
  description = "SSM Parameter name storing the OpenSearch master password"
  value       = aws_ssm_parameter.opensearch_master_password.name
}

# Command output to help users retrieve the password
output "password_retrieval_command" {
  description = "AWS CLI command to retrieve the OpenSearch password"
  value       = "aws ssm get-parameter --name ${aws_ssm_parameter.opensearch_master_password.name} --with-decryption --query Parameter.Value --output text"
}

output "opensearch_monitoring_url" {
  description = "URL for OpenSearch monitoring dashboard"
  value       = "https://${aws_opensearch_domain.cloudtrail.endpoint}/_dashboards/app/opensearch_dashboards#/dashboard/cloudtrail-monitoring"
}

output "metrics_url" {
  description = "URL for CloudWatch metrics"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#metricsV2:graph=~()`"
}

output "log_group_url" {
  description = "URL for CloudWatch log group"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${urlencode(aws_cloudwatch_log_group.cloudtrail.name)}"
}

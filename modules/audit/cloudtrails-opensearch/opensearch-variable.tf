# Additional Variables
variable "opensearch_instance_type" {
  description = "Instance type for OpenSearch cluster"
  type        = string
  default     = "m5.large.search"
}

variable "opensearch_instance_count" {
  description = "Number of instances in the OpenSearch cluster"
  type        = number
  default     = 3
}

variable "opensearch_volume_size" {
  description = "Size in GB of EBS volume per instance"
  type        = number
  default     = 100
}

variable "opensearch_master_user" {
  description = "Master username for OpenSearch domain"
  type        = string
  default     = "genomic_admin"
}

variable "opensearch_master_email" {
  description = "Master email for OpenSearch domain"
  type        = string
  default     = "genomic_admin@gxc.com"
}

variable "opensearch_master_password" {
  description = "Master password for OpenSearch domain. If not provided, a random password will be generated"
  type        = string
  default     = null
  sensitive   = true
}

# NEW: Batching configuration variables
variable "opensearch_batch_size" {
  description = "Maximum number of documents per batch for OpenSearch indexing"
  type        = number
  default     = 500

  validation {
    condition     = var.opensearch_batch_size > 0 && var.opensearch_batch_size <= 5000
    error_message = "Batch size must be between 1 and 5000 documents."
  }
}

variable "opensearch_max_request_size_mb" {
  description = "Maximum request payload size in MB for OpenSearch bulk indexing"
  type        = number
  default     = 30

  validation {
    condition     = var.opensearch_max_request_size_mb > 0 && var.opensearch_max_request_size_mb <= 100
    error_message = "Maximum request size must be between 1 and 100 MB."
  }
}

# Environment-specific batch sizes
variable "opensearch_batch_sizes_by_env" {
  description = "Environment-specific batch sizes for different workloads"
  type        = map(number)
  default = {
    dev     = 250
    staging = 500
    prod    = 1000
  }
}

# Lambda configuration variables
variable "lambda_timeout_seconds" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 900  # 15 minutes

  validation {
    condition     = var.lambda_timeout_seconds >= 60 && var.lambda_timeout_seconds <= 900
    error_message = "Lambda timeout must be between 60 and 900 seconds."
  }
}

variable "lambda_memory_size" {
  description = "Lambda function memory allocation in MB"
  type        = number
  default     = 3008

  validation {
    condition = contains([
      128, 256, 512, 1024, 1536, 2048, 2560, 3008
    ], var.lambda_memory_size)
    error_message = "Lambda memory size must be a valid value (128, 256, 512, 1024, 1536, 2048, 2560, 3008)."
  }
}

variable "lambda_reserved_concurrency" {
  description = "Reserved concurrency for Lambda function to prevent overwhelming OpenSearch"
  type        = number
  default     = 10

  validation {
    condition     = var.lambda_reserved_concurrency > 0 && var.lambda_reserved_concurrency <= 100
    error_message = "Reserved concurrency must be between 1 and 100."
  }
}

# Monitoring and alerting configuration
variable "enable_enhanced_monitoring" {
  description = "Enable enhanced CloudWatch monitoring and alarms"
  type        = bool
  default     = true
}

variable "dlq_retention_days" {
  description = "Number of days to retain messages in the Dead Letter Queue"
  type        = number
  default     = 14

  validation {
    condition     = var.dlq_retention_days >= 1 && var.dlq_retention_days <= 14
    error_message = "DLQ retention must be between 1 and 14 days."
  }
}

# Performance tuning variables
variable "enable_kinesis_enhanced_fanout" {
  description = "Enable enhanced fan-out for Kinesis consumers"
  type        = bool
  default     = false
}

variable "kinesis_shard_count" {
  description = "Number of shards for Kinesis stream"
  type        = number
  default     = 2

  validation {
    condition     = var.kinesis_shard_count >= 1 && var.kinesis_shard_count <= 100
    error_message = "Kinesis shard count must be between 1 and 100."
  }
}

# Existing variables continue...
variable "private_subnet_ids" {
  description = "List of private subnet IDs for VPC deployment"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 private subnet IDs are required for high availability."
  }
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for OpenSearch deployment"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnet IDs are required for high availability."
  }
}

variable "vpc_id" {
  description = "VPC ID for OpenSearch deployment"
  type        = string
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access OpenSearch"
  type        = list(string)
  default     = []
}

variable "saml_metadata_content" {
  description = "SAML metadata XML content from your identity provider"
  type        = string
  sensitive   = true
  default     = null
}

variable "saml_master_user_name" {
  description = "SAML master user name"
  type        = string
  default     = "saml/AWSReservedSSO_AdministratorAccess"
}

variable "saml_master_backend_role" {
  description = "SAML master backend role ARN"
  type        = string
  default     = null
}

variable "cognito_users" {
  description = "List of users to create in Cognito"
  type = list(object({
    username   = string
    password   = string
    groups     = list(string)
    attributes = map(string)
  }))
  default = [
    {
      username = "admin@example.com"
      password = "InitialPassword123!"
      groups   = ["Administrators"]
      attributes = {
        email          = "admin@example.com"
        email_verified = "true"
      }
    }
  ]
  sensitive = true
}
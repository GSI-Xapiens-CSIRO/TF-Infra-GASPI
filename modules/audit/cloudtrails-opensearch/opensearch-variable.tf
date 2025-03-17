# Additional Variables
variable "opensearch_instance_type" {
  description = "Instance type for OpenSearch cluster"
  type        = string
  default     = "m6g.large.search"
}

variable "opensearch_instance_count" {
  description = "Number of instances in the OpenSearch cluster"
  type        = number
  default     = 2
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
  default     = [] # You should provide your IP addresses when calling the module
}

variable "saml_metadata_content" {
  description = "SAML metadata XML content from your identity provider"
  type        = string
  sensitive   = true
  default     = null
}

variable "saml_master_user_name" {
  description = "SAML master user name (typically in the format 'saml/AWSReservedSSO_RoleName_Hash')"
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
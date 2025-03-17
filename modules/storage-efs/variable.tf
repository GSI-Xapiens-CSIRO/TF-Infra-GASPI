# ==========================================================================
#  Module Storage EFS: variable.tf
# --------------------------------------------------------------------------
#  Description:
#    EFS Storage Variable
# --------------------------------------------------------------------------
#    - AWS Region
#    - AWS Account ID
#    - AWS Account Profile
#    - Workspace ID
#    - Workspace Environment
#    - Global Tags
# ==========================================================================

# --------------------------------------------------------------------------
#  KMS Key & Environment
# --------------------------------------------------------------------------
variable "kms_key" {
  description = "KMS Key References"
  type        = map(string)
}

variable "kms_env" {
  description = "KMS Key Environment"
  type        = map(string)
}

# --------------------------------------------------------------------------
#  AWS
# --------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_account_id_source" {
  description = "The AWS Account ID management"
  type        = string
}

variable "aws_account_id_destination" {
  description = "The AWS Account ID to deploy the Budget in"
  type        = string
}

variable "aws_account_profile_source" {
  description = "AWS Profile source to manage AWS resources"
  type        = string
}

variable "aws_account_profile_destination" {
  description = "AWS Profile destination to manage AWS resources"
  type        = string
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  default     = ""
}

# --------------------------------------------------------------------------
#  Workspace
# --------------------------------------------------------------------------
variable "workspace_name" {
  description = "Workspace Environment Name"
  type        = string
}

variable "workspace_env" {
  description = "Workspace Environment Selection"
  type        = map(string)
}

# --------------------------------------------------------------------------
#  Environment Resources Tags
# --------------------------------------------------------------------------
variable "environment" {
  description = "Target Environment (tags)"
  type        = map(string)
}

# --------------------------------------------------------------------------
#  Department Tags
# --------------------------------------------------------------------------
variable "department" {
  description = "Department Owner"
  type        = string
}

# --------------------------------------------------------------------------
#  Global Prefix Name
# --------------------------------------------------------------------------
variable "prefix_name" {
  description = "Global Prefix Name"
  type        = string
}

# --------------------------------------------------------------------------
#  VPC
# --------------------------------------------------------------------------
variable "vpc_id" {
  description = "VPC ID where EFS will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for mount targets"
  type        = list(string)
}

# --------------------------------------------------------------------------
#  EFS Configuration
# --------------------------------------------------------------------------
variable "performance_mode" {
  description = "Performance mode of the file system (generalPurpose or maxIO)"
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Performance mode must be either 'generalPurpose' or 'maxIO'."
  }
}

variable "throughput_mode" {
  description = "Throughput mode of the file system (bursting, provisioned, or elastic)"
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned", "elastic"], var.throughput_mode)
    error_message = "Throughput mode must be one of: bursting, provisioned, or elastic."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = "Provisioned throughput in MiB/s (required if throughput_mode is provisioned)"
  type        = number
  default     = null
}

variable "transition_to_ia" {
  description = "Lifecycle policy transition to IA (AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, or AFTER_90_DAYS)"
  type        = string
  default     = null

  validation {
    condition = var.transition_to_ia == null ? true : contains([
      "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS"
    ], var.transition_to_ia)
    error_message = "transition_to_ia must be one of: AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, or AFTER_90_DAYS."
  }
}

variable "enable_backup" {
  description = "Enable EFS backup policy"
  type        = bool
  default     = true
}

# --------------------------------------------------------------------------
#  Access Point Configuration
# --------------------------------------------------------------------------
variable "create_access_point" {
  description = "Whether to create an access point"
  type        = bool
  default     = false
}

variable "access_point_path" {
  description = "Path for the access point root directory"
  type        = string
  default     = "data"
}

variable "access_point_uid" {
  description = "POSIX user ID for access point"
  type        = number
  default     = 1000
}

variable "access_point_gid" {
  description = "POSIX group ID for access point"
  type        = number
  default     = 1000
}

# --------------------------------------------------------------------------
#  Replication Configuration
# --------------------------------------------------------------------------
variable "enable_replication" {
  description = "Enable EFS replication"
  type        = bool
  default     = false
}

variable "replication_destination_region" {
  description = "Destination region for EFS replication"
  type        = string
  default     = null
}

variable "replication_kms_key_id" {
  description = "KMS key ID for replication destination"
  type        = string
  default     = null
}

# --------------------------------------------------------------------------
#  CloudWatch Alarm Thresholds
# --------------------------------------------------------------------------
variable "storage_bytes_threshold" {
  description = "The threshold for EFS storage usage in bytes"
  type        = number
  default     = 1000000000000  # 1TB
}

variable "io_limit_threshold" {
  description = "The threshold for EFS IO limit percentage"
  type        = number
  default     = 80  # 80%
}

variable "burst_credit_threshold" {
  description = "The threshold for EFS burst credit balance"
  type        = number
  default     = 60000000000  # 60GB
}

variable "client_connections_threshold" {
  description = "The threshold for number of client connections"
  type        = number
  default     = 100
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "create_dashboard" {
  description = "Whether to create a CloudWatch dashboard for EFS metrics"
  type        = bool
  default     = true
}
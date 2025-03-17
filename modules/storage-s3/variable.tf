# ==========================================================================
#  Module Storage: variable.tf
# --------------------------------------------------------------------------
#  Description:
#    Global Variable
# --------------------------------------------------------------------------
#    - KMS Key ID
#    - KMS Key Environment
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
  description = "The AWS region"
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
  description = "The AWS Profile management"
  type        = string
}

variable "aws_account_profile_destination" {
  description = "The AWS Profile to deploy the Budget in"
  type        = string
}

variable "aws_access_key" {
  description = "The AWS Access Key"
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "The AWS Secret Key"
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
#  Storage Variables
# --------------------------------------------------------------------------
variable "allowed_role_arns" {
  description = "List of IAM role ARNs allowed to access the bucket"
  type        = list(string)
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "enable_notifications" {
  description = "Enable bucket notifications"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for notifications"
  type        = string
  default     = null
}

variable "enable_replication" {
  description = "Enable bucket replication"
  type        = bool
  default     = false
}

variable "replication_role_arn" {
  description = "ARN of IAM role for replication"
  type        = string
  default     = null
}

variable "destination_bucket_arn" {
  description = "ARN of destination bucket for replication"
  type        = string
  default     = null
}

variable "enable_object_lock" {
  description = "Enable S3 object lock"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "bucket_enable_lifecycle" {
  description = "Enable bucket lifecycle"
  type        = bool
  default     = false
}

variable "group_awscloud_developer" {
  description = "Name of the developer group"
  type        = string
}

variable "group_awscloud_administrator" {
  description = "Name of the administrator group"
  type        = string
}

variable "group_awscloud_billing" {
  description = "Name of the billing group"
  type        = string
}
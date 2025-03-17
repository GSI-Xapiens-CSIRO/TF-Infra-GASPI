variable "aws_region" {
  description = "The AWS region to deploy the CloudTrail in"
  type        = string
}

variable "aws_account_id_source" {
  description = "The AWS Account ID management"
  type        = string
}

variable "aws_account_id_destination" {
  description = "The AWS Account ID to deploy the CloudTrail in"
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
}

variable "aws_secret_key" {
  description = "The AWS Secret Key"
  type        = string
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

variable "log_retention_days" {
  description = "Number of days to retain CloudTrail logs"
  type        = number
  default     = 365
}

# --------------------------------------------------------------------------
#  KMS Key & Environment
# --------------------------------------------------------------------------
variable "kms_key" {
  type        = map(string)
  description = "KMS Key References"
}

variable "kms_env" {
  type        = map(string)
  description = "KMS Key Environment"
}
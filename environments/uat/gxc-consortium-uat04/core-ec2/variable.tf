# ==========================================================================
#  496940679572 - Core: variable.tf
# --------------------------------------------------------------------------
#  Description:
#    Global Variable
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
  type        = map(string)
  description = "KMS Key References"
  default = {
    default = "arn:aws:kms:ap-southeast-3:496940679572:key/HASH_NUMBER"
    lab     = "arn:aws:kms:ap-southeast-3:496940679572:key/HASH_NUMBER"
    staging = "arn:aws:kms:ap-southeast-3:496940679572:key/HASH_NUMBER"
    prod    = "arn:aws:kms:ap-southeast-3:496940679572:key/HASH_NUMBER"
  }
}

variable "kms_env" {
  type        = map(string)
  description = "KMS Key Environment"
  default = {
    lab     = "RnD"
    staging = "Staging"
    nonprod = "NonProduction"
    prod    = "Production"
  }
}

# --------------------------------------------------------------------------
#  AWS
# --------------------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region to deploy the VPC certificate in"
  type        = string
  default     = "ap-southeast-3"
}

variable "aws_account_id_source" {
  description = "The AWS Account ID management"
  type        = string
  default     = "496940679572"
}

variable "aws_account_id_destination" {
  description = "The AWS Account ID to deploy the Budget in"
  type        = string
  default     = "496940679572"
}

variable "aws_account_profile_source" {
  description = "The AWS Profile management"
  type        = string
  default     = "GXC-TF-User-Executor-UAT04"
}

variable "aws_account_profile_destination" {
  description = "The AWS Profile to deploy the Budget in"
  type        = string
  default     = "GXC-TF-User-Executor-UAT04"
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
  default     = "default"
}

variable "workspace_env" {
  description = "Workspace Environment Selection"
  type        = map(string)
  default = {
    default = "default"
    lab     = "rnd"
    staging = "staging"
    nonprod = "nonprod"
    prod    = "prod"
  }
}

# --------------------------------------------------------------------------
#  Environment Resources Tags
# --------------------------------------------------------------------------
variable "environment" {
  description = "Target Environment (tags)"
  type        = map(string)
  default = {
    default = "DEF"
    lab     = "RND"
    staging = "STG"
    nonprod = "NONPROD"
    prod    = "PROD"
  }
}

# --------------------------------------------------------------------------
#  Department Tags
# --------------------------------------------------------------------------
variable "department" {
  description = "Department Owner"
  type        = string
  default     = "DEVOPS"
}

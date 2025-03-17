# ==========================================================================
#  Module S3 Logs: s3-logs-variable.tf
# --------------------------------------------------------------------------
#  Description:
#    S3 Logs Variable
# --------------------------------------------------------------------------
#    - Bucket Prefix
#    - Bucket Common Tags
#    - Bucket Retention Configuration
#    - Bucket Allowed Account IDs
# ==========================================================================

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "gxc-sbeacon-logs"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "retention_config" {
  description = "Log retention configuration for different log types"
  type = map(object({
    standard_ia_days = number
    glacier_days     = number
    expiration_days  = number
  }))
  default = {
    cloudfront = {
      standard_ia_days = 30
      glacier_days     = 90
      expiration_days  = 365
    }
    lambda = {
      standard_ia_days = 30
      glacier_days     = 90
      expiration_days  = 365
    }
    s3_access = {
      standard_ia_days = 30
      glacier_days     = 60
      expiration_days  = 180
    }
    dynamodb = {
      standard_ia_days = 45
      glacier_days     = 90
      expiration_days  = 730
    }
  }
}

variable "allowed_account_ids" {
  description = "List of AWS account IDs allowed to write logs"
  type = map(object({
    account_id = string
    name       = string
  }))
}
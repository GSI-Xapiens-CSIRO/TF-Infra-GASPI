# --------------------------------------------------------------------------
#  Global Prefix Name
# --------------------------------------------------------------------------
variable "prefix_name" {
  description = "Global Prefix Name"
  type        = string
  default     = "genomic-snapshot"
}

variable "allowed_role_arns" {
  description = "List of IAM role ARNs allowed to access the bucket"
  type        = list(string)
  default     = ["arn:aws:iam::938674806253:group/gxc-developer_938674806253_staging"]
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
  default     = "arn:aws:iam::938674806253:group/gxc-developer_938674806253_staging"
}

variable "destination_bucket_arn" {
  description = "ARN of destination bucket for replication"
  type        = string
  default     = null
}

variable "bucket_enable_lifecycle" {
  description = "Enable bucket lifecycle"
  type        = bool
  default     = true
}

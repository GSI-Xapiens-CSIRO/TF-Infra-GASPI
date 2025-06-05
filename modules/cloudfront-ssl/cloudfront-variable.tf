# ==========================================================================
#  Module CloudFront SSL: cloudfront-variable.tf
# --------------------------------------------------------------------------
#  Description:
#    CloudFront SSL Variable
# --------------------------------------------------------------------------
#    - Domain Configuration
#    - ALB Configuration
#    - CloudFront Configuration
#    - Certificate Configuration
# ==========================================================================

# --------------------------------------------------------------------------
#  Domain Configuration
# --------------------------------------------------------------------------
variable "domain_name" {
  description = "The custom domain name (e.g., app.example.com)"
  type        = string
}

variable "hosted_zone_name" {
  description = "The Route 53 hosted zone name (e.g., example.com)"
  type        = string
}

# --------------------------------------------------------------------------
#  Infrastructure Configuration
# --------------------------------------------------------------------------
variable "vpc_id" {
  description = "ID of the VPC where resources will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Application Load Balancer"
  type        = list(string)
}

# --------------------------------------------------------------------------
#  ALB Configuration
# --------------------------------------------------------------------------
variable "alb_internal" {
  description = "Boolean to determine if the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "alb_target_group_port" {
  description = "Port for the ALB target group (where your application listens)"
  type        = number
  default     = 80
}

variable "alb_target_group_protocol" {
  description = "Protocol for the ALB target group"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Health check path for the ALB target group"
  type        = string
  default     = "/"
}

# --------------------------------------------------------------------------
#  CloudFront Configuration
# --------------------------------------------------------------------------
variable "cloudfront_price_class" {
  description = "CloudFront price class. Valid values: PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_100"
}

# --------------------------------------------------------------------------
#  Certificate Configuration
# --------------------------------------------------------------------------
variable "certificate_body_path" {
  description = "Path to the SSL certificate body file (cert.crt)"
  type        = string
}

variable "private_key_path" {
  description = "Path to the SSL certificate private key file (cert.key)"
  type        = string
}

variable "certificate_chain_path" {
  description = "Optional path to the SSL certificate chain file (chain.crt)"
  type        = string
  default     = null
}
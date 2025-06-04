# ==========================================================================
#  Module CloudFront SSL: cloudfront-variable.tf
# --------------------------------------------------------------------------
#  Description:
#    CloudFront SSL Variable for Existing CloudFront
# --------------------------------------------------------------------------
#    - Import Configuration
#    - Domain Configuration
#    - ALB Configuration
#    - Separate Certificate ARNs
# ==========================================================================

# --------------------------------------------------------------------------
#  Import Configuration
# --------------------------------------------------------------------------
variable "import_existing_cloudfront" {
  description = "Whether to import existing CloudFront distribution"
  type        = bool
  default     = true
}

variable "existing_cloudfront_distribution_id" {
  description = "Existing CloudFront distribution ID to import/manage"
  type        = string
  default     = null
}

variable "create_new_cloudfront" {
  description = "Whether to create new CloudFront distribution"
  type        = bool
  default     = false
}

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
#  Route53 Configuration
# --------------------------------------------------------------------------
variable "create_alb_dns_record" {
  description = "Whether to create a separate DNS record for direct ALB access"
  type        = bool
  default     = false
}

# --------------------------------------------------------------------------
#  Infrastructure Configuration
# --------------------------------------------------------------------------
variable "vpc_id" {
  description = "ID of the VPC where ALB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Application Load Balancer"
  type        = list(string)
}

# --------------------------------------------------------------------------
#  ALB Configuration
# --------------------------------------------------------------------------
variable "create_alb" {
  description = "Whether to create ALB (set to false if you already have ALB)"
  type        = bool
  default     = true
}

variable "existing_alb_arn" {
  description = "Existing ALB ARN if not creating new ALB"
  type        = string
  default     = null
}

variable "existing_alb_dns_name" {
  description = "Existing ALB DNS name if not creating new ALB"
  type        = string
  default     = null
}

variable "alb_internal" {
  description = "Boolean to determine if the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "alb_target_group_port" {
  description = "Port for the ALB target group"
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
  description = "CloudFront price class (only used if creating new distribution)"
  type        = string
  default     = "PriceClass_100"
}

variable "update_cloudfront_origin" {
  description = "Whether to update CloudFront origin to point to new ALB"
  type        = bool
  default     = true
}

# --------------------------------------------------------------------------
#  Certificate Configuration (FIXED - Separate ALB and CloudFront)
# --------------------------------------------------------------------------
variable "create_certificate" {
  description = "Whether to create/import SSL certificate"
  type        = bool
  default     = true
}

# DEPRECATED: Use alb_existing_certificate_arn and cloudfront_existing_certificate_arn instead
variable "existing_certificate_arn" {
  description = "DEPRECATED: Use alb_existing_certificate_arn and cloudfront_existing_certificate_arn instead"
  type        = string
  default     = null
}

# NEW: Separate certificate ARNs for ALB and CloudFront
variable "alb_existing_certificate_arn" {
  description = "Existing ACM certificate ARN for ALB (must be in same region as ALB)"
  type        = string
  default     = null
}

variable "cloudfront_existing_certificate_arn" {
  description = "Existing ACM certificate ARN for CloudFront (must be in us-east-1)"
  type        = string
  default     = null
}

variable "search_certificate_by_domain" {
  description = "Search for certificate by domain name (fallback option)"
  type        = bool
  default     = false
}

variable "certificate_domain_override" {
  description = "Override domain name for certificate search (e.g., *.example.com)"
  type        = string
  default     = null
}

variable "certificate_body_path" {
  description = "Path to the SSL certificate body file (cert.crt)"
  type        = string
  default     = null
}

variable "private_key_path" {
  description = "Path to the SSL certificate private key file (cert.key)"
  type        = string
  default     = null
}

variable "certificate_chain_path" {
  description = "Optional path to the SSL certificate chain file (chain.crt)"
  type        = string
  default     = null
}
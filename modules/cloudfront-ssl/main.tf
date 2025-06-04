# ==========================================================================
#  Module CloudFront SSL: main.tf
# --------------------------------------------------------------------------
#  Description:
#    Main Terraform Module
# --------------------------------------------------------------------------
#    - Fixed certificate ARN logic
#    - Proper resource references
# ==========================================================================

# --------------------------------------------------------------------------
#  Workspace Environment
# --------------------------------------------------------------------------
locals {
  env = terraform.workspace
}

# --------------------------------------------------------------------------
#  Global Tags
# --------------------------------------------------------------------------
locals {
  tags = {
    Environment     = "${var.environment[local.env]}"
    Department      = "${var.department}"
    DepartmentGroup = "${var.environment[local.env]}-${var.department}"
    Terraform       = true
  }
}

# --------------------------------------------------------------------------
#  Data Sources
# --------------------------------------------------------------------------
data "aws_route53_zone" "selected" {
  provider = aws.destination

  name         = var.hosted_zone_name
  private_zone = false
}

# Data source for existing CloudFront distribution
data "aws_cloudfront_distribution" "existing" {
  count    = var.import_existing_cloudfront && var.existing_cloudfront_distribution_id != null ? 1 : 0
  provider = aws.destination
  id       = var.existing_cloudfront_distribution_id
}

# Data source for existing ALB
data "aws_lb" "existing" {
  count    = !var.create_alb && var.existing_alb_arn != null ? 1 : 0
  provider = aws.destination
  arn      = var.existing_alb_arn
}

# Search certificate by domain only (when needed)
data "aws_acm_certificate" "existing_by_domain" {
  count    = !var.create_certificate && var.search_certificate_by_domain ? 1 : 0
  provider = aws.destination

  domain      = var.certificate_domain_override != null ? var.certificate_domain_override : var.domain_name
  types       = ["AMAZON_ISSUED", "IMPORTED"]
  statuses    = ["ISSUED"]
  most_recent = true
}

# --------------------------------------------------------------------------
#  Locals for Resource References (FIXED)
# --------------------------------------------------------------------------
locals {
  # Use existing or new ALB
  alb_dns_name = var.create_alb ? (
    length(aws_lb.main) > 0 ? aws_lb.main[0].dns_name : null
  ) : var.existing_alb_dns_name

  alb_arn = var.create_alb ? (
    length(aws_lb.main) > 0 ? aws_lb.main[0].arn : null
  ) : var.existing_alb_arn

  alb_zone_id = var.create_alb ? (
    length(aws_lb.main) > 0 ? aws_lb.main[0].zone_id : null
  ) : (
    length(data.aws_lb.existing) > 0 ? data.aws_lb.existing[0].zone_id : null
  )

  # FIXED: Separate certificate ARNs for ALB and CloudFront
  alb_certificate_arn = var.create_certificate && var.create_alb ? (
    length(aws_acm_certificate.alb_cert) > 0 ? aws_acm_certificate.alb_cert[0].arn : null
  ) : coalesce(
    var.alb_existing_certificate_arn,
    var.existing_certificate_arn  # Fallback for backward compatibility
  )

  cloudfront_certificate_arn = var.create_certificate && (var.create_new_cloudfront || var.import_existing_cloudfront) ? (
    length(aws_acm_certificate.cloudfront_cert) > 0 ? aws_acm_certificate.cloudfront_cert[0].arn : null
  ) : coalesce(
    var.cloudfront_existing_certificate_arn,
    var.existing_certificate_arn  # Fallback for backward compatibility
  )

  # For backward compatibility, default to ALB certificate
  certificate_arn = local.alb_certificate_arn

  # CloudFront distribution reference - FIXED to use data source for existing
  cloudfront_distribution_id = var.import_existing_cloudfront ? (
    var.existing_cloudfront_distribution_id
  ) : (
    var.create_new_cloudfront && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].id : null
  )

  cloudfront_domain_name = var.import_existing_cloudfront ? (
    length(data.aws_cloudfront_distribution.existing) > 0 ? data.aws_cloudfront_distribution.existing[0].domain_name : null
  ) : (
    var.create_new_cloudfront && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].domain_name : null
  )

  cloudfront_hosted_zone_id = var.import_existing_cloudfront ? (
    length(data.aws_cloudfront_distribution.existing) > 0 ? data.aws_cloudfront_distribution.existing[0].hosted_zone_id : null
  ) : (
    var.create_new_cloudfront && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].hosted_zone_id : null
  )
}
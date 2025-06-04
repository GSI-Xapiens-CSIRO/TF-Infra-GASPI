# ==========================================================================
#  Module CloudFront SSL: route53.tf
# --------------------------------------------------------------------------
#  Description
#    Route53 DNS Record
# --------------------------------------------------------------------------
#    - A Record for CloudFront (Conditional)
#    - Use data source for existing CloudFront
# ==========================================================================

# --------------------------------------------------------------------------
#  Route 53 Record (Only if managing CloudFront)
# --------------------------------------------------------------------------
resource "aws_route53_record" "cdn" {
  count    = var.import_existing_cloudfront || var.create_new_cloudfront ? 1 : 0
  provider = aws.destination

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name = var.import_existing_cloudfront ? (
      length(data.aws_cloudfront_distribution.existing) > 0 ? data.aws_cloudfront_distribution.existing[0].domain_name : ""
    ) : (
      var.create_new_cloudfront && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].domain_name : ""
    )

    zone_id = var.import_existing_cloudfront ? (
      length(data.aws_cloudfront_distribution.existing) > 0 ? data.aws_cloudfront_distribution.existing[0].hosted_zone_id : ""
    ) : (
      var.create_new_cloudfront && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].hosted_zone_id : ""
    )

    evaluate_target_health = true
  }

  # Only create if we're not using an existing record
  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------------------------
#  Route 53 Record for ALB Direct Access (Optional)
# --------------------------------------------------------------------------
resource "aws_route53_record" "alb_direct" {
  count    = var.create_alb && var.create_alb_dns_record ? 1 : 0
  provider = aws.destination

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "alb-${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main[0].dns_name
    zone_id                = aws_lb.main[0].zone_id
    evaluate_target_health = true
  }
}
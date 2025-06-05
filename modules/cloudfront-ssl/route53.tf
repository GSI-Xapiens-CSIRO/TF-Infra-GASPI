# ==========================================================================
#  Module CloudFront SSL: route53.tf
# --------------------------------------------------------------------------
#  Description
#    Route53 DNS Record
# --------------------------------------------------------------------------
#    - A Record for CloudFront
# ==========================================================================

# --------------------------------------------------------------------------
#  Route 53 Record
# --------------------------------------------------------------------------
resource "aws_route53_record" "cdn" {
  provider = aws.destination

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
}
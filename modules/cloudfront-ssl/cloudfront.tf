# ==========================================================================
#  Module CloudFront SSL: cloudfront.tf
# --------------------------------------------------------------------------
#  Description
#    CloudFront Distribution Management
# --------------------------------------------------------------------------
#    - Create New CloudFront (Optional)
# ==========================================================================

# --------------------------------------------------------------------------
#  NOTE: For existing CloudFront distributions, use data source only
#  Remove the resource block to avoid CNAME conflicts
# --------------------------------------------------------------------------

# --------------------------------------------------------------------------
#  Create New CloudFront Distribution (Optional)
# --------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "main" {
  count    = var.create_new_cloudfront ? 1 : 0
  provider = aws.destination

  origin {
    domain_name = local.alb_dns_name
    origin_id   = "ALB-${var.domain_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "New CloudFront distribution for ${var.domain_name}"
  default_root_object = "index.html"

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-${var.domain_name}"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["Authorization", "CloudFront-Forwarded-Proto"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.cloudfront_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = merge(
    local.tags,
    {
      Name     = "${var.domain_name}-cloudfront-new"
      Services = "CloudFront"
    }
  )
}
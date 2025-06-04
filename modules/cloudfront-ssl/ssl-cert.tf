# ==========================================================================
#  Module CloudFront SSL: ssl-cert.tf
# --------------------------------------------------------------------------
#  Description
#    SSL Certificate Management (Conditional)
# --------------------------------------------------------------------------
#    - Create/Import Certificate if needed
#    - Use Existing Certificate
#    - Separate certificates for ALB and CloudFront
# ==========================================================================

# --------------------------------------------------------------------------
#  ALB Certificate (Regional)
# --------------------------------------------------------------------------
resource "aws_acm_certificate" "alb_cert" {
  count    = var.create_certificate && var.create_alb ? 1 : 0
  provider = aws.destination  # Regional certificate for ALB

  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.hosted_zone_name}"
  ]

  tags = merge(
    local.tags,
    {
      Name     = "${var.domain_name}-alb-certificate"
      Services = "ACM-ALB"
      Region   = var.aws_region
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------------------------
#  CloudFront Certificate (us-east-1)
# --------------------------------------------------------------------------
resource "aws_acm_certificate" "cloudfront_cert" {
  count    = var.create_certificate && (var.create_new_cloudfront || var.import_existing_cloudfront) ? 1 : 0
  provider = aws.us_east_1  # CloudFront requires us-east-1

  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.hosted_zone_name}"
  ]

  tags = merge(
    local.tags,
    {
      Name     = "${var.domain_name}-cloudfront-certificate"
      Services = "ACM-CloudFront"
      Region   = "us-east-1"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------------------------
#  DNS Validation for ALB Certificate
# --------------------------------------------------------------------------
resource "aws_route53_record" "alb_cert_validation" {
  for_each = var.create_certificate && var.create_alb ? {
    for dvo in aws_acm_certificate.alb_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  provider = aws.destination

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# --------------------------------------------------------------------------
#  DNS Validation for CloudFront Certificate
# --------------------------------------------------------------------------
resource "aws_route53_record" "cloudfront_cert_validation" {
  for_each = var.create_certificate && (var.create_new_cloudfront || var.import_existing_cloudfront) ? {
    for dvo in aws_acm_certificate.cloudfront_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  provider = aws.destination

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# --------------------------------------------------------------------------
#  Certificate Validations
# --------------------------------------------------------------------------
resource "aws_acm_certificate_validation" "alb_cert" {
  count    = var.create_certificate && var.create_alb ? 1 : 0
  provider = aws.destination

  certificate_arn         = aws_acm_certificate.alb_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}

resource "aws_acm_certificate_validation" "cloudfront_cert" {
  count    = var.create_certificate && (var.create_new_cloudfront || var.import_existing_cloudfront) ? 1 : 0
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.cloudfront_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}
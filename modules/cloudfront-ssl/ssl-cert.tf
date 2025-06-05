# ==========================================================================
#  Module CloudFront SSL: ssl-cert.tf
# --------------------------------------------------------------------------
#  Description
#    SSL Certificate Management
# --------------------------------------------------------------------------
#    - ACM Certificate Import
# ==========================================================================

# --------------------------------------------------------------------------
#  SSL Certificate
# --------------------------------------------------------------------------
resource "aws_acm_certificate" "cert" {
  provider = aws.destination

  private_key       = file(var.private_key_path)
  certificate_body  = file(var.certificate_body_path)
  certificate_chain = var.certificate_chain_path != null ? file(var.certificate_chain_path) : null

  tags = merge(
    local.tags,
    {
      Name     = "${var.domain_name}-certificate"
      Services = "ACM"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
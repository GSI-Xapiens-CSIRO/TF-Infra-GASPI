# ==========================================================================
#  Module CloudFront SSL: output.tf
# --------------------------------------------------------------------------
#  Description
#    Output Terraform Value
# --------------------------------------------------------------------------
#    - CloudFront Distribution
#    - Application Load Balancer
#    - Security Groups
#    - SSL Certificate
#    - Route53 Records
#    - Summary
# ==========================================================================

# --------------------------------------------------------------------------
#  CloudFront Distribution
# --------------------------------------------------------------------------
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution (e.g., d111111abcdef8.cloudfront.net)"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The CloudFront distribution hosted zone ID"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

# --------------------------------------------------------------------------
#  Application Load Balancer
# --------------------------------------------------------------------------
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_listener_https_arn" {
  description = "ARN of the ALB HTTPS Listener"
  value       = aws_lb_listener.https.arn
}

output "alb_listener_http_arn" {
  description = "ARN of the ALB HTTP Listener (redirect)"
  value       = aws_lb_listener.http_redirect.arn
}

output "alb_target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.main.arn
}

output "alb_target_group_name" {
  description = "Name of the ALB Target Group"
  value       = aws_lb_target_group.main.name
}

# --------------------------------------------------------------------------
#  Security Groups
# --------------------------------------------------------------------------
output "alb_security_group_id" {
  description = "ID of the ALB Security Group"
  value       = aws_security_group.alb_sg.id
}

output "alb_security_group_arn" {
  description = "ARN of the ALB Security Group"
  value       = aws_security_group.alb_sg.arn
}

output "app_security_group_id" {
  description = "ID of the Application Security Group"
  value       = aws_security_group.app_sg.id
}

output "app_security_group_arn" {
  description = "ARN of the Application Security Group"
  value       = aws_security_group.app_sg.arn
}

# --------------------------------------------------------------------------
#  SSL Certificate
# --------------------------------------------------------------------------
output "acm_certificate_arn" {
  description = "ARN of the ACM certificate created/imported"
  value       = aws_acm_certificate.cert.arn
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = aws_acm_certificate.cert.domain_name
}

# --------------------------------------------------------------------------
#  Route53 Records
# --------------------------------------------------------------------------
output "route53_record_name" {
  description = "The name of the Route 53 record"
  value       = aws_route53_record.cdn.name
}

output "route53_record_fqdn" {
  description = "The FQDN of the created Route 53 record"
  value       = aws_route53_record.cdn.fqdn
}

output "route53_hosted_zone_id" {
  description = "The hosted zone ID used for Route 53 record"
  value       = data.aws_route53_zone.selected.zone_id
}

# --------------------------------------------------------------------------
#  Summary
# --------------------------------------------------------------------------
locals {
  summary = <<SUMMARY
CloudFront SSL Configuration:
  Domain Name:           ${var.domain_name}
  Hosted Zone:           ${var.hosted_zone_name}

CloudFront Distribution:
  Distribution ID:       ${aws_cloudfront_distribution.main.id}
  Domain Name:           ${aws_cloudfront_distribution.main.domain_name}
  Distribution ARN:      ${aws_cloudfront_distribution.main.arn}
  Price Class:           ${var.cloudfront_price_class}

Application Load Balancer:
  ALB DNS Name:          ${aws_lb.main.dns_name}
  ALB ARN:               ${aws_lb.main.arn}
  Target Group ARN:      ${aws_lb_target_group.main.arn}
  Target Port:           ${var.alb_target_group_port}
  Target Protocol:       ${var.alb_target_group_protocol}

Security Groups:
  ALB Security Group:    ${aws_security_group.alb_sg.id}
  App Security Group:    ${aws_security_group.app_sg.id}

SSL Certificate:
  Certificate ARN:       ${aws_acm_certificate.cert.arn}
  Certificate Domain:    ${aws_acm_certificate.cert.domain_name}

Route53:
  Record FQDN:           ${aws_route53_record.cdn.fqdn}
  Hosted Zone ID:        ${data.aws_route53_zone.selected.zone_id}

Access URLs:
  Primary Domain:        https://${var.domain_name}
  CloudFront URL:        https://${aws_cloudfront_distribution.main.domain_name}
  ALB Direct URL:        https://${aws_lb.main.dns_name}
SUMMARY
}

output "summary" {
  description = "Summary of CloudFront SSL Configuration"
  value       = local.summary
}
# ==========================================================================
#  Module CloudFront SSL: output.tf
# --------------------------------------------------------------------------
#  Description
#    Output Terraform Value (Conditional)
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
  value = var.import_existing_cloudfront ? (
    var.existing_cloudfront_distribution_id
    ) : (
    var.create_new_cloudfront && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].id : null
  )
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value = var.import_existing_cloudfront ? (
    length(data.aws_cloudfront_distribution.existing) > 0 ? data.aws_cloudfront_distribution.existing[0].domain_name : null
    ) : (
    var.create_new_cloudfront && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].domain_name : null
  )
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value = var.import_existing_cloudfront ? (
    length(data.aws_cloudfront_distribution.existing) > 0 ? data.aws_cloudfront_distribution.existing[0].arn : null
    ) : (
    var.create_new_cloudfront && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].arn : null
  )
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The CloudFront distribution hosted zone ID"
  value = var.import_existing_cloudfront ? (
    length(data.aws_cloudfront_distribution.existing) > 0 ? data.aws_cloudfront_distribution.existing[0].hosted_zone_id : null
    ) : (
    var.create_new_cloudfront && length(aws_cloudfront_distribution.main) > 0 ? aws_cloudfront_distribution.main[0].hosted_zone_id : null
  )
}

# --------------------------------------------------------------------------
#  Application Load Balancer
# --------------------------------------------------------------------------
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value = var.create_alb ? (
    length(aws_lb.main) > 0 ? aws_lb.main[0].dns_name : null
  ) : var.existing_alb_dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the Application Load Balancer"
  value = var.create_alb ? (
    length(aws_lb.main) > 0 ? aws_lb.main[0].zone_id : null
    ) : (
    length(data.aws_lb.existing) > 0 ? data.aws_lb.existing[0].zone_id : null
  )
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value = var.create_alb ? (
    length(aws_lb.main) > 0 ? aws_lb.main[0].arn : null
  ) : var.existing_alb_arn
}

output "alb_listener_https_arn" {
  description = "ARN of the ALB HTTPS Listener"
  value       = var.create_alb && length(aws_lb_listener.https) > 0 ? aws_lb_listener.https[0].arn : null
}

output "alb_listener_http_arn" {
  description = "ARN of the ALB HTTP Listener (redirect)"
  value       = var.create_alb && length(aws_lb_listener.http_redirect) > 0 ? aws_lb_listener.http_redirect[0].arn : null
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
  value       = var.create_alb && length(aws_security_group.alb_sg) > 0 ? aws_security_group.alb_sg[0].id : null
}

output "alb_security_group_arn" {
  description = "ARN of the ALB Security Group"
  value       = var.create_alb && length(aws_security_group.alb_sg) > 0 ? aws_security_group.alb_sg[0].arn : null
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
#  SSL Certificate (FIXED - Separate ALB and CloudFront certificates)
# --------------------------------------------------------------------------
output "acm_certificate_arn" {
  description = "ARN of the ACM certificate (ALB certificate)"
  value       = local.alb_certificate_arn
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = var.domain_name
}

output "cloudfront_certificate_arn" {
  description = "ARN of the CloudFront ACM certificate (us-east-1)"
  value       = local.cloudfront_certificate_arn
}

output "alb_certificate_arn" {
  description = "ARN of the ALB ACM certificate (regional)"
  value       = local.alb_certificate_arn
}

# --------------------------------------------------------------------------
#  Route53 Records
# --------------------------------------------------------------------------
output "route53_record_name" {
  description = "The name of the Route 53 record"
  value       = length(aws_route53_record.cdn) > 0 ? aws_route53_record.cdn[0].name : null
}

output "route53_record_fqdn" {
  description = "The FQDN of the created Route 53 record"
  value       = length(aws_route53_record.cdn) > 0 ? aws_route53_record.cdn[0].fqdn : null
}

output "route53_hosted_zone_id" {
  description = "The hosted zone ID used for Route 53 record"
  value       = data.aws_route53_zone.selected.zone_id
}

# --------------------------------------------------------------------------
#  Resource Status
# --------------------------------------------------------------------------
output "resource_status" {
  description = "Status of created resources"
  value = {
    cloudfront_managed             = var.import_existing_cloudfront || var.create_new_cloudfront
    cloudfront_imported            = var.import_existing_cloudfront
    cloudfront_created             = var.create_new_cloudfront
    alb_created                    = var.create_alb
    alb_certificate_created        = var.create_certificate && var.create_alb
    cloudfront_certificate_created = var.create_certificate && (var.create_new_cloudfront || var.import_existing_cloudfront)
    using_existing_alb_cert        = !var.create_certificate && var.alb_existing_certificate_arn != null
    using_existing_cloudfront_cert = !var.create_certificate && var.cloudfront_existing_certificate_arn != null
  }
}

# --------------------------------------------------------------------------
#  Summary (FIXED)
# --------------------------------------------------------------------------
locals {
  summary = <<SUMMARY
CloudFront SSL Configuration:
  Domain Name:            ${var.domain_name}
  Hosted Zone:            ${var.hosted_zone_name}

CloudFront Distribution:
  Management:             ${var.import_existing_cloudfront ? "Using Existing (Data Source)" : (var.create_new_cloudfront ? "Created New" : "Not Managed")}
  Distribution ID:        ${local.cloudfront_distribution_id != null ? local.cloudfront_distribution_id : "N/A"}
  Domain Name:            ${local.cloudfront_domain_name != null ? local.cloudfront_domain_name : "N/A"}

Application Load Balancer:
  ALB Status:             ${var.create_alb ? "Created New" : "Using Existing"}
  ALB DNS Name:           ${local.alb_dns_name != null ? local.alb_dns_name : "N/A"}
  ALB ARN:                ${local.alb_arn != null ? local.alb_arn : "N/A"}
  Target Group ARN:       ${aws_lb_target_group.main.arn}
  Target Port:            ${var.alb_target_group_port}
  Target Protocol:        ${var.alb_target_group_protocol}

Security Groups:
  ALB Security Group:     ${var.create_alb && length(aws_security_group.alb_sg) > 0 ? aws_security_group.alb_sg[0].id : "Not Created"}
  App Security Group:     ${aws_security_group.app_sg.id}

SSL Certificates:
  ALB Certificate:        ${local.alb_certificate_arn != null ? local.alb_certificate_arn : "None"}
  CloudFront Certificate: ${local.cloudfront_certificate_arn != null ? local.cloudfront_certificate_arn : "None"}
  Certificate Status:     ${var.create_certificate ? "Created New" : "Using Existing"}

Route53:
  Record FQDN:            ${length(aws_route53_record.cdn) > 0 ? aws_route53_record.cdn[0].fqdn : "Not Created"}
  Hosted Zone ID:         ${data.aws_route53_zone.selected.zone_id}

Access URLs:
  Primary Domain:         https://${var.domain_name}
  CloudFront URL:         ${local.cloudfront_domain_name != null ? "https://${local.cloudfront_domain_name}" : "N/A"}
  ALB Direct URL:         ${local.alb_dns_name != null ? "https://${local.alb_dns_name}" : "N/A"}
SUMMARY
}

output "summary" {
  description = "Summary of CloudFront SSL Configuration"
  value       = local.summary
}

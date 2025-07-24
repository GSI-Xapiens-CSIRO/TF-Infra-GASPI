# ==========================================================================
#  Module Core: output.tf
# --------------------------------------------------------------------------
#  Description
#    Output Terraform Value - Enhanced for ML Security
# --------------------------------------------------------------------------
#    - Original VPC and EC2 Outputs
#    - ML Security Outputs (SageMaker, Firewall, VPC Endpoints)
#    - Security Group IDs
#    - Network Firewall Information
# ==========================================================================

# --------------------------------------------------------------------------
#  Original VPC Output
# --------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC Identity"
  value       = aws_vpc.infra_vpc.id
}

output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = aws_vpc.infra_vpc.cidr_block
}

output "vpc_name" {
  description = "VPC Name"
  value       = local.vps_tags.Name
}

output "security_group_id" {
  description = "Default Security Group of VPC Id's"
  value       = aws_security_group.default.id
}

# --------------------------------------------------------------------------
#  Original EC2 Output
# --------------------------------------------------------------------------
# EC2 Private
output "ec2_private_1a" {
  description = "Private Subnet EC2 Zone A"
  value       = aws_subnet.ec2_private_a.*.id
}

output "ec2_private_1a_cidr" {
  description = "Private Subnet EC2 CIDR Block of Zone A"
  value       = aws_subnet.ec2_private_a.cidr_block
}

output "ec2_private_1b" {
  description = "Private Subnet EC2 Zone B"
  value       = aws_subnet.ec2_private_b.*.id
}

output "ec2_private_1b_cidr" {
  description = "Private Subnet EC2 CIDR Block of Zone B"
  value       = aws_subnet.ec2_private_b.cidr_block
}

output "ec2_private_1c" {
  description = "Private Subnet EC2 Zone C"
  value       = aws_subnet.ec2_private_c.*.id
}

output "ec2_private_1c_cidr" {
  description = "Private Subnet EC2 CIDR Block of Zone C"
  value       = aws_subnet.ec2_private_c.cidr_block
}

# EC2 Public
output "ec2_public_1a" {
  description = "Public Subnet EC2 Zone A"
  value       = aws_subnet.ec2_public_a.*.id
}

output "ec2_public_1a_cidr" {
  description = "Public Subnet EC2 CIDR Block of Zone A"
  value       = aws_subnet.ec2_public_a.cidr_block
}

output "ec2_public_1b" {
  description = "Public Subnet EC2 Zone B"
  value       = aws_subnet.ec2_public_b.*.id
}

output "ec2_public_1b_cidr" {
  description = "Public Subnet EC2 CIDR Block of Zone B"
  value       = aws_subnet.ec2_public_b.cidr_block
}

output "ec2_public_1c" {
  description = "Public Subnet EC2 Zone C"
  value       = aws_subnet.ec2_public_c.*.id
}

output "ec2_public_1c_cidr" {
  description = "Public Subnet EC2 CIDR Block of Zone C"
  value       = aws_subnet.ec2_public_c.cidr_block
}

# --------------------------------------------------------------------------
#  ML Security Outputs - SageMaker Subnets
# --------------------------------------------------------------------------
output "sagemaker_private_1a" {
  description = "Private Subnet SageMaker Zone A"
  value       = var.enable_sagemaker_studio ? aws_subnet.sagemaker_private_a[0].id : null
}

output "sagemaker_private_1a_cidr" {
  description = "Private Subnet SageMaker CIDR Block of Zone A"
  value       = var.enable_sagemaker_studio ? aws_subnet.sagemaker_private_a[0].cidr_block : null
}

output "sagemaker_private_1b" {
  description = "Private Subnet SageMaker Zone B"
  value       = var.enable_sagemaker_studio ? aws_subnet.sagemaker_private_b[0].id : null
}

output "sagemaker_private_1b_cidr" {
  description = "Private Subnet SageMaker CIDR Block of Zone B"
  value       = var.enable_sagemaker_studio ? aws_subnet.sagemaker_private_b[0].cidr_block : null
}

output "sagemaker_private_1c" {
  description = "Private Subnet SageMaker Zone C"
  value       = var.enable_sagemaker_studio ? aws_subnet.sagemaker_private_c[0].id : null
}

output "sagemaker_private_1c_cidr" {
  description = "Private Subnet SageMaker CIDR Block of Zone C"
  value       = var.enable_sagemaker_studio ? aws_subnet.sagemaker_private_c[0].cidr_block : null
}

# --------------------------------------------------------------------------
#  ML Security Outputs - Network Firewall
# --------------------------------------------------------------------------
output "network_firewall_id" {
  description = "Network Firewall ID"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall.ml_security_firewall[0].id : null
}

output "network_firewall_arn" {
  description = "Network Firewall ARN"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall.ml_security_firewall[0].arn : null
}

output "firewall_policy_arn" {
  description = "Network Firewall Policy ARN"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall_policy.ml_security_policy[0].arn : null
}

output "firewall_endpoints" {
  description = "Network Firewall Endpoint IDs by AZ"
  value       = var.enable_network_firewall ? local.firewall_endpoints : {}
}

# --------------------------------------------------------------------------
#  ML Security Outputs - Firewall Subnets
# --------------------------------------------------------------------------
output "firewall_subnet_1a" {
  description = "Network Firewall Subnet Zone A"
  value       = var.enable_network_firewall ? aws_subnet.firewall_a[0].id : null
}

output "firewall_subnet_1b" {
  description = "Network Firewall Subnet Zone B"
  value       = var.enable_network_firewall ? aws_subnet.firewall_b[0].id : null
}

output "firewall_subnet_1c" {
  description = "Network Firewall Subnet Zone C"
  value       = var.enable_network_firewall ? aws_subnet.firewall_c[0].id : null
}

# --------------------------------------------------------------------------
#  ML Security Outputs - NAT Gateways
# --------------------------------------------------------------------------
output "ml_nat_gateway_1a" {
  description = "ML NAT Gateway Zone A"
  value       = var.enable_network_firewall ? aws_nat_gateway.ml_nat_a[0].id : null
}

output "ml_nat_gateway_1b" {
  description = "ML NAT Gateway Zone B"
  value       = var.enable_network_firewall ? aws_nat_gateway.ml_nat_b[0].id : null
}

output "ml_nat_gateway_1c" {
  description = "ML NAT Gateway Zone C"
  value       = var.enable_network_firewall ? aws_nat_gateway.ml_nat_c[0].id : null
}

# --------------------------------------------------------------------------
#  ML Security Outputs - Security Groups
# --------------------------------------------------------------------------
output "sagemaker_security_group_id" {
  description = "SageMaker Studio Security Group ID"
  value       = var.enable_sagemaker_studio ? aws_security_group.sagemaker_studio[0].id : null
}

output "vpc_endpoints_security_group_id" {
  description = "VPC Endpoints Security Group ID"
  value       = var.enable_sagemaker_studio ? aws_security_group.vpc_endpoints[0].id : null
}

output "ml_default_security_group_id" {
  description = "ML Default Security Group ID"
  value       = aws_security_group.ml_default.id
}

# --------------------------------------------------------------------------
#  ML Security Outputs - VPC Endpoints
# --------------------------------------------------------------------------
output "s3_gateway_endpoint_id" {
  description = "S3 Gateway Endpoint ID"
  value       = var.enable_sagemaker_studio ? aws_vpc_endpoint.s3_gateway[0].id : null
}

output "sagemaker_api_endpoint_id" {
  description = "SageMaker API Endpoint ID"
  value       = var.enable_sagemaker_studio ? aws_vpc_endpoint.sagemaker_api[0].id : null
}

output "sagemaker_runtime_endpoint_id" {
  description = "SageMaker Runtime Endpoint ID"
  value       = var.enable_sagemaker_studio ? aws_vpc_endpoint.sagemaker_runtime[0].id : null
}

output "sagemaker_studio_endpoint_id" {
  description = "SageMaker Studio Endpoint ID"
  value       = var.enable_sagemaker_studio ? aws_vpc_endpoint.sagemaker_studio[0].id : null
}

# --------------------------------------------------------------------------
#  ML Security Outputs - Logging
# --------------------------------------------------------------------------
output "firewall_alert_log_group" {
  description = "Network Firewall Alert Log Group Name"
  value       = var.enable_network_firewall ? aws_cloudwatch_log_group.firewall_alert_logs[0].name : null
}

output "firewall_flow_log_group" {
  description = "Network Firewall Flow Log Group Name"
  value       = var.enable_network_firewall ? aws_cloudwatch_log_group.firewall_flow_logs[0].name : null
}

# --------------------------------------------------------------------------
#  Enhanced Summary Output
# --------------------------------------------------------------------------
locals {
  summary = <<SUMMARY
VPC Summary:
  VPC Id:                    ${aws_vpc.infra_vpc.id}
  VPC CIDR:                  ${aws_vpc.infra_vpc.cidr_block}
  Default Security Group Id: ${aws_security_group.default.id}
  ML Default Security Group: ${aws_security_group.ml_default.id}

Traditional EC2 Infrastructure:
  EC2 Private Subnets:
    Zone A: ${aws_subnet.ec2_private_a.id} (${aws_subnet.ec2_private_a.cidr_block})
    Zone B: ${aws_subnet.ec2_private_b.id} (${aws_subnet.ec2_private_b.cidr_block})
    Zone C: ${aws_subnet.ec2_private_c.id} (${aws_subnet.ec2_private_c.cidr_block})
  EC2 Public Subnets:
    Zone A: ${aws_subnet.ec2_public_a.id} (${aws_subnet.ec2_public_a.cidr_block})
    Zone B: ${aws_subnet.ec2_public_b.id} (${aws_subnet.ec2_public_b.cidr_block})
    Zone C: ${aws_subnet.ec2_public_c.id} (${aws_subnet.ec2_public_c.cidr_block})

ML Security Infrastructure:
  Network Firewall Status:   ${var.enable_network_firewall ? "ENABLED" : "DISABLED"}
  SageMaker Studio Status:   ${var.enable_sagemaker_studio ? "ENABLED" : "DISABLED"}

${var.enable_sagemaker_studio ? "  SageMaker Private Subnets:" : "SageMaker Private Subnets:"}
${var.enable_sagemaker_studio ? "    Zone A: ${aws_subnet.sagemaker_private_a[0].id} (${aws_subnet.sagemaker_private_a[0].cidr_block})" : "    Zone A: N/A"}
${var.enable_sagemaker_studio ? "    Zone B: ${aws_subnet.sagemaker_private_b[0].id} (${aws_subnet.sagemaker_private_b[0].cidr_block})" : "    Zone B: N/A"}
${var.enable_sagemaker_studio ? "    Zone C: ${aws_subnet.sagemaker_private_c[0].id} (${aws_subnet.sagemaker_private_c[0].cidr_block})" : "    Zone C: N/A"}

${var.enable_network_firewall ? "  Network Firewall:" : ""}
${var.enable_network_firewall ? "    Firewall ID: ${aws_networkfirewall_firewall.ml_security_firewall[0].id}" : ""}
${var.enable_network_firewall ? "    Policy ARN:  ${aws_networkfirewall_firewall_policy.ml_security_policy[0].arn}" : ""}
${var.enable_network_firewall ? "    Alert Logs:  ${aws_cloudwatch_log_group.firewall_alert_logs[0].name}" : ""}
${var.enable_network_firewall ? "    Flow Logs:   ${aws_cloudwatch_log_group.firewall_flow_logs[0].name}" : ""}

${var.enable_network_firewall ? "  Firewall Subnets:" : ""}
${var.enable_network_firewall ? "    Zone A: ${aws_subnet.firewall_a[0].id} (${aws_subnet.firewall_a[0].cidr_block})" : ""}
${var.enable_network_firewall ? "    Zone B: ${aws_subnet.firewall_b[0].id} (${aws_subnet.firewall_b[0].cidr_block})" : ""}
${var.enable_network_firewall ? "    Zone C: ${aws_subnet.firewall_c[0].id} (${aws_subnet.firewall_c[0].cidr_block})" : ""}

${var.enable_network_firewall ? "  ML NAT Gateways:" : ""}
${var.enable_network_firewall ? "    Zone A: ${aws_nat_gateway.ml_nat_a[0].id}" : ""}
${var.enable_network_firewall ? "    Zone B: ${aws_nat_gateway.ml_nat_b[0].id}" : ""}
${var.enable_network_firewall ? "    Zone C: ${aws_nat_gateway.ml_nat_c[0].id}" : ""}

Data Protection Features:
  - Domain Allow/Block Lists: ${var.enable_network_firewall ? "ACTIVE" : "INACTIVE"}
  - IPS Rules for Data Leak Prevention: ${var.enable_network_firewall ? "ACTIVE" : "INACTIVE"}
  - Stateless Traffic Filtering: ${var.enable_network_firewall ? "ACTIVE" : "INACTIVE"}
  - VPC Endpoints for AWS Services: ${var.enable_sagemaker_studio ? "ACTIVE" : "INACTIVE"}
  - Restrictive Security Groups: ACTIVE
  - Comprehensive Logging: ${var.enable_network_firewall ? "ACTIVE" : "INACTIVE"}

Allowed Domains: ${join(", ", var.allowed_domains)}
Blocked Domains: ${join(", ", var.blocked_domains)}
SUMMARY
}

output "summary" {
  description = "Summary Core Infrastructure Configuration with ML Security"
  value       = local.summary
}

# --------------------------------------------------------------------------
#  Configuration Status Output
# --------------------------------------------------------------------------
output "ml_security_config" {
  description = "ML Security Configuration Status"
  value = {
    network_firewall_enabled = var.enable_network_firewall
    sagemaker_studio_enabled = var.enable_sagemaker_studio
    allowed_domains_count    = length(var.allowed_domains)
    blocked_domains_count    = length(var.blocked_domains)
    vpc_endpoints_count      = var.enable_sagemaker_studio ? 9 : 0
    security_level           = var.enable_network_firewall && var.enable_sagemaker_studio ? "HIGH" : "MEDIUM"
  }
}

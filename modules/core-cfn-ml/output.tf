# ==========================================================================
#  Module Core: output.tf
# --------------------------------------------------------------------------
#  Description
#    Module Outputs
# --------------------------------------------------------------------------
#    - VPC and Network Resources
#    - S3 Buckets and KMS Keys
#    - SageMaker Resources
#    - IAM Roles
# ==========================================================================

# --------------------------------------------------------------------------
#  VPC and Network Outputs
# --------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of VPC where SageMaker Studio will reside"
  value       = aws_vpc.infra_vpc.id
}

output "sagemaker_studio_subnet_id" {
  description = "The ID of the SageMaker subnet"
  value       = var.enable_sagemaker_studio ? aws_subnet.ml_sagemaker_studio_subnet[0].id : null
}

output "sagemaker_security_group_id" {
  description = "The ID the SageMaker security group"
  value       = var.enable_sagemaker_studio ? aws_security_group.ml_sagemaker_security_group[0].id : null
}

output "nat_gateway_subnet_cidr" {
  description = "NAT Gateway subnet CIDR"
  value       = var.enable_network_firewall ? var.nat_gateway_subnet_cidr[local.env] : null
}

output "igw_route_table_id" {
  description = "IGW route table ID"
  value       = var.enable_network_firewall ? aws_route_table.igw_ingress_route_table[0].id : null
}

output "nat_gateway_route_table_id" {
  description = "NAT Gateway route table ID"
  value       = var.enable_network_firewall ? aws_route_table.nat_gateway_route_table[0].id : null
}

# --------------------------------------------------------------------------
#  S3 and Storage Outputs
# --------------------------------------------------------------------------
output "data_bucket_name" {
  description = "Name of S3 bucket for data"
  value       = var.enable_sagemaker_studio ? local.data_bucket_name : null
}

output "model_bucket_name" {
  description = "Name of S3 bucket for models"
  value       = var.enable_sagemaker_studio ? local.model_bucket_name : null
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 VPC Endpoint"
  value       = var.enable_sagemaker_studio ? aws_vpc_endpoint.s3[0].id : null
}

output "kms_key_s3_buckets_arn" {
  description = "KMS key arn for data encryption in S3 buckets"
  value       = var.enable_sagemaker_studio ? aws_kms_key.s3_kms_key[0].arn : null
}

output "kms_key_ebs_arn" {
  description = "KMS key arn for SageMaker notebooks EBS encryption"
  value       = var.enable_sagemaker_studio ? aws_kms_key.sagemaker_kms_key[0].arn : null
}

# --------------------------------------------------------------------------
#  SageMaker Outputs
# --------------------------------------------------------------------------
output "sagemaker_studio_domain_id" {
  description = "SageMaker Studio domain id"
  value       = var.enable_sagemaker_studio ? aws_sagemaker_domain.sagemaker_studio_domain[0].id : null
}

output "sagemaker_execution_role_arn" {
  description = "IAM Execution role for SageMaker Studio and SageMaker notebooks"
  value       = var.enable_sagemaker_studio ? aws_iam_role.sagemaker_execution_role[0].arn : null
}

output "user_profile_name" {
  description = "SageMaker user profile name"
  value       = var.enable_sagemaker_studio ? aws_sagemaker_user_profile.sagemaker_user_profile[0].user_profile_name : null
}

# --------------------------------------------------------------------------
#  Network Firewall Outputs
# --------------------------------------------------------------------------
output "network_firewall_arn" {
  description = "Network Firewall ARN"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall.network_firewall[0].arn : null
}

output "network_firewall_endpoint_id" {
  description = "Network Firewall VPC Endpoint ID"
  value       = var.enable_network_firewall ? element(split(":", tolist(tolist(aws_networkfirewall_firewall.network_firewall[0].firewall_status[0].sync_states)[0].attachment)[0].endpoint_id), 1) : null
}

# --------------------------------------------------------------------------
#  VPC Additional Outputs
# --------------------------------------------------------------------------
output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = aws_vpc.infra_vpc.cidr_block
}

output "vpc_name" {
  description = "VPC Name"
  value       = aws_vpc.infra_vpc.tags.Name
}

# --------------------------------------------------------------------------
#  EC2 Subnet Outputs
# --------------------------------------------------------------------------
output "ec2_private_1a" {
  description = "Private Subnet EC2 Zone A"
  value       = aws_subnet.ec2_private_a.id
}

output "ec2_private_1a_cidr" {
  description = "Private Subnet EC2 CIDR Block of Zone A"
  value       = aws_subnet.ec2_private_a.cidr_block
}

output "ec2_private_1b" {
  description = "Private Subnet EC2 Zone B"
  value       = aws_subnet.ec2_private_b.id
}

output "ec2_private_1b_cidr" {
  description = "Private Subnet EC2 CIDR Block of Zone B"
  value       = aws_subnet.ec2_private_b.cidr_block
}

output "ec2_private_1c" {
  description = "Private Subnet EC2 Zone C"
  value       = aws_subnet.ec2_private_c.id
}

output "ec2_private_1c_cidr" {
  description = "Private Subnet EC2 CIDR Block of Zone C"
  value       = aws_subnet.ec2_private_c.cidr_block
}

output "ec2_public_1a" {
  description = "Public Subnet EC2 Zone A"
  value       = aws_subnet.ec2_public_a.id
}

output "ec2_public_1a_cidr" {
  description = "Public Subnet EC2 CIDR Block of Zone A"
  value       = aws_subnet.ec2_public_a.cidr_block
}

output "ec2_public_1b" {
  description = "Public Subnet EC2 Zone B"
  value       = aws_subnet.ec2_public_b.id
}

output "ec2_public_1b_cidr" {
  description = "Public Subnet EC2 CIDR Block of Zone B"
  value       = aws_subnet.ec2_public_b.cidr_block
}

output "ec2_public_1c" {
  description = "Public Subnet EC2 Zone C"
  value       = aws_subnet.ec2_public_c.id
}

output "ec2_public_1c_cidr" {
  description = "Public Subnet EC2 CIDR Block of Zone C"
  value       = aws_subnet.ec2_public_c.cidr_block
}

# --------------------------------------------------------------------------
#  SageMaker Subnet Outputs (Single AZ)
# --------------------------------------------------------------------------
output "sagemaker_private_1a" {
  description = "Private Subnet SageMaker Zone A"
  value       = var.enable_sagemaker_studio ? aws_subnet.ml_sagemaker_studio_subnet[0].id : null
}

output "sagemaker_private_1a_cidr" {
  description = "Private Subnet SageMaker CIDR Block of Zone A"
  value       = var.enable_sagemaker_studio ? aws_subnet.ml_sagemaker_studio_subnet[0].cidr_block : null
}

output "sagemaker_private_1b" {
  description = "Private Subnet SageMaker Zone B"
  value       = null
}

output "sagemaker_private_1b_cidr" {
  description = "Private Subnet SageMaker CIDR Block of Zone B"
  value       = null
}

output "sagemaker_private_1c" {
  description = "Private Subnet SageMaker Zone C"
  value       = null
}

output "sagemaker_private_1c_cidr" {
  description = "Private Subnet SageMaker CIDR Block of Zone C"
  value       = null
}

# --------------------------------------------------------------------------
#  Network Firewall Additional Outputs
# --------------------------------------------------------------------------
output "network_firewall_id" {
  description = "Network Firewall ID"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall.network_firewall[0].id : null
}

output "firewall_policy_arn" {
  description = "Network Firewall Policy ARN"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall_policy.network_firewall_policy[0].arn : null
}

output "icmp_block_rule_group_arn" {
  description = "ICMP Block Rule Group ARN"
  value       = var.enable_network_firewall ? aws_networkfirewall_rule_group.icmp_block_stateless[0].arn : null
}

output "firewall_endpoints" {
  description = "Network Firewall Endpoints Details by AZ"
  value = var.enable_network_firewall ? {
    for sync_state in aws_networkfirewall_firewall.network_firewall[0].firewall_status[0].sync_states :
    sync_state.availability_zone => {
      availability_zone = sync_state.availability_zone
      subnet_id         = sync_state.attachment[0].subnet_id
      endpoint_id       = element(split(":", sync_state.attachment[0].endpoint_id), 1)
      status            = "Ready"
    }
  } : {}
}

# --------------------------------------------------------------------------
#  Firewall Subnet Outputs (Multi-AZ)
# --------------------------------------------------------------------------
output "firewall_subnet_1a" {
  description = "Network Firewall Subnet Zone A"
  value       = var.enable_network_firewall ? aws_subnet.ml_firewall_subnet_a[0].id : null
}

output "firewall_subnet_1b" {
  description = "Network Firewall Subnet Zone B"
  value       = var.enable_network_firewall ? aws_subnet.ml_firewall_subnet_b[0].id : null
}

output "firewall_subnet_1c" {
  description = "Network Firewall Subnet Zone C"
  value       = var.enable_network_firewall ? aws_subnet.ml_firewall_subnet_c[0].id : null
}

# --------------------------------------------------------------------------
#  NAT Gateway Outputs (Single Zone A)
# --------------------------------------------------------------------------
output "ml_nat_gateway_1a" {
  description = "ML NAT Gateway Zone A"
  value       = var.enable_network_firewall ? aws_nat_gateway.nat_gateway[0].id : null
}

output "ml_nat_gateway_1b" {
  description = "ML NAT Gateway Zone B"
  value       = null
}

output "ml_nat_gateway_1c" {
  description = "ML NAT Gateway Zone C"
  value       = null
}

output "nat_gateway_subnet_1a" {
  description = "NAT Gateway Subnet Zone A"
  value       = var.enable_network_firewall ? aws_subnet.ml_gateway_subnet_a[0].id : null
}

output "nat_gateway_subnet_1b" {
  description = "NAT Gateway Subnet Zone B"
  value       = var.enable_network_firewall ? aws_subnet.ml_gateway_subnet_b[0].id : null
}

output "nat_gateway_subnet_1c" {
  description = "NAT Gateway Subnet Zone C"
  value       = var.enable_network_firewall ? aws_subnet.ml_gateway_subnet_c[0].id : null
}

output "ml_sagemaker_security_group_name" {
  description = "ML SageMaker Security Group Name"
  value       = var.enable_sagemaker_studio ? aws_security_group.ml_sagemaker_security_group[0].name : null
}

output "ml_vpc_endpoints_security_group_name" {
  description = "ML VPC Endpoints Security Group Name"
  value       = var.enable_sagemaker_studio ? aws_security_group.vpc_endpoints_security_group[0].name : null
}

output "ml_vpc_security_group_name" {
  description = "ML VPC Security Group Name"
  value       = aws_security_group.ml_vpc_security_group.name
}

output "ml_vpc_security_group_id" {
  description = "ML VPC Security Group ID"
  value       = aws_security_group.ml_vpc_security_group.id
}

# --------------------------------------------------------------------------
#  Security Group Outputs
# --------------------------------------------------------------------------
output "vpc_endpoints_security_group_id" {
  description = "VPC Endpoints Security Group ID"
  value       = var.enable_sagemaker_studio ? aws_security_group.vpc_endpoints_security_group[0].id : null
}

output "ml_default_security_group_id" {
  description = "ML Default Security Group ID"
  value       = aws_vpc.infra_vpc.default_security_group_id
}

# --------------------------------------------------------------------------
#  VPC Endpoint Outputs
# --------------------------------------------------------------------------
output "s3_gateway_endpoint_id" {
  description = "S3 Gateway Endpoint ID"
  value       = var.enable_sagemaker_studio ? aws_vpc_endpoint.s3[0].id : null
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
  value       = var.enable_sagemaker_studio ? aws_vpc_endpoint.sagemaker_notebook[0].id : null
}

# --------------------------------------------------------------------------
#  Logging Outputs
# --------------------------------------------------------------------------
output "firewall_alert_log_group" {
  description = "Network Firewall Alert Log Group Name"
  value       = null
}

output "firewall_flow_log_group" {
  description = "Network Firewall Flow Log Group Name"
  value       = null
}

# --------------------------------------------------------------------------
#  Summary and Configuration Outputs
# --------------------------------------------------------------------------
output "summary" {
  description = "Summary Core Infrastructure Configuration with ML Security"
  value       = <<SUMMARY
VPC Summary:
  VPC Id:                    ${aws_vpc.infra_vpc.id}
  VPC CIDR:                  ${aws_vpc.infra_vpc.cidr_block}
  Default Security Group:    ${aws_vpc.infra_vpc.default_security_group_id}

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

${var.enable_sagemaker_studio ? "  SageMaker Studio Subnet:" : "SageMaker Studio Subnet:"}
${var.enable_sagemaker_studio ? "    Zone A: ${aws_subnet.ml_sagemaker_studio_subnet[0].id} (${aws_subnet.ml_sagemaker_studio_subnet[0].cidr_block})" : "    Zone A: N/A"}

${var.enable_network_firewall ? "  Network Firewall:" : ""}
${var.enable_network_firewall ? "    Firewall ID: ${aws_networkfirewall_firewall.network_firewall[0].id}" : ""}
${var.enable_network_firewall ? "    Policy ARN:  ${aws_networkfirewall_firewall_policy.network_firewall_policy[0].arn}" : ""}

  ${var.enable_network_firewall ? "  Firewall Subnets:" : ""}
  ${var.enable_network_firewall ? "    Zone A: ${aws_subnet.ml_firewall_subnet_a[0].id} (${aws_subnet.ml_firewall_subnet_a[0].cidr_block})" : ""}
  ${var.enable_network_firewall ? "    Zone B: ${aws_subnet.ml_firewall_subnet_b[0].id} (${aws_subnet.ml_firewall_subnet_b[0].cidr_block})" : ""}
  ${var.enable_network_firewall ? "    Zone C: ${aws_subnet.ml_firewall_subnet_c[0].id} (${aws_subnet.ml_firewall_subnet_c[0].cidr_block})" : ""}

${var.enable_network_firewall ? "  NAT Gateway:" : ""}
${var.enable_network_firewall ? "    Zone A: ${aws_nat_gateway.nat_gateway[0].id}" : ""}
${var.enable_network_firewall ? "    Subnet: ${aws_subnet.ml_gateway_subnet_a[0].id} (${aws_subnet.ml_gateway_subnet_a[0].cidr_block})" : ""}
${var.enable_network_firewall ? "  NAT Gateway Subnets (Available):" : ""}
${var.enable_network_firewall ? "    Zone A: ${aws_subnet.ml_gateway_subnet_a[0].id} (${aws_subnet.ml_gateway_subnet_a[0].cidr_block})" : ""}
${var.enable_network_firewall ? "    Zone B: ${aws_subnet.ml_gateway_subnet_b[0].id} (${aws_subnet.ml_gateway_subnet_b[0].cidr_block})" : ""}
${var.enable_network_firewall ? "    Zone C: ${aws_subnet.ml_gateway_subnet_c[0].id} (${aws_subnet.ml_gateway_subnet_c[0].cidr_block})" : ""}

  Security Groups:
    Default SG: ${aws_vpc.infra_vpc.default_security_group_id}
    ML VPC SG: ${aws_security_group.ml_vpc_security_group.name} (${aws_security_group.ml_vpc_security_group.id})
${var.enable_sagemaker_studio ? "    SageMaker SG: ${aws_security_group.ml_sagemaker_security_group[0].name} (${aws_security_group.ml_sagemaker_security_group[0].id})" : "    SageMaker SG: N/A (SageMaker Studio disabled)"}
${var.enable_sagemaker_studio ? "    VPC Endpoints SG: ${aws_security_group.vpc_endpoints_security_group[0].name} (${aws_security_group.vpc_endpoints_security_group[0].id})" : "    VPC Endpoints SG: N/A (SageMaker Studio disabled)"}

Sagemaker Studio Security Groups Details:
  Default Security Group: ${aws_vpc.infra_vpc.default_security_group_id}
  ML VPC Security Group: ${aws_security_group.ml_vpc_security_group.name} (${aws_security_group.ml_vpc_security_group.id})
  SageMaker Security Group: ${var.enable_sagemaker_studio ? "${aws_security_group.ml_sagemaker_security_group[0].name} (${aws_security_group.ml_sagemaker_security_group[0].id})" : "N/A (SageMaker Studio disabled)"}
  VPC Endpoints Security Group: ${var.enable_sagemaker_studio ? "${aws_security_group.vpc_endpoints_security_group[0].name} (${aws_security_group.vpc_endpoints_security_group[0].id})" : "N/A (SageMaker Studio disabled)"}

Data Protection Features:
  - Domain Allow/Block Lists: ${var.enable_network_firewall ? "ACTIVE" : "INACTIVE"}
  - VPC Endpoints for AWS Services: ${var.enable_sagemaker_studio ? "ACTIVE" : "INACTIVE"}
  - Restrictive Security Groups: ACTIVE

Allowed Domains: ${join(", ", var.allowed_domains)}
Blocked Domains: ${join(", ", var.blocked_domains)}
Allowed CIDR Blocks: ${join(", ", var.allowed_cidr_blocks)}
SUMMARY
}

output "ml_security_config" {
  description = "ML Security Configuration Status"
  value = {
    network_firewall_enabled = var.enable_network_firewall
    sagemaker_studio_enabled = var.enable_sagemaker_studio
    allowed_domains_count    = length(var.allowed_domains)
    blocked_domains_count    = length(var.blocked_domains)
    allowed_cidr_blocks      = length(var.allowed_cidr_blocks)
    vpc_endpoints_count      = var.enable_sagemaker_studio ? 9 : 0
    security_level           = var.enable_network_firewall && var.enable_sagemaker_studio ? "HIGH" : "MEDIUM"
  }
}

# --------------------------------------------------------------------------
#  Project Information
# --------------------------------------------------------------------------
output "project_name" {
  description = "Project name used for resource naming"
  value       = local.project_name
}

output "primary_availability_zone" {
  description = "Primary availability zone for single-AZ deployment"
  value       = local.primary_az
}
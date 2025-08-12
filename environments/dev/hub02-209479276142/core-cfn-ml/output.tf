# ==========================================================================
#  209479276142 - Core: output.tf
# --------------------------------------------------------------------------
#  Description
#    Output Terraform Value - Enhanced for ML Security Module
# --------------------------------------------------------------------------
#    - VPC and Network Resources
#    - S3 Buckets and KMS Keys
#    - SageMaker Resources
#    - Network Firewall Resources
#    - Summary and Configuration Status
# ==========================================================================

# --------------------------------------------------------------------------
#  VPC and Network Outputs
# --------------------------------------------------------------------------
output "vpc_id" {
  description = "The ID of VPC where SageMaker Studio will reside"
  value       = module.core.vpc_id
}

output "sagemaker_studio_subnet_id" {
  description = "The ID of the SageMaker subnet"
  value       = module.core.sagemaker_studio_subnet_id
}

output "sagemaker_security_group_id" {
  description = "The ID the SageMaker security group"
  value       = module.core.sagemaker_security_group_id
}

output "nat_gateway_subnet_cidr" {
  description = "NAT Gateway subnet CIDR"
  value       = module.core.nat_gateway_subnet_cidr
}

output "igw_route_table_id" {
  description = "IGW route table ID"
  value       = module.core.igw_route_table_id
}

output "nat_gateway_route_table_id" {
  description = "NAT Gateway route table ID"
  value       = module.core.nat_gateway_route_table_id
}

# --------------------------------------------------------------------------
#  S3 and Storage Outputs
# --------------------------------------------------------------------------
output "data_bucket_name" {
  description = "Name of S3 bucket for data"
  value       = module.core.data_bucket_name
}

output "model_bucket_name" {
  description = "Name of S3 bucket for models"
  value       = module.core.model_bucket_name
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 VPC Endpoint"
  value       = module.core.s3_vpc_endpoint_id
}

output "kms_key_s3_buckets_arn" {
  description = "KMS key arn for data encryption in S3 buckets"
  value       = module.core.kms_key_s3_buckets_arn
}

output "kms_key_ebs_arn" {
  description = "KMS key arn for SageMaker notebooks EBS encryption"
  value       = module.core.kms_key_ebs_arn
}

# --------------------------------------------------------------------------
#  SageMaker Outputs
# --------------------------------------------------------------------------
output "sagemaker_studio_domain_id" {
  description = "SageMaker Studio domain id"
  value       = module.core.sagemaker_studio_domain_id
}

output "sagemaker_execution_role_arn" {
  description = "IAM Execution role for SageMaker Studio and SageMaker notebooks"
  value       = module.core.sagemaker_execution_role_arn
}

output "user_profile_name" {
  description = "SageMaker user profile name"
  value       = module.core.user_profile_name
}

# --------------------------------------------------------------------------
#  Network Firewall Outputs
# --------------------------------------------------------------------------
output "network_firewall_arn" {
  description = "Network Firewall ARN"
  value       = module.core.network_firewall_arn
}

output "network_firewall_endpoint_id" {
  description = "Network Firewall VPC Endpoint ID"
  value       = module.core.network_firewall_endpoint_id
}

# --------------------------------------------------------------------------
#  Project Information
# --------------------------------------------------------------------------
output "project_name" {
  description = "Project name used for resource naming"
  value       = module.core.project_name
}

output "primary_availability_zone" {
  description = "Primary availability zone for single-AZ deployment"
  value       = module.core.primary_availability_zone
}

# --------------------------------------------------------------------------
#  VPC and Network Details
# --------------------------------------------------------------------------
output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = module.core.vpc_cidr
}

output "vpc_name" {
  description = "VPC Name"
  value       = module.core.vpc_name
}

# --------------------------------------------------------------------------
#  EC2 Subnet Outputs
# --------------------------------------------------------------------------
output "ec2_private_1a" {
  description = "Private Subnet EC2 Zone A"
  value       = module.core.ec2_private_1a
}

output "ec2_private_1a_cidr" {
  description = "Private Subnet EC2 CIDR Block of Zone A"
  value       = module.core.ec2_private_1a_cidr
}

output "ec2_private_1b" {
  description = "Private Subnet EC2 Zone B"
  value       = module.core.ec2_private_1b
}

output "ec2_private_1b_cidr" {
  description = "Private Subnet EC2 CIDR Block of Zone B"
  value       = module.core.ec2_private_1b_cidr
}

output "ec2_private_1c" {
  description = "Private Subnet EC2 Zone C"
  value       = module.core.ec2_private_1c
}

output "ec2_private_1c_cidr" {
  description = "Private Subnet EC2 CIDR Block of Zone C"
  value       = module.core.ec2_private_1c_cidr
}

output "ec2_public_1a" {
  description = "Public Subnet EC2 Zone A"
  value       = module.core.ec2_public_1a
}

output "ec2_public_1a_cidr" {
  description = "Public Subnet EC2 CIDR Block of Zone A"
  value       = module.core.ec2_public_1a_cidr
}

output "ec2_public_1b" {
  description = "Public Subnet EC2 Zone B"
  value       = module.core.ec2_public_1b
}

output "ec2_public_1b_cidr" {
  description = "Public Subnet EC2 CIDR Block of Zone B"
  value       = module.core.ec2_public_1b_cidr
}

output "ec2_public_1c" {
  description = "Public Subnet EC2 Zone C"
  value       = module.core.ec2_public_1c
}

output "ec2_public_1c_cidr" {
  description = "Public Subnet EC2 CIDR Block of Zone C"
  value       = module.core.ec2_public_1c_cidr
}

# --------------------------------------------------------------------------
#  SageMaker Subnet Outputs
# --------------------------------------------------------------------------
output "sagemaker_private_1a" {
  description = "Private Subnet SageMaker Zone A"
  value       = module.core.sagemaker_private_1a
}

output "sagemaker_private_1a_cidr" {
  description = "Private Subnet SageMaker CIDR Block of Zone A"
  value       = module.core.sagemaker_private_1a_cidr
}

output "sagemaker_private_1b" {
  description = "Private Subnet SageMaker Zone B"
  value       = module.core.sagemaker_private_1b
}

output "sagemaker_private_1b_cidr" {
  description = "Private Subnet SageMaker CIDR Block of Zone B"
  value       = module.core.sagemaker_private_1b_cidr
}

output "sagemaker_private_1c" {
  description = "Private Subnet SageMaker Zone C"
  value       = module.core.sagemaker_private_1c
}

output "sagemaker_private_1c_cidr" {
  description = "Private Subnet SageMaker CIDR Block of Zone C"
  value       = module.core.sagemaker_private_1c_cidr
}

# --------------------------------------------------------------------------
#  Network Firewall Additional Outputs
# --------------------------------------------------------------------------
output "network_firewall_id" {
  description = "Network Firewall ID"
  value       = module.core.network_firewall_id
}

output "firewall_policy_arn" {
  description = "Network Firewall Policy ARN"
  value       = module.core.firewall_policy_arn
}

output "firewall_endpoints" {
  description = "Network Firewall Endpoint IDs by AZ"
  value       = module.core.firewall_endpoints
}

# --------------------------------------------------------------------------
#  Firewall Subnet Outputs
# --------------------------------------------------------------------------
output "firewall_subnet_1a" {
  description = "Network Firewall Subnet Zone A"
  value       = module.core.firewall_subnet_1a
}

output "firewall_subnet_1b" {
  description = "Network Firewall Subnet Zone B"
  value       = module.core.firewall_subnet_1b
}

output "firewall_subnet_1c" {
  description = "Network Firewall Subnet Zone C"
  value       = module.core.firewall_subnet_1c
}

# --------------------------------------------------------------------------
#  NAT Gateway Outputs
# --------------------------------------------------------------------------
output "ml_nat_gateway_1a" {
  description = "ML NAT Gateway Zone A"
  value       = module.core.ml_nat_gateway_1a
}

output "ml_nat_gateway_1b" {
  description = "ML NAT Gateway Zone B"
  value       = module.core.ml_nat_gateway_1b
}

output "ml_nat_gateway_1c" {
  description = "ML NAT Gateway Zone C"
  value       = module.core.ml_nat_gateway_1c
}

# --------------------------------------------------------------------------
#  Security Group Outputs
# --------------------------------------------------------------------------
output "vpc_endpoints_security_group_id" {
  description = "VPC Endpoints Security Group ID"
  value       = module.core.vpc_endpoints_security_group_id
}

output "ml_default_security_group_id" {
  description = "ML Default Security Group ID"
  value       = module.core.ml_default_security_group_id
}

# --------------------------------------------------------------------------
#  VPC Endpoint Outputs
# --------------------------------------------------------------------------
output "s3_gateway_endpoint_id" {
  description = "S3 Gateway Endpoint ID"
  value       = module.core.s3_gateway_endpoint_id
}

output "sagemaker_api_endpoint_id" {
  description = "SageMaker API Endpoint ID"
  value       = module.core.sagemaker_api_endpoint_id
}

output "sagemaker_runtime_endpoint_id" {
  description = "SageMaker Runtime Endpoint ID"
  value       = module.core.sagemaker_runtime_endpoint_id
}

output "sagemaker_studio_endpoint_id" {
  description = "SageMaker Studio Endpoint ID"
  value       = module.core.sagemaker_studio_endpoint_id
}

# --------------------------------------------------------------------------
#  Logging Outputs
# --------------------------------------------------------------------------
output "firewall_alert_log_group" {
  description = "Network Firewall Alert Log Group Name"
  value       = module.core.firewall_alert_log_group
}

output "firewall_flow_log_group" {
  description = "Network Firewall Flow Log Group Name"
  value       = module.core.firewall_flow_log_group
}

# --------------------------------------------------------------------------
#  Summary and Configuration Outputs
# --------------------------------------------------------------------------
output "summary" {
  description = "Summary Core Infrastructure Configuration with ML Security"
  value       = module.core.summary
}

output "ml_security_config" {
  description = "ML Security Configuration Status"
  value       = module.core.ml_security_config
}
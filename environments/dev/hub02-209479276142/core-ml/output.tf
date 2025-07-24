# ==========================================================================
#  209479276142 - Core: output.tf
# --------------------------------------------------------------------------
#  Description
#    Output Terraform Value - Enhanced for ML Security Module
# --------------------------------------------------------------------------
#    - Original VPC and EC2 Outputs (from module)
#    - ML Security Outputs (SageMaker, Network Firewall, VPC Endpoints)
#    - Security Group IDs
#    - Network Firewall Information
#    - Module-based Output References
# ==========================================================================

# --------------------------------------------------------------------------
#  Original VPC Output (Module References)
# --------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC Identity"
  value       = module.core.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR Block"
  value       = module.core.vpc_cidr
}

output "vpc_name" {
  description = "VPC Name"
  value       = module.core.vpc_name
}

output "security_group_id" {
  description = "Default Security Group of VPC Id's"
  value       = module.core.security_group_id
}

# --------------------------------------------------------------------------
#  Original EC2 Output (Module References)
# --------------------------------------------------------------------------
# EC2 Private
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

# EC2 Public
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
#  ML Security Outputs - SageMaker Subnets
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
#  ML Security Outputs - Network Firewall
# --------------------------------------------------------------------------
output "network_firewall_id" {
  description = "Network Firewall ID"
  value       = module.core.network_firewall_id
}

output "network_firewall_arn" {
  description = "Network Firewall ARN"
  value       = module.core.network_firewall_arn
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
#  ML Security Outputs - Firewall Subnets
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
#  ML Security Outputs - NAT Gateways
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
#  ML Security Outputs - Security Groups
# --------------------------------------------------------------------------
output "sagemaker_security_group_id" {
  description = "SageMaker Studio Security Group ID"
  value       = module.core.sagemaker_security_group_id
}

output "vpc_endpoints_security_group_id" {
  description = "VPC Endpoints Security Group ID"
  value       = module.core.vpc_endpoints_security_group_id
}

output "ml_default_security_group_id" {
  description = "ML Default Security Group ID"
  value       = module.core.ml_default_security_group_id
}

# --------------------------------------------------------------------------
#  ML Security Outputs - VPC Endpoints
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
#  ML Security Outputs - Logging
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
#  Enhanced Summary Output
# --------------------------------------------------------------------------
output "summary" {
  description = "Summary Core Infrastructure Configuration with ML Security"
  value       = module.core.summary
}

# --------------------------------------------------------------------------
#  ML Security Configuration Status
# --------------------------------------------------------------------------
output "ml_security_config" {
  description = "ML Security Configuration Status"
  value       = module.core.ml_security_config
}

# --------------------------------------------------------------------------
#  Subnet Arrays for Easy Consumption by Other Modules
# --------------------------------------------------------------------------
output "all_private_subnets" {
  description = "All private subnet IDs (EC2 + SageMaker)"
  value = compact([
    for subnet in concat(
      module.core.ec2_private_1a,
      module.core.ec2_private_1b,
      module.core.ec2_private_1c,
      [module.core.sagemaker_private_1a],
      [module.core.sagemaker_private_1b],
      [module.core.sagemaker_private_1c]
    ) : subnet
  ])
}

output "all_public_subnets" {
  description = "All public subnet IDs"
  value = compact(concat(
    module.core.ec2_public_1a,
    module.core.ec2_public_1b,
    module.core.ec2_public_1c
  ))
}

output "sagemaker_subnets" {
  description = "SageMaker private subnet IDs only"
  value = compact([
    module.core.sagemaker_private_1a,
    module.core.sagemaker_private_1b,
    module.core.sagemaker_private_1c
  ])
}

output "firewall_subnets" {
  description = "Network Firewall subnet IDs"
  value = compact([
    module.core.firewall_subnet_1a,
    module.core.firewall_subnet_1b,
    module.core.firewall_subnet_1c
  ])
}

# --------------------------------------------------------------------------
#  Security Groups Array for Easy Reference
# --------------------------------------------------------------------------
output "all_security_groups" {
  description = "All security group IDs created by the module"
  value = {
    default_sg       = module.core.security_group_id
    ml_default_sg    = module.core.ml_default_security_group_id
    sagemaker_sg     = module.core.sagemaker_security_group_id
    vpc_endpoints_sg = module.core.vpc_endpoints_security_group_id
  }
}

# --------------------------------------------------------------------------
#  Network Information for Dependent Modules
# --------------------------------------------------------------------------
output "network_info" {
  description = "Network information for dependent modules"
  value = {
    vpc_id   = module.core.vpc_id
    vpc_cidr = module.core.vpc_cidr

    # Traditional subnets
    ec2_private_subnets = {
      zone_a = {
        id   = length(module.core.ec2_private_1a) > 0 ? module.core.ec2_private_1a[0] : null
        cidr = module.core.ec2_private_1a_cidr
      }
      zone_b = {
        id   = length(module.core.ec2_private_1b) > 0 ? module.core.ec2_private_1b[0] : null
        cidr = module.core.ec2_private_1b_cidr
      }
      zone_c = {
        id   = length(module.core.ec2_private_1c) > 0 ? module.core.ec2_private_1c[0] : null
        cidr = module.core.ec2_private_1c_cidr
      }
    }

    ec2_public_subnets = {
      zone_a = {
        id   = length(module.core.ec2_public_1a) > 0 ? module.core.ec2_public_1a[0] : null
        cidr = module.core.ec2_public_1a_cidr
      }
      zone_b = {
        id   = length(module.core.ec2_public_1b) > 0 ? module.core.ec2_public_1b[0] : null
        cidr = module.core.ec2_public_1b_cidr
      }
      zone_c = {
        id   = length(module.core.ec2_public_1c) > 0 ? module.core.ec2_public_1c[0] : null
        cidr = module.core.ec2_public_1c_cidr
      }
    }

    # ML Security subnets
    sagemaker_subnets = {
      zone_a = {
        id   = module.core.sagemaker_private_1a
        cidr = module.core.sagemaker_private_1a_cidr
      }
      zone_b = {
        id   = module.core.sagemaker_private_1b
        cidr = module.core.sagemaker_private_1b_cidr
      }
      zone_c = {
        id   = module.core.sagemaker_private_1c
        cidr = module.core.sagemaker_private_1c_cidr
      }
    }

    firewall_subnets = {
      zone_a = module.core.firewall_subnet_1a
      zone_b = module.core.firewall_subnet_1b
      zone_c = module.core.firewall_subnet_1c
    }

    # Security configuration
    ml_security_enabled = module.core.ml_security_config.network_firewall_enabled
    sagemaker_enabled   = module.core.ml_security_config.sagemaker_studio_enabled
    security_level      = module.core.ml_security_config.security_level

    # Network Firewall information
    firewall_id        = module.core.network_firewall_id
    firewall_endpoints = module.core.firewall_endpoints
  }
}

# --------------------------------------------------------------------------
#  Monitoring and Logging Information
# --------------------------------------------------------------------------
output "monitoring_info" {
  description = "Monitoring and logging information"
  value = {
    firewall_alert_log_group = module.core.firewall_alert_log_group
    firewall_flow_log_group  = module.core.firewall_flow_log_group
    security_level           = module.core.ml_security_config.security_level
    allowed_domains_count    = module.core.ml_security_config.allowed_domains_count
    blocked_domains_count    = module.core.ml_security_config.blocked_domains_count
    vpc_endpoints_count      = module.core.ml_security_config.vpc_endpoints_count
  }
}
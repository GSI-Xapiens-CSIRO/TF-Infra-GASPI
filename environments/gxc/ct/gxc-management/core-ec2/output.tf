# ==========================================================================
#  112233445566 - Core: output.tf
# --------------------------------------------------------------------------
#  Description
#    Output Terraform Value
# --------------------------------------------------------------------------
#    - VPC ID
#    - VPC CIDR
#    - VPC Name
#    - VPC Security Group ID
#    - Subnet ID EC2 Private A
#    - Subnet ID EC2 Private B
#    - Subnet ID EC2 Private C
#    - Subnet CIDR Block EC2 Private A
#    - Subnet CIDR Block EC2 Private B
#    - Subnet CIDR Block EC2 Private C
#    - Subnet ID EC2 Public A
#    - Subnet ID EC2 Public B
#    - Subnet ID EC2 Public C
#    - Subnet CIDR Block EC2 Public A
#    - Subnet CIDR Block EC2 Public B
#    - Subnet CIDR Block EC2 Public C
# ==========================================================================

# --------------------------------------------------------------------------
#  VPC Output
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
  description = "Security Group of VPC Id's"
  value       = module.core.security_group_id
}

# --------------------------------------------------------------------------
#  EC2 Output
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
#  Summary Output
# --------------------------------------------------------------------------
output "summary" {
  description = "Summary Core Infrastructure Configuration"
  value       = module.core.summary
}

# CloudFormation-Compatible Terraform Module Usage

This module has been adapted to be compatible with the CloudFormation templates from `amazon-sagemaker-studio-vpc-networkfirewall/cfn_templates`.

## Key Changes Made

### 1. Single-AZ Deployment (CloudFormation Style)
- Simplified from multi-AZ to single-AZ deployment
- Uses primary AZ (`${region}a`) for all resources
- Matches CloudFormation template architecture

### 2. New CloudFormation-Compatible Files
- `cfn-subnets.tf` - Single-AZ subnet configuration
- `cfn-network-firewall.tf` - Network Firewall with CloudFormation naming
- `cfn-routing.tf` - Route tables and routes matching CloudFormation
- `cfn-vpc-endpoints.tf` - VPC endpoints for SageMaker services
- `cfn-s3-iam.tf` - S3 buckets and IAM roles
- `cfn-sagemaker-studio.tf` - SageMaker Studio domain and user profile
- `cfn-outputs.tf` - CloudFormation-compatible outputs

### 3. CloudFormation-Style Naming
- Resources use CloudFormation naming conventions
- Project-based naming: `${project_name}-${account_id}-${region}-suffix`
- Consistent tagging with `ProjectName`

## Usage Example

```hcl
module "ml_infrastructure" {
  source = "./modules/core-nat-ml"

  # CloudFormation compatibility
  project_name = "sagemaker-studio-anfw"
  
  # Enable CloudFormation-style features
  enable_network_firewall = true
  enable_sagemaker_studio = true
  
  # AWS Configuration
  aws_region                      = "us-east-1"
  aws_account_id_source          = "123456789012"
  aws_account_id_destination     = "123456789012"
  aws_account_profile_source     = "default"
  aws_account_profile_destination = "default"
  
  # CloudFormation-style CIDR blocks
  vpc_cidr = {
    default = "10.2.0.0/16"
    lab     = "10.2.0.0/16"
    staging = "10.3.0.0/16"
    prod    = "10.5.0.0/16"
  }
  
  firewall_subnet_cidr = {
    default = "10.2.1.0/24"
    lab     = "10.2.1.0/24"
    staging = "10.3.1.0/24"
    prod    = "10.5.1.0/24"
  }
  
  nat_gateway_subnet_cidr = {
    default = "10.2.2.0/24"
    lab     = "10.2.2.0/24"
    staging = "10.3.2.0/24"
    prod    = "10.5.2.0/24"
  }
  
  sagemaker_subnet_cidr = {
    default = "10.2.3.0/24"
    lab     = "10.2.3.0/24"
    staging = "10.3.3.0/24"
    prod    = "10.5.3.0/24"
  }
  
  # SageMaker Configuration
  sagemaker_domain_name      = "sagemaker-anfw-domain"
  sagemaker_user_profile_name = "anfw-user-profile"
  start_kernel_gateway_apps  = false  # Set to true to start Data Science and Data Wrangler apps
  
  # Security Configuration
  allowed_domains = [
    ".amazonaws.com",
    ".kaggle.com"
  ]
  
  # KMS Configuration (if using existing keys)
  kms_key = {
    lab     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    staging = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    prod    = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
  
  # Tagging
  department = "DEVOPS"
  custom_tags = {
    Owner       = "ML-Team"
    Environment = "Development"
    CostCenter  = "ML-Research"
  }
}
```

## Key Outputs (CloudFormation Compatible)

```hcl
# VPC and Network
output "vpc_id" {
  value = module.ml_infrastructure.vpc_id
}

output "sagemaker_studio_subnet_id" {
  value = module.ml_infrastructure.sagemaker_studio_subnet_id
}

# S3 Buckets
output "data_bucket_name" {
  value = module.ml_infrastructure.data_bucket_name
}

output "model_bucket_name" {
  value = module.ml_infrastructure.model_bucket_name
}

# SageMaker
output "sagemaker_studio_domain_id" {
  value = module.ml_infrastructure.sagemaker_studio_domain_id
}

output "sagemaker_execution_role_arn" {
  value = module.ml_infrastructure.sagemaker_execution_role_arn
}
```

## Migration from Multi-AZ to Single-AZ

If you're migrating from the existing multi-AZ setup:

1. **Backup existing resources** before migration
2. **Use CloudFormation-compatible files** instead of existing multi-AZ files
3. **Update variable references** to use new CloudFormation-style variables
4. **Test in non-production environment** first

## CloudFormation Equivalence

This Terraform module now creates the same resources as the CloudFormation templates:

- **vpc.yaml** → `cfn-subnets.tf`, `cfn-network-firewall.tf`, `cfn-routing.tf`, `cfn-vpc-endpoints.tf`
- **iam.yaml** → `cfn-s3-iam.tf` (IAM portion)
- **s3.yaml** → `cfn-s3-iam.tf` (S3 portion)
- **sagemaker-studio.yaml** → `cfn-sagemaker-studio.tf`
- **sagemaker-studio-vpc.yaml** → Main orchestration (handled by module structure)

## Cost Optimization

Single-AZ deployment reduces costs by:
- Using only one NAT Gateway instead of three
- Single Network Firewall endpoint
- Reduced data transfer costs
- Simplified routing (fewer route tables)

**Note**: Single-AZ deployment is suitable for development/testing but consider multi-AZ for production workloads requiring high availability.
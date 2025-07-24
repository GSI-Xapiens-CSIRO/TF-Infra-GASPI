# ==========================================================================
#  Infra Terraformer: provider.tf
# --------------------------------------------------------------------------
#  Description:
#    Provider Modules
# --------------------------------------------------------------------------
#    - Terraform Cli Version
#    - AWS Terraform Version
#    - AWS Region
#    - AWS Access Key
#    - AWS Secret Key
#    - AWS Account ID
# ==========================================================================

# --------------------------------------------------------------------------
#  Terraform AWS Version Compability & Remote State Path
# --------------------------------------------------------------------------
terraform {
  required_version = ">= 1.8.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.74.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }

    random = ">= 2.0"
  }
}

# --------------------------------------------------------------------------
#  AWS Provider Properties
# --------------------------------------------------------------------------
provider "aws" {
  region  = var.aws_region
  profile = var.aws_account_profile
  # access_key               = var.aws_access_key
  # secret_key               = var.aws_secret_key
  # shared_config_files      = ["$HOME/.aws/config"]
  # shared_credentials_files = ["$HOME/.aws/credentials"]
}

# ==========================================================================
#  222233334444 - CloudTrails: main.tf
# --------------------------------------------------------------------------
#  Description:
#    Main Terraform Module
# --------------------------------------------------------------------------
#    - Workspace Environment
#    - Common Tags
# ==========================================================================

# --------------------------------------------------------------------------
#  Workspace Environmet
# --------------------------------------------------------------------------
locals {
  env = terraform.workspace
}

# --------------------------------------------------------------------------
#  Global Tags
# --------------------------------------------------------------------------
locals {
  tags = {
    Environment     = "${var.environment[local.env]}"
    Department      = "${var.department}"
    DepartmentGroup = "${var.environment[local.env]}-${var.department}"
    Terraform       = true
  }
}

# module "cloudtrail" {
#   source = "../../../modules/audit/cloudtrails"
#   providers = {
#     aws = aws
#   }

#   aws_region                      = var.aws_region
#   aws_account_id_source           = var.aws_account_id_source
#   aws_account_id_destination      = var.aws_account_id_destination
#   aws_account_profile_source      = var.aws_account_profile_source
#   aws_account_profile_destination = var.aws_account_profile_destination
#   aws_access_key                  = var.aws_access_key
#   aws_secret_key                  = var.aws_secret_key
#   workspace_name                  = var.workspace_name
#   workspace_env                   = var.workspace_env
#   environment                     = var.environment
#   department                      = var.department
#   kms_key                         = var.kms_key
#   kms_env                         = var.kms_env

#   log_retention_days = 365
# }

module "cloudtrail" {
  source = "../../../modules/audit/cloudtrails-opensearch"
  providers = {
    aws = aws
  }

  aws_region                      = var.aws_region
  aws_account_id_source           = var.aws_account_id_source
  aws_account_id_destination      = var.aws_account_id_destination
  aws_account_profile_source      = var.aws_account_profile_source
  aws_account_profile_destination = var.aws_account_profile_destination
  aws_access_key                  = var.aws_access_key
  aws_secret_key                  = var.aws_secret_key
  workspace_name                  = var.workspace_name
  workspace_env                   = var.workspace_env
  environment                     = var.environment
  department                      = var.department
  kms_key                         = var.kms_key
  kms_env                         = var.kms_env

  log_retention_days = 365

  vpc_id = data.terraform_remote_state.core_state.outputs.vpc_id
  public_subnet_ids = local.env == "prod" ? [
    data.terraform_remote_state.core_state.outputs.ec2_public_1a[0],
    data.terraform_remote_state.core_state.outputs.ec2_public_1b[0],
    data.terraform_remote_state.core_state.outputs.ec2_public_1c[0]
    ] : [
    data.terraform_remote_state.core_state.outputs.ec2_public_1a[0],
    data.terraform_remote_state.core_state.outputs.ec2_public_1b[0],
  ]
  private_subnet_ids = local.env == "prod" ? [
    data.terraform_remote_state.core_state.outputs.ec2_private_1a[0],
    data.terraform_remote_state.core_state.outputs.ec2_private_1b[0],
    data.terraform_remote_state.core_state.outputs.ec2_private_1c[0]
    ] : [
    data.terraform_remote_state.core_state.outputs.ec2_private_1a[0],
    data.terraform_remote_state.core_state.outputs.ec2_private_1b[0],
  ]
  opensearch_instance_type   = "t3.medium.search"
  opensearch_instance_count  = 2
  opensearch_master_user     = "gxc-admin"
  opensearch_master_email    = "test@email.com"
  opensearch_master_password = ""
  opensearch_volume_size     = 50

  allowed_ips = [
    "10.1.0.0/32",
    "10.3.0.0/32"
  ]

  saml_metadata_content = null

  cognito_users = [
    {
      username = "gxc-admin"
      password = ""
      groups   = ["Administrators"]
      attributes = {
        email          = "test@email.com"
        email_verified = "true"
      }
    },
    {
      username = "xti-user01"
      password = ""
      groups   = ["Administrators"]
      attributes = {
        email          = "user01@email.com"
        email_verified = "true"
      }
    },
    {
      username = "xti-user02"
      password = ""
      groups   = ["Administrators"]
      attributes = {
        email          = "user02@email.com"
        email_verified = "true"
      }
    }
  ]
}

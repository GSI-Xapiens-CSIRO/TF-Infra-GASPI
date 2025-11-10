# ==========================================================================
#  442799077487 - CloudTrails: main.tf
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
#   source = "../../../../modules/audit/cloudtrails"
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
  source = "../../../../modules/audit//cloudtrails-opensearch"

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
  opensearch_instance_type   = local.env == "prod" ? "m5.large.search" : "t3.medium.search"
  opensearch_instance_count  = local.env == "prod" ? 3 : 2
  opensearch_master_user     = "gxc-admin"
  opensearch_master_email    = "devops@example.com"
  opensearch_master_password = "R4nd0m-P4ssW0Rd"
  opensearch_volume_size     = local.env == "prod" ? 300 : 150

  allowed_ips = [
    "111.94.0.0/16",
    "182.253.0.0/16"
  ]

  saml_metadata_content = null

  cognito_users = [
    {
      username = "gxc-admin"
      password = "R4nd0m-P4ssW0Rd"
      groups   = ["Administrators"]
      attributes = {
        email          = "devops@example.com"
        email_verified = "true"
      }
    },
    {
      username = "admin01"
      password = "R4nd0m-P4ssW0Rd"
      groups   = ["Administrators"]
      attributes = {
        email          = "admin01@example.com"
        email_verified = "true"
      }
    },
    {
      username = "admin02"
      password = "R4nd0m-P4ssW0Rd"
      groups   = ["Administrators"]
      attributes = {
        email          = "admin02@example.com"
        email_verified = "true"
      }
    }
  ]
}

module "s3_snapshot" {
  source = "../../../../modules//storage-s3"

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
  prefix_name                     = var.prefix_name
  allowed_role_arns               = var.allowed_role_arns
  log_retention_days              = var.log_retention_days
  enable_notifications            = var.enable_notifications
  sns_topic_arn                   = var.sns_topic_arn
  enable_replication              = var.enable_replication
  replication_role_arn            = var.replication_role_arn
  destination_bucket_arn          = var.destination_bucket_arn
  bucket_enable_lifecycle         = var.bucket_enable_lifecycle
  group_awscloud_developer        = "gxc-developer_${var.aws_account_id_destination}_${local.env}"
  group_awscloud_administrator    = "gxc-administrator_${var.aws_account_id_destination}_${local.env}"
  group_awscloud_billing          = "gxc-developer_${var.aws_account_id_destination}_${local.env}"
  common_tags                     = local.tags
}

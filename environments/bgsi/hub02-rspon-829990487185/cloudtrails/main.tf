# ==========================================================================
#  829990487185 - CloudTrails: main.tf
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
  opensearch_master_user     = "bgsi-master"
  opensearch_master_email    = "rscm@binomika.kemenkes.go.id"
  opensearch_master_password = "SuperAdmin!123456"
  opensearch_volume_size     = local.env == "prod" ? 300 : 150

  allowed_ips = [
    "10.1.0.0/32",
    "10.3.0.0/32"
  ]

  saml_metadata_content = null

  cognito_users = [
    {
      username = "bgsi-admin"
      password = "Admin!123456"
      groups   = ["Administrators"]
      attributes = {
        email          = "bgsi.admin01@binomika.kemkes.go.id"
        email_verified = "true"
      }
    },
    {
      username = "bgsi-user01"
      password = "User01!123456"
      groups   = ["Administrators"]
      attributes = {
        email          = "bgsi.developer01@binomika.kemkes.go.id"
        email_verified = "true"
      }
    },
    {
      username = "bgsi-user02"
      password = "User02!123456"
      groups   = ["Administrators"]
      attributes = {
        email          = "bgsi.developer02@binomika.kemkes.go.id"
        email_verified = "true"
      }
    }
  ]
}

module "s3_snapshot" {
  source = "../../../../../modules//storage-s3"

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
  allowed_role_arns               = [
    "gxc-developer_${var.aws_account_id_destination}_${local.env}",
    "gxc-administrator_${var.aws_account_id_destination}_${local.env}"
  ]
  log_retention_days              = var.log_retention_days
  enable_notifications            = var.enable_notifications
  sns_topic_arn                   = var.sns_topic_arn
  enable_replication              = var.enable_replication
  replication_role_arn            = "gxc-administrator_${var.aws_account_id_destination}_${local.env}"
  destination_bucket_arn          = "gxc-administrator_${var.aws_account_id_destination}_${local.env}"
  bucket_enable_lifecycle         = var.bucket_enable_lifecycle
  group_awscloud_developer        = "gxc-developer_${var.aws_account_id_destination}_${local.env}"
  group_awscloud_administrator    = "gxc-administrator_${var.aws_account_id_destination}_${local.env}"
  group_awscloud_billing          = "gxc-developer_${var.aws_account_id_destination}_${local.env}"
  common_tags                     = local.tags
}

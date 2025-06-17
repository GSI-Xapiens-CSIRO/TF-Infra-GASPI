# ==========================================================================
#  127214202110 - IAM Logging: main.tf
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

# --------------------------------------------------------------------------
#  Reuse Module: IAM Logging
# --------------------------------------------------------------------------
module "hub_logging_roles" {
  source = "../../../modules/iam-logging"

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

  ## Static Variables ##
  # central_logs_bucket_arn = var.central_logs_bucket_arn
  ## Remote State Variables ##
  central_logs_bucket_arn = data.terraform_remote_state.s3_logs_remote.outputs.central_logging.arn
  hub_identifier          = "hub01"


  enabled_logging_types = {
    cloudfront = true
    lambda     = true
    s3_access  = true
    apigateway = true
    dynamodb   = true
  }

  common_tags = {
    Project   = "GXC-sBeacon"
    Terraform = "true"
    AccountID = "${var.aws_account_id_destination}"
  }
}

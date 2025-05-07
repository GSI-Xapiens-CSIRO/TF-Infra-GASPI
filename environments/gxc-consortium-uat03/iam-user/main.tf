# ==========================================================================
#  YOUR_AWS_ACCOUNT - IAM: main.tf
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
#  Reuse Module: IAM-User
# --------------------------------------------------------------------------
module "iam-user" {
  source = "../../../../modules//iam-user"

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

  group_gxc_developer      = var.group_gxc_developer
  group_gxc_administrator  = var.group_gxc_administrator
  policy_gxc_developer     = var.policy_gxc_developer
  policy_gxc_administrator = var.policy_gxc_administrator
  tf_user_executor         = var.tf_user_executor
  xti_team_developer       = var.xti_team_developer
  xti_team_administrator   = var.xti_team_administrator
  csiro_team_developer     = var.csiro_team_developer
  csiro_team_administrator = var.csiro_team_administrator
}

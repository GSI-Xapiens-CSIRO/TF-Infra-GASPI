# ==========================================================================
#  209479276142 - CloudTrail Only: main.tf
# --------------------------------------------------------------------------
#  Description:
#    Main Terraform Module
# --------------------------------------------------------------------------
#    - Workspace Environment
#    - Common Tags
# ==========================================================================

# --------------------------------------------------------------------------
#  Reuse Module: CloudTrail Only
# --------------------------------------------------------------------------
module "cloudtrail_only" {
  source = "../../../../../modules/audit/cloudtrails-only"

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

  log_retention_days = var.log_retention_days
}
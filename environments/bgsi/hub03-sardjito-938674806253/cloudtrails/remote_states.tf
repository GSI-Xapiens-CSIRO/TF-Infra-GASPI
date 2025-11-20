# ==========================================================================
#  938674806253 - CloudTrail: remote_states.tf
# --------------------------------------------------------------------------
#  Description
# --------------------------------------------------------------------------
#    - DynamoDB
#    - S3 Bucket
#    - Region
# ==========================================================================

# --------------------------------------------------------------------------
#  Use Existing Core Terraform Remote State
# --------------------------------------------------------------------------
data "terraform_remote_state" "core_state" {
  backend   = "s3"
  workspace = local.env

  config = {
    bucket  = "tf-state-938674806253-ap-southeast-3"
    key     = "bgsi/938674806253/core/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_account_profile_destination
    # access_key = var.aws_access_key
    # secret_key = var.aws_secret_key
  }
}

# ==========================================================================
#  123412341234 - CloudTrail: remote_states.tf
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
    bucket  = "tf-state-123412341234-ap-southeast-3"
    key     = "gxc-consortium/123412341234/core/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_account_profile_destination
    # access_key = var.aws_access_key
    # secret_key = var.aws_secret_key
  }
}

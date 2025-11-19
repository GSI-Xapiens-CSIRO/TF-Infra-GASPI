# ==========================================================================
#  829990487185 - IAM Logging: remote_states.tf (Remote Terraform References)
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
data "terraform_remote_state" "tfstate_remote" {
  backend   = "s3"
  workspace = local.env

  config = {
    bucket  = "tf-state-829990487185-ap-southeast-3"
    key     = "bgsi/829990487185/tfstate/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_account_profile_source
  }
}

data "terraform_remote_state" "s3_logs_remote" {
  backend   = "s3"
  workspace = local.env

  config = {
    bucket  = "tf-state-829990487185-ap-southeast-3"
    key     = "bgsi/864899849921/s3-logs/terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_account_profile_source
  }
}
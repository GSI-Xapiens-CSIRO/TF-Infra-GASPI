# ==========================================================================
#  YOUR_AWS_ACCOUNT - Budget: backend.tf (Storing tfstate)
# --------------------------------------------------------------------------
#  Description
# --------------------------------------------------------------------------
#    - S3 Bucket Path
#    - DynamoDB Table
# ==========================================================================

# --------------------------------------------------------------------------
#  Store Path for Terraform State
# --------------------------------------------------------------------------
terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-YOUR_AWS_ACCOUNT-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-YOUR_AWS_ACCOUNT-ap-southeast-3"
    key            = "gxc-consortium/YOUR_AWS_ACCOUNT/budget/terraform.tfstate"
    encrypt        = true
  }
}

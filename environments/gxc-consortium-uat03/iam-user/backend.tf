# ==========================================================================
#  YOUR_AWS_ACCOUNT - IAM: backend.tf
# --------------------------------------------------------------------------
#  Description:
#    Store Terraform State to S3
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
    key            = "gxc-consortium/YOUR_AWS_ACCOUNT/iam-user/terraform.tfstate"
    encrypt        = true
  }
}

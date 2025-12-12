# ==========================================================================
#  209479276142 - IAM Logging: backend.tf
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
    bucket         = "tf-state-112233445566-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-112233445566-ap-southeast-3"
    key            = "gxc-consortium/209479276142/iam-logging/terraform.tfstate"
    encrypt        = true
  }
}

# ==========================================================================
#  127214202110 - IAM TFUser-Executor: backend.tf
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
    bucket         = "tf-state-127214202110-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-127214202110-ap-southeast-3"
    key            = "gxc-consortium/127214202110/iam-tfuser/terraform.tfstate"
    encrypt        = true
  }
}

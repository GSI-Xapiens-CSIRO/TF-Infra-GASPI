# ==========================================================================
#  209479276142 - CloudTrail Only: backend.tf (Storing tfstate)
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
    bucket         = "tf-state-209479276142-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-209479276142-ap-southeast-3"
    key            = "gxc-consortium/209479276142/cloudtrail-only/terraform.tfstate"
    encrypt        = true
  }
}
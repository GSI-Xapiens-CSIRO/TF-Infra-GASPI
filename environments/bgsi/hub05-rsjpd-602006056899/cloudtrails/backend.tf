# ==========================================================================
#  602006056899 - CloudTrails: backend.tf
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
    bucket         = "tf-state-602006056899-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-602006056899-ap-southeast-3"
    key            = "bgsi/602006056899/cloudtrails/terraform.tfstate"
    encrypt        = true
  }
}

terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-123412341234-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-123412341234-ap-southeast-3"
    key            = "gxc-consortium/123412341234/gaspi-infra-deployment/terraform.tfstate"
    encrypt        = true
  }
}
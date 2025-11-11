terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-444455556666-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-444455556666-ap-southeast-3"
    key            = "bgsi/444455556666/gaspi-infra-deployment/terraform.tfstate"
    encrypt        = true
  }
}

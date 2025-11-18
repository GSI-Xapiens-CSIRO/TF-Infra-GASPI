terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-899630542732-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-899630542732-ap-southeast-3"
    key            = "bgsi/899630542732/gaspi-infra-deployment/terraform.tfstate"
    encrypt        = true
  }
}
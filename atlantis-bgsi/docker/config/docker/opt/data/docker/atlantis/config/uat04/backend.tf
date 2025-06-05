terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-496940679572-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-496940679572-ap-southeast-3"
    key            = "bgsi-consortium/496940679572/gaspi-infra-deployment/terraform.tfstate"
    encrypt        = true
  }
}
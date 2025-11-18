terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-819520291687-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-819520291687-ap-southeast-3"
    key            = "bgsi/819520291687/gaspi-infra-deployment/terraform.tfstate"
    encrypt        = true
  }
}

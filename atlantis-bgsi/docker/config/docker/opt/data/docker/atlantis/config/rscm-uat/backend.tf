terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-695094375681-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-695094375681-ap-southeast-3"
    key            = "bgsi/695094375681/gaspi-infra-deployment/terraform.tfstate"
    encrypt        = true
  }
}

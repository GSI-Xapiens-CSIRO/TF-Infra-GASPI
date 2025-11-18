terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-741464515101-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-741464515101-ap-southeast-3"
    key            = "bgsi/741464515101/gaspi-infra-deployment/terraform.tfstate"
    encrypt        = true
  }
}
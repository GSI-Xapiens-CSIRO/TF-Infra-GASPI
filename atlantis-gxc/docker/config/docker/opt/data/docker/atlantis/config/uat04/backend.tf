terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-777788889999-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-777788889999-ap-southeast-3"
    key            = "gxc-consortium/777788889999/gaspi-infra-deployment/terraform.tfstate"
    encrypt        = true
  }
}
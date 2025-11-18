terraform {
  backend "s3" {
    region         = "ap-southeast-3"
    bucket         = "tf-state-829990487185-ap-southeast-3"
    dynamodb_table = "ddb-tf-state-829990487185-ap-southeast-3"
    key            = "bgsi/829990487185/gaspi-infra-deployment/terraform.tfstate"
    encrypt        = true
  }
}
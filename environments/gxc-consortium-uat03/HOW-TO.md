# Terraform Import AWS Account 460722568061 (Terraformer)

Reverse Engineer AWS Account Configuration using Terraform

## How-to-Use

- Create `provider.tf`, add this line:

  ```
  terraform {
    required_version = ">= 1.8.4"

    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 5.72"
      }
      tls = {
        source  = "hashicorp/tls"
        version = ">= 3.0"
      }
      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = ">= 2.10"
      }

      random = ">= 2.0"
    }
  }
  ```

- Setup AWS Credentials & Config

  ```
  $HOME/.aws/credentials
  ---
  [GXC-TF-User-Executor]
  aws_access_key_id =
  aws_secret_access_key =

  $HOME/.aws/config
  ---
  [profile GXC-TF-User-Executor]
  role_arn = arn:aws:iam::460722568061:role/TF-Central-Role_460722568061
  source_profile = GXC-TF-User-Executor-UAT03
  region = ap-southeast-3
  output = json
  ```

- Change AWS Profile and Region

  ```
  unset AWS_SESSION_TOKEN AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID

  export AWS_PROFILE=GXC-TF-User-Executor-UAT03
  export AWS_DEFAULT_REGION=ap-southeast-3

  aws sts get-caller-identity --profile $AWS_PROFILE
  ```

- Run `terraform init`

- Running Terraformer
  ```
  terraformer import aws --regions=$AWS_DEFAULT_REGION --resources="*" --profile=$AWS_PROFILE
  ```

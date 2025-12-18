# Terraform IAM Logging for 469134084689

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
  [GXC-TF-User-Executor-HUB03]
  aws_access_key_id =
  aws_secret_access_key =

  $HOME/.aws/config
  ---
  [profile GXC-TF-User-Executor-HUB03]
  role_arn = arn:aws:iam::469134084689:role/TF-Central-Role_469134084689
  source_profile = GXC-TF-User-Executor-HUB03
  region = ap-southeast-3
  output = json
  ```

- Change AWS Profile and Region

  ```
  unset AWS_SESSION_TOKEN AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID

  export AWS_PROFILE=GXC-TF-User-Executor-HUB03
  export AWS_DEFAULT_REGION=ap-southeast-3

  aws sts get-caller-identity --profile $AWS_PROFILE
  ```

- Run `terraform init`


## How-to-Deploy

- Terraform Initialize

  ```
  terraform init
  ```

- List Existing Workspace

  ```
  terraform workspace list
  ```

- Create Workspace

  ```
  terraform workspace new [environment]
  ---
  eg:
  terraform workspace new lab
  terraform workspace new staging
  terraform workspace new prod
  ```

- Use Workspace

  ```
  terraform workspace select [environment]
  ---
  eg:
  terraform workspace select lab
  terraform workspace select staging
  terraform workspace select prod
  ```

- Terraform Planning

  ```
  terraform plan
  ```

- Terraform Provisioning

  ```
  terraform apply
  ```

## Migrate State

- Rename Backend

  ```
  mv backend.tf.example backend.tf
  ```

- Initiate Migrate

  ```
  terraform init --migrate-state
  ```

## Cleanup Environment

```
terraform destroy
```

## Copyright

- Author: **DevOps Engineer (support.gxc@xapiens.id)**
- Vendor: **Xapiens Teknologi Indonesia (xapiens.id)**
- License: **Apache v2**

# Terraform Module Cloudfront ALB

## Prerequisites

1.  **Terraform Installed**: Ensure Terraform (version specified in `versions.tf`) is installed.
2.  **AWS Credentials Configured**: Your AWS credentials must be configured for Terraform to use. This can be via environment variables, shared credential files (`~/.aws/credentials`), or IAM roles.
3.  **SSL Certificate Files**: You need your SSL certificate (`cert.crt`), private key (`cert.key`), and optionally the certificate chain (`chain.crt`) available locally. These will be referenced by path.
4.  **Existing VPC and Subnets**: You need the ID of an existing VPC and a list of public subnet IDs where the ALB will be deployed.
5.  **Existing Route 53 Hosted Zone**: You need the name of an existing public Route 53 hosted zone for the domain you intend to use.

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
  role_arn = arn:aws:iam::112233445566:role/TF-Central-Role_112233445566
  source_profile = GXC-TF-User-Executor
  region = ap-southeast-3
  output = json
  ```

- Change AWS Profile and Region

  ```
  unset AWS_SESSION_TOKEN AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID

  export AWS_PROFILE=GXC-TF-User-Executor
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

## Important Considerations

- **Application Deployment**: This module provisions the infrastructure (ALB, CloudFront, SGs). You still need to deploy your application (e.g., on EC2, ECS, Fargate) and ensure its instances/tasks:
  - Use the Security Group ID provided in the `app_instance_sg_id` output.
  - Are registered with the ALB Target Group created by this module (or you modify the module to create an ASG/ECS service that registers them). The current module creates a target group; you'd typically point an Auto Scaling Group or ECS Service to this `aws_lb_target_group.main.arn`.
- **ACM Certificate Validation**: The `aws_acm_certificate` resource with imported certificates does not require DNS or email validation _within AWS ACM_. However, the certificate itself must be valid and trusted.
- **CloudFront Propagation**: DNS changes and CloudFront distribution deployments can take some time to propagate globally (5-30 minutes or more).
- **Cost**: Be aware of the costs associated with ALB, CloudFront, Route 53, and data transfer.

## Copyright

- Author: **DevOps Engineer (devops@xapiens.id)**
- Vendor: **Xapiens Teknologi Indonesia (xapiens.id)**
- License: **Apache v2**

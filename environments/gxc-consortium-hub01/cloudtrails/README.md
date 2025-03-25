# Terraform CloudTrails with OpenSearch for 112233445566

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.72 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../../modules/audit/cloudtrails-opensearch | n/a |

## Resources

| Name | Type |
|------|------|
| [terraform_remote_state.core_state](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | The AWS Access Key | `string` | `""` | no |
| <a name="input_aws_account_id_destination"></a> [aws\_account\_id\_destination](#input\_aws\_account\_id\_destination) | The AWS Account ID to deploy the Budget in | `string` | `"112233445566"` | no |
| <a name="input_aws_account_id_source"></a> [aws\_account\_id\_source](#input\_aws\_account\_id\_source) | The AWS Account ID management | `string` | `"112233445566"` | no |
| <a name="input_aws_account_profile_destination"></a> [aws\_account\_profile\_destination](#input\_aws\_account\_profile\_destination) | The AWS Profile to deploy the Budget in | `string` | `"GXC-TF-User-Executor-Hub01-UAT"` | no |
| <a name="input_aws_account_profile_source"></a> [aws\_account\_profile\_source](#input\_aws\_account\_profile\_source) | The AWS Profile management | `string` | `"GXC-TF-User-Executor"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region | `string` | `"ap-southeast-3"` | no |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | The AWS Secret Key | `string` | `""` | no |
| <a name="input_department"></a> [department](#input\_department) | Department Owner | `string` | `"DEVOPS"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Target Environment (tags) | `map(string)` | <pre>{<br/>  "default": "DEF",<br/>  "lab": "RND",<br/>  "prod": "PROD",<br/>  "staging": "STG"<br/>}</pre> | no |
| <a name="input_kms_env"></a> [kms\_env](#input\_kms\_env) | KMS Key Environment | `map(string)` | <pre>{<br/>  "lab": "RnD",<br/>  "prod": "Production",<br/>  "staging": "Staging"<br/>}</pre> | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | KMS Key References | `map(string)` | <pre>{<br/>  "default": "arn:aws:kms:ap-southeast-3:112233445566:key/4e8f681c-be57-406f-8265-5c4c13b243ac",<br/>  "lab": "arn:aws:kms:ap-southeast-3:112233445566:key/4e8f681c-be57-406f-8265-5c4c13b243ac",<br/>  "prod": "arn:aws:kms:ap-southeast-3:112233445566:key/4e8f681c-be57-406f-8265-5c4c13b243ac",<br/>  "staging": "arn:aws:kms:ap-southeast-3:112233445566:key/4e8f681c-be57-406f-8265-5c4c13b243ac"<br/>}</pre> | no |
| <a name="input_workspace_env"></a> [workspace\_env](#input\_workspace\_env) | Workspace Environment Selection | `map(string)` | <pre>{<br/>  "default": "default",<br/>  "lab": "rnd",<br/>  "prod": "prod",<br/>  "staging": "staging"<br/>}</pre> | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Workspace Environment Name | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_athena_database"></a> [athena\_database](#output\_athena\_database) | Name of the Athena database for CloudTrail analysis |
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | ARN of the CloudTrail trail |
| <a name="output_cloudtrail_bucket"></a> [cloudtrail\_bucket](#output\_cloudtrail\_bucket) | Name of the S3 bucket storing CloudTrail logs |
| <a name="output_cloudtrail_kms_key_arn"></a> [cloudtrail\_kms\_key\_arn](#output\_cloudtrail\_kms\_key\_arn) | ARN of the KMS key used for CloudTrail encryption |
| <a name="output_cloudtrail_log_group"></a> [cloudtrail\_log\_group](#output\_cloudtrail\_log\_group) | Name of the CloudWatch Log Group for CloudTrail |
| <a name="output_cloudtrail_sns_topic_arn"></a> [cloudtrail\_sns\_topic\_arn](#output\_cloudtrail\_sns\_topic\_arn) | ARN of the SNS topic for CloudTrail alerts |
| <a name="output_cloudwatch_log_groups_sbeacon"></a> [cloudwatch\_log\_groups\_sbeacon](#output\_cloudwatch\_log\_groups\_sbeacon) | List of CloudWatch log groups for Lambda functions |
| <a name="output_cloudwatch_log_groups_svep"></a> [cloudwatch\_log\_groups\_svep](#output\_cloudwatch\_log\_groups\_svep) | List of CloudWatch log groups for Lambda functions |
| <a name="output_cloudwatch_monitoring_url"></a> [cloudwatch\_monitoring\_url](#output\_cloudwatch\_monitoring\_url) | URL for CloudWatch monitoring dashboard |
| <a name="output_cloudwatch_to_kinesis_role_arn"></a> [cloudwatch\_to\_kinesis\_role\_arn](#output\_cloudwatch\_to\_kinesis\_role\_arn) | The ARN of the IAM role used for CloudWatch to Kinesis integration |
| <a name="output_configuration_summary"></a> [configuration\_summary](#output\_configuration\_summary) | Summary of key configuration parameters |
| <a name="output_firehose_arn"></a> [firehose\_arn](#output\_firehose\_arn) | The ARN of the Kinesis Firehose delivery stream |
| <a name="output_firehose_name"></a> [firehose\_name](#output\_firehose\_name) | The name of the Kinesis Firehose delivery stream |
| <a name="output_firehose_role_arn"></a> [firehose\_role\_arn](#output\_firehose\_role\_arn) | The ARN of the IAM role used by Kinesis Firehose |
| <a name="output_kinesis_firehose_name"></a> [kinesis\_firehose\_name](#output\_kinesis\_firehose\_name) | Name of the Kinesis Firehose delivery stream |
| <a name="output_kinesis_stream_arn"></a> [kinesis\_stream\_arn](#output\_kinesis\_stream\_arn) | The ARN of the Kinesis stream |
| <a name="output_kinesis_stream_name"></a> [kinesis\_stream\_name](#output\_kinesis\_stream\_name) | The name of the Kinesis stream receiving CloudTrail logs |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the Lambda function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | The name of the Lambda function transforming CloudTrail logs |
| <a name="output_log_group_url"></a> [log\_group\_url](#output\_log\_group\_url) | URL for CloudWatch log group |
| <a name="output_metrics_url"></a> [metrics\_url](#output\_metrics\_url) | URL for CloudWatch metrics |
| <a name="output_opensearch_credentials"></a> [opensearch\_credentials](#output\_opensearch\_credentials) | OpenSearch access credentials |
| <a name="output_opensearch_dashboard_endpoint"></a> [opensearch\_dashboard\_endpoint](#output\_opensearch\_dashboard\_endpoint) | The domain-specific endpoint for OpenSearch Dashboards access |
| <a name="output_opensearch_dashboard_url"></a> [opensearch\_dashboard\_url](#output\_opensearch\_dashboard\_url) | URL for OpenSearch Dashboards access |
| <a name="output_opensearch_domain_arn"></a> [opensearch\_domain\_arn](#output\_opensearch\_domain\_arn) | The ARN of the OpenSearch domain |
| <a name="output_opensearch_domain_endpoint"></a> [opensearch\_domain\_endpoint](#output\_opensearch\_domain\_endpoint) | The domain-specific endpoint used to submit index, search, and data upload requests to OpenSearch |
| <a name="output_opensearch_domain_name"></a> [opensearch\_domain\_name](#output\_opensearch\_domain\_name) | The name of the OpenSearch domain |
| <a name="output_opensearch_endpoint"></a> [opensearch\_endpoint](#output\_opensearch\_endpoint) | Domain-specific endpoint used to submit index, search, and data upload requests |
| <a name="output_opensearch_master_user"></a> [opensearch\_master\_user](#output\_opensearch\_master\_user) | OpenSearch master username |
| <a name="output_opensearch_monitoring_url"></a> [opensearch\_monitoring\_url](#output\_opensearch\_monitoring\_url) | URL for OpenSearch monitoring dashboard |
| <a name="output_opensearch_password_parameter"></a> [opensearch\_password\_parameter](#output\_opensearch\_password\_parameter) | SSM Parameter name storing the OpenSearch master password |
| <a name="output_password_retrieval_command"></a> [password\_retrieval\_command](#output\_password\_retrieval\_command) | AWS CLI command to retrieve the OpenSearch password |
| <a name="output_vpc_security_group_id"></a> [vpc\_security\_group\_id](#output\_vpc\_security\_group\_id) | The ID of the security group used for OpenSearch VPC access |
<!-- END_TF_DOCS -->
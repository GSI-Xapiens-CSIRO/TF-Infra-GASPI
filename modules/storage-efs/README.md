# Terraform Module Storage EFS

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_dashboard.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_metric_alarm.burst_credit_balance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.client_connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.io_limit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.storage_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_efs_access_point.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_backup_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_replication_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_replication_configuration) | resource |
| [aws_security_group.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_point_gid"></a> [access\_point\_gid](#input\_access\_point\_gid) | POSIX group ID for access point | `number` | `1000` | no |
| <a name="input_access_point_path"></a> [access\_point\_path](#input\_access\_point\_path) | Path for the access point root directory | `string` | `"data"` | no |
| <a name="input_access_point_uid"></a> [access\_point\_uid](#input\_access\_point\_uid) | POSIX user ID for access point | `number` | `1000` | no |
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | AWS Access Key | `string` | `""` | no |
| <a name="input_aws_account_id_destination"></a> [aws\_account\_id\_destination](#input\_aws\_account\_id\_destination) | The AWS Account ID to deploy the Budget in | `string` | n/a | yes |
| <a name="input_aws_account_id_source"></a> [aws\_account\_id\_source](#input\_aws\_account\_id\_source) | The AWS Account ID management | `string` | n/a | yes |
| <a name="input_aws_account_profile_destination"></a> [aws\_account\_profile\_destination](#input\_aws\_account\_profile\_destination) | AWS Profile destination to manage AWS resources | `string` | n/a | yes |
| <a name="input_aws_account_profile_source"></a> [aws\_account\_profile\_source](#input\_aws\_account\_profile\_source) | AWS Profile source to manage AWS resources | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | AWS Secret Key | `string` | `""` | no |
| <a name="input_burst_credit_threshold"></a> [burst\_credit\_threshold](#input\_burst\_credit\_threshold) | The threshold for EFS burst credit balance | `number` | `60000000000` | no |
| <a name="input_client_connections_threshold"></a> [client\_connections\_threshold](#input\_client\_connections\_threshold) | The threshold for number of client connections | `number` | `100` | no |
| <a name="input_create_access_point"></a> [create\_access\_point](#input\_create\_access\_point) | Whether to create an access point | `bool` | `false` | no |
| <a name="input_create_dashboard"></a> [create\_dashboard](#input\_create\_dashboard) | Whether to create a CloudWatch dashboard for EFS metrics | `bool` | `true` | no |
| <a name="input_department"></a> [department](#input\_department) | Department Owner | `string` | n/a | yes |
| <a name="input_enable_backup"></a> [enable\_backup](#input\_enable\_backup) | Enable EFS backup policy | `bool` | `true` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Enable EFS replication | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Target Environment (tags) | `map(string)` | n/a | yes |
| <a name="input_io_limit_threshold"></a> [io\_limit\_threshold](#input\_io\_limit\_threshold) | The threshold for EFS IO limit percentage | `number` | `80` | no |
| <a name="input_kms_env"></a> [kms\_env](#input\_kms\_env) | KMS Key Environment | `map(string)` | n/a | yes |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | KMS Key References | `map(string)` | n/a | yes |
| <a name="input_performance_mode"></a> [performance\_mode](#input\_performance\_mode) | Performance mode of the file system (generalPurpose or maxIO) | `string` | `"generalPurpose"` | no |
| <a name="input_prefix_name"></a> [prefix\_name](#input\_prefix\_name) | Global Prefix Name | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs for mount targets | `list(string)` | n/a | yes |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned\_throughput\_in\_mibps](#input\_provisioned\_throughput\_in\_mibps) | Provisioned throughput in MiB/s (required if throughput\_mode is provisioned) | `number` | `null` | no |
| <a name="input_replication_destination_region"></a> [replication\_destination\_region](#input\_replication\_destination\_region) | Destination region for EFS replication | `string` | `null` | no |
| <a name="input_replication_kms_key_id"></a> [replication\_kms\_key\_id](#input\_replication\_kms\_key\_id) | KMS key ID for replication destination | `string` | `null` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of the SNS topic for CloudWatch alarms | `string` | n/a | yes |
| <a name="input_storage_bytes_threshold"></a> [storage\_bytes\_threshold](#input\_storage\_bytes\_threshold) | The threshold for EFS storage usage in bytes | `number` | `1000000000000` | no |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | Throughput mode of the file system (bursting, provisioned, or elastic) | `string` | `"bursting"` | no |
| <a name="input_transition_to_ia"></a> [transition\_to\_ia](#input\_transition\_to\_ia) | Lifecycle policy transition to IA (AFTER\_7\_DAYS, AFTER\_14\_DAYS, AFTER\_30\_DAYS, AFTER\_60\_DAYS, or AFTER\_90\_DAYS) | `string` | `null` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR block | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where EFS will be deployed | `string` | n/a | yes |
| <a name="input_workspace_env"></a> [workspace\_env](#input\_workspace\_env) | Workspace Environment Selection | `map(string)` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Workspace Environment Name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_point_id"></a> [access\_point\_id](#output\_access\_point\_id) | ID of the EFS access point |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | DNS name of the EFS file system |
| <a name="output_efs_arn"></a> [efs\_arn](#output\_efs\_arn) | The ARN of the EFS file system |
| <a name="output_efs_id"></a> [efs\_id](#output\_efs\_id) | The ID of the EFS file system |
| <a name="output_mount_target_ips"></a> [mount\_target\_ips](#output\_mount\_target\_ips) | List of mount target IPs |
| <a name="output_mount_targets"></a> [mount\_targets](#output\_mount\_targets) | List of mount target IDs |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the EFS security group |
<!-- END_TF_DOCS -->
# Terraform Module Core Machine Learning Infrastructure with NAT & Firewall

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
| <a name="provider_aws.destination"></a> [aws.destination](#provider\_aws.destination) | 6.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat_gateway_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_policy.sagemaker_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.sagemaker_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.sagemaker_execution_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_kms_alias.s3_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.sagemaker_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.s3_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.sagemaker_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_networkfirewall_firewall.network_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall) | resource |
| [aws_networkfirewall_firewall_policy.network_firewall_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.domain_allow_stateful](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_route.firewall_egress_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.igw_ingress_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.nat_gateway_egress_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.sagemaker_egress_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.firewall_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.igw_ec2_rt_public_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.igw_ec2_rt_public_b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.igw_ec2_rt_public_c](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.igw_ingress_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.nat_gateway_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.sagemaker_studio_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.firewall_subnet_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.igw_ec2_rt_public_1a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.igw_ec2_rt_public_1b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.igw_ec2_rt_public_1c](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.igw_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.nat_gateway_subnet_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sagemaker_studio_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.data_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.model_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.data_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.model_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.data_bucket_pab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.model_bucket_pab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.data_bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.model_bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_sagemaker_app.data_science_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_app) | resource |
| [aws_sagemaker_app.data_wrangler_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_app) | resource |
| [aws_sagemaker_app.jupyter_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_app) | resource |
| [aws_sagemaker_domain.sagemaker_studio_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_domain) | resource |
| [aws_sagemaker_user_profile.sagemaker_user_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_user_profile) | resource |
| [aws_security_group.sagemaker_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_endpoints_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.sagemaker_self_reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.ec2_private_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.ec2_private_b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.ec2_private_c](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.ec2_public_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.ec2_public_b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.ec2_public_c](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.firewall_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.nat_gateway_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sagemaker_studio_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.infra_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecr_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecr_dkr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sagemaker_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sagemaker_notebook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sagemaker_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_email_addresses"></a> [alert\_email\_addresses](#input\_alert\_email\_addresses) | List of email addresses for security alerts | `list(string)` | `[]` | no |
| <a name="input_allow_ssh_from_anywhere"></a> [allow\_ssh\_from\_anywhere](#input\_allow\_ssh\_from\_anywhere) | Allow SSH access from anywhere (DANGEROUS - only for testing) | `bool` | `false` | no |
| <a name="input_allowed_domains"></a> [allowed\_domains](#input\_allowed\_domains) | List of allowed domains for ML workloads (domain allowlist) | `list(string)` | <pre>[<br/>  ".amazonaws.com",<br/>  ".anaconda.com",<br/>  ".anaconda.org",<br/>  ".pypi.org",<br/>  ".pythonhosted.org",<br/>  ".conda.io",<br/>  ".continuum.io",<br/>  ".github.com",<br/>  ".githubusercontent.com",<br/>  ".huggingface.co",<br/>  ".kaggle.com",<br/>  ".pytorch.org",<br/>  ".tensorflow.org",<br/>  ".jupyter.org",<br/>  ".scipy.org",<br/>  ".numpy.org"<br/>]</pre> | no |
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | The AWS Access Key (use with caution, prefer IAM roles) | `string` | `""` | no |
| <a name="input_aws_account_id_destination"></a> [aws\_account\_id\_destination](#input\_aws\_account\_id\_destination) | The AWS Account ID to deploy the infrastructure in | `string` | n/a | yes |
| <a name="input_aws_account_id_source"></a> [aws\_account\_id\_source](#input\_aws\_account\_id\_source) | The AWS Account ID for management/source account | `string` | n/a | yes |
| <a name="input_aws_account_profile_destination"></a> [aws\_account\_profile\_destination](#input\_aws\_account\_profile\_destination) | The AWS CLI profile to deploy the infrastructure with | `string` | n/a | yes |
| <a name="input_aws_account_profile_source"></a> [aws\_account\_profile\_source](#input\_aws\_account\_profile\_source) | The AWS CLI profile for management/source account | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy the VPC and resources in | `string` | n/a | yes |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | The AWS Secret Key (use with caution, prefer IAM roles) | `string` | `""` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Retention period for automated backups | `number` | `7` | no |
| <a name="input_blocked_domains"></a> [blocked\_domains](#input\_blocked\_domains) | List of explicitly blocked domains for data exfiltration prevention | `list(string)` | <pre>[<br/>  ".dropbox.com",<br/>  ".box.com",<br/>  ".onedrive.com",<br/>  ".googledrive.com",<br/>  ".icloud.com",<br/>  ".mega.nz",<br/>  ".mediafire.com",<br/>  ".rapidshare.com",<br/>  ".sendspace.com",<br/>  ".wetransfer.com",<br/>  ".fileserve.com",<br/>  ".4shared.com",<br/>  ".telegram.org",<br/>  ".whatsapp.com",<br/>  ".slack.com",<br/>  ".discord.com",<br/>  ".teams.microsoft.com",<br/>  ".gitlab.com",<br/>  ".bitbucket.org",<br/>  ".sourceforge.net",<br/>  ".pastebin.com",<br/>  ".hastebin.com",<br/>  ".ghostbin.co",<br/>  ".termbin.com"<br/>]</pre> | no |
| <a name="input_compliance_framework"></a> [compliance\_framework](#input\_compliance\_framework) | Compliance framework requirements (affects security settings) | `list(string)` | <pre>[<br/>  "general"<br/>]</pre> | no |
| <a name="input_coreinfra"></a> [coreinfra](#input\_coreinfra) | Core Infrastructure Name Prefix | `string` | `"gxc-tf-mgmt"` | no |
| <a name="input_custom_firewall_rules"></a> [custom\_firewall\_rules](#input\_custom\_firewall\_rules) | Custom firewall rules for specific organizational requirements | <pre>list(object({<br/>    name        = string<br/>    priority    = number<br/>    action      = string<br/>    protocol    = string<br/>    source_port = string<br/>    dest_port   = string<br/>    content     = optional(string)<br/>    description = string<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | Additional custom tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | Data classification level for tagging and compliance | `string` | `"confidential"` | no |
| <a name="input_department"></a> [department](#input\_department) | Department Owner for resource tagging | `string` | `"DEVOPS"` | no |
| <a name="input_ec2_prefix"></a> [ec2\_prefix](#input\_ec2\_prefix) | EC2 Prefix Name | `string` | `"ec2"` | no |
| <a name="input_ec2_private_a"></a> [ec2\_private\_a](#input\_ec2\_private\_a) | Private Subnet for EC2 Zone A | `map(string)` | <pre>{<br/>  "default": "10.16.16.0/21",<br/>  "lab": "10.16.16.0/21",<br/>  "nonprod": "10.32.16.0/21",<br/>  "prod": "10.48.16.0/21",<br/>  "staging": "10.32.16.0/21"<br/>}</pre> | no |
| <a name="input_ec2_private_b"></a> [ec2\_private\_b](#input\_ec2\_private\_b) | Private Subnet for EC2 Zone B | `map(string)` | <pre>{<br/>  "default": "10.16.24.0/21",<br/>  "lab": "10.16.24.0/21",<br/>  "nonprod": "10.32.24.0/21",<br/>  "prod": "10.48.24.0/21",<br/>  "staging": "10.32.24.0/21"<br/>}</pre> | no |
| <a name="input_ec2_private_c"></a> [ec2\_private\_c](#input\_ec2\_private\_c) | Private Subnet for EC2 Zone C | `map(string)` | <pre>{<br/>  "default": "10.16.32.0/21",<br/>  "lab": "10.16.32.0/21",<br/>  "nonprod": "10.32.32.0/21",<br/>  "prod": "10.48.32.0/21",<br/>  "staging": "10.32.32.0/21"<br/>}</pre> | no |
| <a name="input_ec2_public_a"></a> [ec2\_public\_a](#input\_ec2\_public\_a) | Public Subnet for EC2 Zone A | `map(string)` | <pre>{<br/>  "default": "10.16.40.0/21",<br/>  "lab": "10.16.40.0/21",<br/>  "nonprod": "10.32.40.0/21",<br/>  "prod": "10.48.40.0/21",<br/>  "staging": "10.32.40.0/21"<br/>}</pre> | no |
| <a name="input_ec2_public_b"></a> [ec2\_public\_b](#input\_ec2\_public\_b) | Public Subnet for EC2 Zone B | `map(string)` | <pre>{<br/>  "default": "10.16.48.0/21",<br/>  "lab": "10.16.48.0/21",<br/>  "nonprod": "10.32.48.0/21",<br/>  "prod": "10.48.48.0/21",<br/>  "staging": "10.32.48.0/21"<br/>}</pre> | no |
| <a name="input_ec2_public_c"></a> [ec2\_public\_c](#input\_ec2\_public\_c) | Public Subnet for EC2 Zone C | `map(string)` | <pre>{<br/>  "default": "10.16.56.0/21",<br/>  "lab": "10.16.56.0/21",<br/>  "nonprod": "10.32.56.0/21",<br/>  "prod": "10.48.56.0/21",<br/>  "staging": "10.32.56.0/21"<br/>}</pre> | no |
| <a name="input_ec2_rt_prefix"></a> [ec2\_rt\_prefix](#input\_ec2\_rt\_prefix) | EC2 Routing Table Prefix Name | `string` | `"ec2-rt"` | no |
| <a name="input_enable_cross_region_backup"></a> [enable\_cross\_region\_backup](#input\_enable\_cross\_region\_backup) | Enable cross-region backup for critical resources | `bool` | `false` | no |
| <a name="input_enable_data_loss_prevention"></a> [enable\_data\_loss\_prevention](#input\_enable\_data\_loss\_prevention) | Enable advanced data loss prevention rules and monitoring | `bool` | `true` | no |
| <a name="input_enable_debug_logging"></a> [enable\_debug\_logging](#input\_enable\_debug\_logging) | Enable debug logging for troubleshooting (disable in production) | `bool` | `false` | no |
| <a name="input_enable_encryption_at_rest"></a> [enable\_encryption\_at\_rest](#input\_enable\_encryption\_at\_rest) | Enable encryption at rest for all supported resources | `bool` | `true` | no |
| <a name="input_enable_encryption_in_transit"></a> [enable\_encryption\_in\_transit](#input\_enable\_encryption\_in\_transit) | Enforce encryption in transit for all communications | `bool` | `true` | no |
| <a name="input_enable_ml_monitoring"></a> [enable\_ml\_monitoring](#input\_enable\_ml\_monitoring) | Enable enhanced monitoring and logging for ML workloads | `bool` | `true` | no |
| <a name="input_enable_network_firewall"></a> [enable\_network\_firewall](#input\_enable\_network\_firewall) | Enable AWS Network Firewall for ML security and data loss prevention | `bool` | `false` | no |
| <a name="input_enable_sagemaker_studio"></a> [enable\_sagemaker\_studio](#input\_enable\_sagemaker\_studio) | Enable Amazon SageMaker Studio deployment with VPC-only access | `bool` | `false` | no |
| <a name="input_enable_security_notifications"></a> [enable\_security\_notifications](#input\_enable\_security\_notifications) | Enable security event notifications via SNS | `bool` | `true` | no |
| <a name="input_enable_vpc_flow_logs"></a> [enable\_vpc\_flow\_logs](#input\_enable\_vpc\_flow\_logs) | Enable VPC Flow Logs for network monitoring | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Target Environment mapping for resource tags | `map(string)` | <pre>{<br/>  "default": "DEF",<br/>  "lab": "RND",<br/>  "nonprod": "NONPROD",<br/>  "prod": "PROD",<br/>  "staging": "STG"<br/>}</pre> | no |
| <a name="input_firewall_deletion_protection"></a> [firewall\_deletion\_protection](#input\_firewall\_deletion\_protection) | Enable deletion protection for Network Firewall | `bool` | `true` | no |
| <a name="input_firewall_log_retention_days"></a> [firewall\_log\_retention\_days](#input\_firewall\_log\_retention\_days) | CloudWatch log retention period for firewall logs | `number` | `30` | no |
| <a name="input_firewall_prefix"></a> [firewall\_prefix](#input\_firewall\_prefix) | Network Firewall Prefix Name | `string` | `"firewall"` | no |
| <a name="input_firewall_rt_prefix"></a> [firewall\_rt\_prefix](#input\_firewall\_rt\_prefix) | Firewall Routing Table Prefix Name | `string` | `"firewall-rt"` | no |
| <a name="input_firewall_subnet_a"></a> [firewall\_subnet\_a](#input\_firewall\_subnet\_a) | Network Firewall Subnet Zone A | `map(string)` | <pre>{<br/>  "default": "10.16.80.0/24",<br/>  "lab": "10.16.80.0/24",<br/>  "nonprod": "10.32.80.0/24",<br/>  "prod": "10.48.80.0/24",<br/>  "staging": "10.32.80.0/24"<br/>}</pre> | no |
| <a name="input_firewall_subnet_b"></a> [firewall\_subnet\_b](#input\_firewall\_subnet\_b) | Network Firewall Subnet Zone B | `map(string)` | <pre>{<br/>  "default": "10.16.81.0/24",<br/>  "lab": "10.16.81.0/24",<br/>  "nonprod": "10.32.81.0/24",<br/>  "prod": "10.48.81.0/24",<br/>  "staging": "10.32.81.0/24"<br/>}</pre> | no |
| <a name="input_firewall_subnet_c"></a> [firewall\_subnet\_c](#input\_firewall\_subnet\_c) | Network Firewall Subnet Zone C | `map(string)` | <pre>{<br/>  "default": "10.16.82.0/24",<br/>  "lab": "10.16.82.0/24",<br/>  "nonprod": "10.32.82.0/24",<br/>  "prod": "10.48.82.0/24",<br/>  "staging": "10.32.82.0/24"<br/>}</pre> | no |
| <a name="input_firewall_subnet_cidr"></a> [firewall\_subnet\_cidr](#input\_firewall\_subnet\_cidr) | Network Firewall subnet CIDR | `map(string)` | <pre>{<br/>  "default": "10.16.1.0/24",<br/>  "lab": "10.16.1.0/24",<br/>  "nonprod": "10.32.1.0/24",<br/>  "prod": "10.48.1.0/24",<br/>  "staging": "10.32.1.0/24"<br/>}</pre> | no |
| <a name="input_igw_prefix"></a> [igw\_prefix](#input\_igw\_prefix) | IGW Prefix Name | `string` | `"igw"` | no |
| <a name="input_igw_rt_prefix"></a> [igw\_rt\_prefix](#input\_igw\_rt\_prefix) | IGW Routing Table Prefix Name | `string` | `"igw-rt"` | no |
| <a name="input_kms_env"></a> [kms\_env](#input\_kms\_env) | KMS Key Environment mapping | `map(string)` | <pre>{<br/>  "lab": "RnD",<br/>  "nonprod": "NonProduction",<br/>  "prod": "Production",<br/>  "staging": "Staging"<br/>}</pre> | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | KMS Key References for encryption | `map(string)` | n/a | yes |
| <a name="input_nat_ec2_prefix"></a> [nat\_ec2\_prefix](#input\_nat\_ec2\_prefix) | NAT EC2 Prefix Name | `string` | `"natgw_ec2"` | no |
| <a name="input_nat_gateway_count"></a> [nat\_gateway\_count](#input\_nat\_gateway\_count) | Number of NAT Gateways to deploy (1-3, affects availability and cost) | `number` | `3` | no |
| <a name="input_nat_gateway_subnet_cidr"></a> [nat\_gateway\_subnet\_cidr](#input\_nat\_gateway\_subnet\_cidr) | NAT Gateway subnet CIDR | `map(string)` | <pre>{<br/>  "default": "10.16.2.0/24",<br/>  "lab": "10.16.2.0/24",<br/>  "nonprod": "10.32.2.0/24",<br/>  "prod": "10.48.2.0/24",<br/>  "staging": "10.32.2.0/24"<br/>}</pre> | no |
| <a name="input_nat_prefix"></a> [nat\_prefix](#input\_nat\_prefix) | NAT Prefix Name | `string` | `"nat"` | no |
| <a name="input_nat_public_a"></a> [nat\_public\_a](#input\_nat\_public\_a) | NAT Gateway Public Subnet Zone A | `map(string)` | <pre>{<br/>  "default": "10.16.88.0/24",<br/>  "lab": "10.16.88.0/24",<br/>  "nonprod": "10.32.88.0/24",<br/>  "prod": "10.48.88.0/24",<br/>  "staging": "10.32.88.0/24"<br/>}</pre> | no |
| <a name="input_nat_public_b"></a> [nat\_public\_b](#input\_nat\_public\_b) | NAT Gateway Public Subnet Zone B | `map(string)` | <pre>{<br/>  "default": "10.16.89.0/24",<br/>  "lab": "10.16.89.0/24",<br/>  "nonprod": "10.32.89.0/24",<br/>  "prod": "10.48.89.0/24",<br/>  "staging": "10.32.89.0/24"<br/>}</pre> | no |
| <a name="input_nat_public_c"></a> [nat\_public\_c](#input\_nat\_public\_c) | NAT Gateway Public Subnet Zone C | `map(string)` | <pre>{<br/>  "default": "10.16.90.0/24",<br/>  "lab": "10.16.90.0/24",<br/>  "nonprod": "10.32.90.0/24",<br/>  "prod": "10.48.90.0/24",<br/>  "staging": "10.32.90.0/24"<br/>}</pre> | no |
| <a name="input_nat_rt_prefix"></a> [nat\_rt\_prefix](#input\_nat\_rt\_prefix) | NAT Routing Table Prefix Name | `string` | `"nat-rt"` | no |
| <a name="input_peer_owner_id"></a> [peer\_owner\_id](#input\_peer\_owner\_id) | Core Infrastrucre VPC Peers Owner ID | `map(string)` | <pre>{<br/>  "default": "1234567890",<br/>  "lab": "1234567890",<br/>  "nonprod": "1234567890",<br/>  "prod": "0987654321",<br/>  "staging": "1234567890"<br/>}</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for CloudFormation compatibility | `string` | `""` | no |
| <a name="input_propagating_vgws"></a> [propagating\_vgws](#input\_propagating\_vgws) | Core Infrastrucre VPC Gateway Propagating | `map(string)` | <pre>{<br/>  "default": "vgw-1234567890",<br/>  "lab": "vgw-1234567890",<br/>  "nonprod": "vgw-1234567890",<br/>  "prod": "vgw-0987654321",<br/>  "staging": "vgw-1234567890"<br/>}</pre> | no |
| <a name="input_resource_naming_prefix"></a> [resource\_naming\_prefix](#input\_resource\_naming\_prefix) | Additional prefix for resource naming (useful for multi-tenant deployments) | `string` | `""` | no |
| <a name="input_sagemaker_default_instance_type"></a> [sagemaker\_default\_instance\_type](#input\_sagemaker\_default\_instance\_type) | Default instance type for SageMaker Studio notebooks | `string` | `"ml.t3.medium"` | no |
| <a name="input_sagemaker_domain_name"></a> [sagemaker\_domain\_name](#input\_sagemaker\_domain\_name) | Name for the SageMaker Studio Domain | `string` | `"secure-ml-domain"` | no |
| <a name="input_sagemaker_execution_role_name"></a> [sagemaker\_execution\_role\_name](#input\_sagemaker\_execution\_role\_name) | Name for the SageMaker execution role | `string` | `"SageMakerExecutionRole"` | no |
| <a name="input_sagemaker_prefix"></a> [sagemaker\_prefix](#input\_sagemaker\_prefix) | SageMaker Prefix Name | `string` | `"sagemaker"` | no |
| <a name="input_sagemaker_private_a"></a> [sagemaker\_private\_a](#input\_sagemaker\_private\_a) | Private Subnet for SageMaker Zone A | `map(string)` | <pre>{<br/>  "default": "10.16.8.0/21",<br/>  "lab": "10.16.8.0/21",<br/>  "nonprod": "10.32.8.0/21",<br/>  "prod": "10.48.8.0/21",<br/>  "staging": "10.32.8.0/21"<br/>}</pre> | no |
| <a name="input_sagemaker_private_b"></a> [sagemaker\_private\_b](#input\_sagemaker\_private\_b) | Private Subnet for SageMaker Zone B | `map(string)` | <pre>{<br/>  "default": "10.16.64.0/21",<br/>  "lab": "10.16.64.0/21",<br/>  "nonprod": "10.32.64.0/21",<br/>  "prod": "10.48.64.0/21",<br/>  "staging": "10.32.64.0/21"<br/>}</pre> | no |
| <a name="input_sagemaker_private_c"></a> [sagemaker\_private\_c](#input\_sagemaker\_private\_c) | Private Subnet for SageMaker Zone C | `map(string)` | <pre>{<br/>  "default": "10.16.72.0/21",<br/>  "lab": "10.16.72.0/21",<br/>  "nonprod": "10.32.72.0/21",<br/>  "prod": "10.48.72.0/21",<br/>  "staging": "10.32.72.0/21"<br/>}</pre> | no |
| <a name="input_sagemaker_rt_prefix"></a> [sagemaker\_rt\_prefix](#input\_sagemaker\_rt\_prefix) | SageMaker Routing Table Prefix Name | `string` | `"sagemaker-rt"` | no |
| <a name="input_sagemaker_subnet_cidr"></a> [sagemaker\_subnet\_cidr](#input\_sagemaker\_subnet\_cidr) | SageMaker Studio subnet CIDR | `map(string)` | <pre>{<br/>  "default": "10.16.3.0/24",<br/>  "lab": "10.16.3.0/24",<br/>  "nonprod": "10.32.3.0/24",<br/>  "prod": "10.48.3.0/24",<br/>  "staging": "10.32.3.0/24"<br/>}</pre> | no |
| <a name="input_sagemaker_user_profile_name"></a> [sagemaker\_user\_profile\_name](#input\_sagemaker\_user\_profile\_name) | Default user profile name for SageMaker Studio | `string` | `"ml-user"` | no |
| <a name="input_single_az_deployment"></a> [single\_az\_deployment](#input\_single\_az\_deployment) | Deploy in single AZ to reduce costs (not recommended for production) | `bool` | `false` | no |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | Slack webhook URL for security notifications (optional) | `string` | `""` | no |
| <a name="input_start_kernel_gateway_apps"></a> [start\_kernel\_gateway\_apps](#input\_start\_kernel\_gateway\_apps) | Start the KernelGateway Apps (Data Science and Data Wrangler) | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Core Infrastructure CIDR Block | `map(string)` | <pre>{<br/>  "default": "10.16.0.0/16",<br/>  "lab": "10.16.0.0/16",<br/>  "nonprod": "10.32.0.0/16",<br/>  "prod": "10.48.0.0/16",<br/>  "staging": "10.32.0.0/16"<br/>}</pre> | no |
| <a name="input_vpc_flow_logs_retention_days"></a> [vpc\_flow\_logs\_retention\_days](#input\_vpc\_flow\_logs\_retention\_days) | CloudWatch log retention period for VPC Flow Logs | `number` | `14` | no |
| <a name="input_vpc_peer"></a> [vpc\_peer](#input\_vpc\_peer) | Core Infrastrucre VPC Peers ID | `map(string)` | <pre>{<br/>  "default": "vpc-1234567890",<br/>  "lab": "vpc-1234567890",<br/>  "nonprod": "vpc-1234567890",<br/>  "prod": "vpc-0987654321",<br/>  "staging": "vpc-1234567890"<br/>}</pre> | no |
| <a name="input_workspace_env"></a> [workspace\_env](#input\_workspace\_env) | Workspace Environment Selection mapping | `map(string)` | <pre>{<br/>  "default": "default",<br/>  "lab": "rnd",<br/>  "nonprod": "nonprod",<br/>  "prod": "prod",<br/>  "staging": "staging"<br/>}</pre> | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Workspace Environment Name | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_bucket_name"></a> [data\_bucket\_name](#output\_data\_bucket\_name) | Name of S3 bucket for data |
| <a name="output_ec2_private_1a"></a> [ec2\_private\_1a](#output\_ec2\_private\_1a) | Private Subnet EC2 Zone A |
| <a name="output_ec2_private_1a_cidr"></a> [ec2\_private\_1a\_cidr](#output\_ec2\_private\_1a\_cidr) | Private Subnet EC2 CIDR Block of Zone A |
| <a name="output_ec2_private_1b"></a> [ec2\_private\_1b](#output\_ec2\_private\_1b) | Private Subnet EC2 Zone B |
| <a name="output_ec2_private_1b_cidr"></a> [ec2\_private\_1b\_cidr](#output\_ec2\_private\_1b\_cidr) | Private Subnet EC2 CIDR Block of Zone B |
| <a name="output_ec2_private_1c"></a> [ec2\_private\_1c](#output\_ec2\_private\_1c) | Private Subnet EC2 Zone C |
| <a name="output_ec2_private_1c_cidr"></a> [ec2\_private\_1c\_cidr](#output\_ec2\_private\_1c\_cidr) | Private Subnet EC2 CIDR Block of Zone C |
| <a name="output_ec2_public_1a"></a> [ec2\_public\_1a](#output\_ec2\_public\_1a) | Public Subnet EC2 Zone A |
| <a name="output_ec2_public_1a_cidr"></a> [ec2\_public\_1a\_cidr](#output\_ec2\_public\_1a\_cidr) | Public Subnet EC2 CIDR Block of Zone A |
| <a name="output_ec2_public_1b"></a> [ec2\_public\_1b](#output\_ec2\_public\_1b) | Public Subnet EC2 Zone B |
| <a name="output_ec2_public_1b_cidr"></a> [ec2\_public\_1b\_cidr](#output\_ec2\_public\_1b\_cidr) | Public Subnet EC2 CIDR Block of Zone B |
| <a name="output_ec2_public_1c"></a> [ec2\_public\_1c](#output\_ec2\_public\_1c) | Public Subnet EC2 Zone C |
| <a name="output_ec2_public_1c_cidr"></a> [ec2\_public\_1c\_cidr](#output\_ec2\_public\_1c\_cidr) | Public Subnet EC2 CIDR Block of Zone C |
| <a name="output_firewall_alert_log_group"></a> [firewall\_alert\_log\_group](#output\_firewall\_alert\_log\_group) | Network Firewall Alert Log Group Name |
| <a name="output_firewall_endpoints"></a> [firewall\_endpoints](#output\_firewall\_endpoints) | Network Firewall Endpoint IDs by AZ |
| <a name="output_firewall_flow_log_group"></a> [firewall\_flow\_log\_group](#output\_firewall\_flow\_log\_group) | Network Firewall Flow Log Group Name |
| <a name="output_firewall_policy_arn"></a> [firewall\_policy\_arn](#output\_firewall\_policy\_arn) | Network Firewall Policy ARN |
| <a name="output_firewall_subnet_1a"></a> [firewall\_subnet\_1a](#output\_firewall\_subnet\_1a) | Network Firewall Subnet Zone A |
| <a name="output_firewall_subnet_1b"></a> [firewall\_subnet\_1b](#output\_firewall\_subnet\_1b) | Network Firewall Subnet Zone B |
| <a name="output_firewall_subnet_1c"></a> [firewall\_subnet\_1c](#output\_firewall\_subnet\_1c) | Network Firewall Subnet Zone C |
| <a name="output_igw_route_table_id"></a> [igw\_route\_table\_id](#output\_igw\_route\_table\_id) | IGW route table ID |
| <a name="output_kms_key_ebs_arn"></a> [kms\_key\_ebs\_arn](#output\_kms\_key\_ebs\_arn) | KMS key arn for SageMaker notebooks EBS encryption |
| <a name="output_kms_key_s3_buckets_arn"></a> [kms\_key\_s3\_buckets\_arn](#output\_kms\_key\_s3\_buckets\_arn) | KMS key arn for data encryption in S3 buckets |
| <a name="output_ml_default_security_group_id"></a> [ml\_default\_security\_group\_id](#output\_ml\_default\_security\_group\_id) | ML Default Security Group ID |
| <a name="output_ml_nat_gateway_1a"></a> [ml\_nat\_gateway\_1a](#output\_ml\_nat\_gateway\_1a) | ML NAT Gateway Zone A |
| <a name="output_ml_nat_gateway_1b"></a> [ml\_nat\_gateway\_1b](#output\_ml\_nat\_gateway\_1b) | ML NAT Gateway Zone B |
| <a name="output_ml_nat_gateway_1c"></a> [ml\_nat\_gateway\_1c](#output\_ml\_nat\_gateway\_1c) | ML NAT Gateway Zone C |
| <a name="output_ml_security_config"></a> [ml\_security\_config](#output\_ml\_security\_config) | ML Security Configuration Status |
| <a name="output_model_bucket_name"></a> [model\_bucket\_name](#output\_model\_bucket\_name) | Name of S3 bucket for models |
| <a name="output_nat_gateway_route_table_id"></a> [nat\_gateway\_route\_table\_id](#output\_nat\_gateway\_route\_table\_id) | NAT Gateway route table ID |
| <a name="output_nat_gateway_subnet_cidr"></a> [nat\_gateway\_subnet\_cidr](#output\_nat\_gateway\_subnet\_cidr) | NAT Gateway subnet CIDR |
| <a name="output_network_firewall_arn"></a> [network\_firewall\_arn](#output\_network\_firewall\_arn) | Network Firewall ARN |
| <a name="output_network_firewall_endpoint_id"></a> [network\_firewall\_endpoint\_id](#output\_network\_firewall\_endpoint\_id) | Network Firewall VPC Endpoint ID |
| <a name="output_network_firewall_id"></a> [network\_firewall\_id](#output\_network\_firewall\_id) | Network Firewall ID |
| <a name="output_primary_availability_zone"></a> [primary\_availability\_zone](#output\_primary\_availability\_zone) | Primary availability zone for single-AZ deployment |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Project name used for resource naming |
| <a name="output_s3_gateway_endpoint_id"></a> [s3\_gateway\_endpoint\_id](#output\_s3\_gateway\_endpoint\_id) | S3 Gateway Endpoint ID |
| <a name="output_s3_vpc_endpoint_id"></a> [s3\_vpc\_endpoint\_id](#output\_s3\_vpc\_endpoint\_id) | The ID of the S3 VPC Endpoint |
| <a name="output_sagemaker_api_endpoint_id"></a> [sagemaker\_api\_endpoint\_id](#output\_sagemaker\_api\_endpoint\_id) | SageMaker API Endpoint ID |
| <a name="output_sagemaker_execution_role_arn"></a> [sagemaker\_execution\_role\_arn](#output\_sagemaker\_execution\_role\_arn) | IAM Execution role for SageMaker Studio and SageMaker notebooks |
| <a name="output_sagemaker_private_1a"></a> [sagemaker\_private\_1a](#output\_sagemaker\_private\_1a) | Private Subnet SageMaker Zone A |
| <a name="output_sagemaker_private_1a_cidr"></a> [sagemaker\_private\_1a\_cidr](#output\_sagemaker\_private\_1a\_cidr) | Private Subnet SageMaker CIDR Block of Zone A |
| <a name="output_sagemaker_private_1b"></a> [sagemaker\_private\_1b](#output\_sagemaker\_private\_1b) | Private Subnet SageMaker Zone B |
| <a name="output_sagemaker_private_1b_cidr"></a> [sagemaker\_private\_1b\_cidr](#output\_sagemaker\_private\_1b\_cidr) | Private Subnet SageMaker CIDR Block of Zone B |
| <a name="output_sagemaker_private_1c"></a> [sagemaker\_private\_1c](#output\_sagemaker\_private\_1c) | Private Subnet SageMaker Zone C |
| <a name="output_sagemaker_private_1c_cidr"></a> [sagemaker\_private\_1c\_cidr](#output\_sagemaker\_private\_1c\_cidr) | Private Subnet SageMaker CIDR Block of Zone C |
| <a name="output_sagemaker_runtime_endpoint_id"></a> [sagemaker\_runtime\_endpoint\_id](#output\_sagemaker\_runtime\_endpoint\_id) | SageMaker Runtime Endpoint ID |
| <a name="output_sagemaker_security_group_id"></a> [sagemaker\_security\_group\_id](#output\_sagemaker\_security\_group\_id) | The ID the SageMaker security group |
| <a name="output_sagemaker_studio_domain_id"></a> [sagemaker\_studio\_domain\_id](#output\_sagemaker\_studio\_domain\_id) | SageMaker Studio domain id |
| <a name="output_sagemaker_studio_endpoint_id"></a> [sagemaker\_studio\_endpoint\_id](#output\_sagemaker\_studio\_endpoint\_id) | SageMaker Studio Endpoint ID |
| <a name="output_sagemaker_studio_subnet_id"></a> [sagemaker\_studio\_subnet\_id](#output\_sagemaker\_studio\_subnet\_id) | The ID of the SageMaker subnet |
| <a name="output_summary"></a> [summary](#output\_summary) | Summary Core Infrastructure Configuration with ML Security |
| <a name="output_user_profile_name"></a> [user\_profile\_name](#output\_user\_profile\_name) | SageMaker user profile name |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC CIDR Block |
| <a name="output_vpc_endpoints_security_group_id"></a> [vpc\_endpoints\_security\_group\_id](#output\_vpc\_endpoints\_security\_group\_id) | VPC Endpoints Security Group ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of VPC where SageMaker Studio will reside |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | VPC Name |
<!-- END_TF_DOCS -->
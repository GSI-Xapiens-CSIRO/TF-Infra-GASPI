# Terraform Module Core Machine Learning Infrastructure with NAT & Firewall for 209479276142

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.72 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_core"></a> [core](#module\_core) | ../../../../modules//core-nat-ml | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | The AWS Access Key | `string` | `""` | no |
| <a name="input_aws_account_id_destination"></a> [aws\_account\_id\_destination](#input\_aws\_account\_id\_destination) | The AWS Account ID to deploy the Budget in | `string` | `"209479276142"` | no |
| <a name="input_aws_account_id_source"></a> [aws\_account\_id\_source](#input\_aws\_account\_id\_source) | The AWS Account ID management | `string` | `"463470956521"` | no |
| <a name="input_aws_account_profile_destination"></a> [aws\_account\_profile\_destination](#input\_aws\_account\_profile\_destination) | The AWS Profile to deploy the Budget in | `string` | `"GXC-TF-User-Executor-HUB02"` | no |
| <a name="input_aws_account_profile_source"></a> [aws\_account\_profile\_source](#input\_aws\_account\_profile\_source) | The AWS Profile management | `string` | `"GXC-TF-User-Executor"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy the VPC certificate in | `string` | `"ap-southeast-3"` | no |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | The AWS Secret Key | `string` | `""` | no |
| <a name="input_coreinfra"></a> [coreinfra](#input\_coreinfra) | Core Infrastrucre Name Prefix | `string` | `"gxc-tf-hub02"` | no |
| <a name="input_department"></a> [department](#input\_department) | Department Owner | `string` | `"DEVOPS"` | no |
| <a name="input_ec2_prefix"></a> [ec2\_prefix](#input\_ec2\_prefix) | EC2 Prefix Name | `string` | `"ec2"` | no |
| <a name="input_ec2_private_a"></a> [ec2\_private\_a](#input\_ec2\_private\_a) | Private Subnet for EC2 Zone A | `map(string)` | <pre>{<br/>  "default": "10.16.16.0/21",<br/>  "lab": "10.16.16.0/21",<br/>  "nonprod": "10.32.16.0/21",<br/>  "prod": "10.48.16.0/21",<br/>  "staging": "10.32.16.0/21"<br/>}</pre> | no |
| <a name="input_ec2_private_b"></a> [ec2\_private\_b](#input\_ec2\_private\_b) | Private Subnet for EC2 Zone B | `map(string)` | <pre>{<br/>  "default": "10.16.24.0/21",<br/>  "lab": "10.16.24.0/21",<br/>  "nonprod": "10.32.24.0/21",<br/>  "prod": "10.48.24.0/21",<br/>  "staging": "10.32.24.0/21"<br/>}</pre> | no |
| <a name="input_ec2_private_c"></a> [ec2\_private\_c](#input\_ec2\_private\_c) | Private Subnet for EC2 Zone C | `map(string)` | <pre>{<br/>  "default": "10.16.32.0/21",<br/>  "lab": "10.16.32.0/21",<br/>  "nonprod": "10.32.32.0/21",<br/>  "prod": "10.48.32.0/21",<br/>  "staging": "10.32.32.0/21"<br/>}</pre> | no |
| <a name="input_ec2_public_a"></a> [ec2\_public\_a](#input\_ec2\_public\_a) | Public Subnet for EC2 Zone A | `map(string)` | <pre>{<br/>  "default": "10.16.40.0/21",<br/>  "lab": "10.16.40.0/21",<br/>  "nonprod": "10.32.40.0/21",<br/>  "prod": "10.48.40.0/21",<br/>  "staging": "10.32.40.0/21"<br/>}</pre> | no |
| <a name="input_ec2_public_b"></a> [ec2\_public\_b](#input\_ec2\_public\_b) | Public Subnet for EC2 Zone B | `map(string)` | <pre>{<br/>  "default": "10.16.48.0/21",<br/>  "lab": "10.16.48.0/21",<br/>  "nonprod": "10.32.48.0/21",<br/>  "prod": "10.48.48.0/21",<br/>  "staging": "10.32.48.0/21"<br/>}</pre> | no |
| <a name="input_ec2_public_c"></a> [ec2\_public\_c](#input\_ec2\_public\_c) | Public Subnet for EC2 Zone C | `map(string)` | <pre>{<br/>  "default": "10.16.56.0/21",<br/>  "lab": "10.16.56.0/21",<br/>  "nonprod": "10.32.56.0/21",<br/>  "prod": "10.48.56.0/21",<br/>  "staging": "10.32.56.0/21"<br/>}</pre> | no |
| <a name="input_ec2_rt_prefix"></a> [ec2\_rt\_prefix](#input\_ec2\_rt\_prefix) | NAT EC2 Routing Table Prefix Name | `string` | `"ec2-rt"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Target Environment (tags) | `map(string)` | <pre>{<br/>  "default": "DEF",<br/>  "lab": "RND",<br/>  "nonprod": "NONPROD",<br/>  "prod": "PROD",<br/>  "staging": "STG"<br/>}</pre> | no |
| <a name="input_igw_prefix"></a> [igw\_prefix](#input\_igw\_prefix) | IGW Prefix Name | `string` | `"igw"` | no |
| <a name="input_igw_rt_prefix"></a> [igw\_rt\_prefix](#input\_igw\_rt\_prefix) | IGW Routing Table Prefix Name | `string` | `"igw-rt"` | no |
| <a name="input_kms_env"></a> [kms\_env](#input\_kms\_env) | KMS Key Environment | `map(string)` | <pre>{<br/>  "lab": "RnD",<br/>  "nonprod": "NonProduction",<br/>  "prod": "Production",<br/>  "staging": "Staging"<br/>}</pre> | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | KMS Key References | `map(string)` | <pre>{<br/>  "default": "arn:aws:kms:ap-southeast-3:463470956521:key/2abc18b5-ded4-4615-90ce-fc3c6ccfbb41",<br/>  "lab": "arn:aws:kms:ap-southeast-3:463470956521:key/2abc18b5-ded4-4615-90ce-fc3c6ccfbb41",<br/>  "prod": "arn:aws:kms:ap-southeast-3:463470956521:key/2abc18b5-ded4-4615-90ce-fc3c6ccfbb41",<br/>  "staging": "arn:aws:kms:ap-southeast-3:463470956521:key/2abc18b5-ded4-4615-90ce-fc3c6ccfbb41"<br/>}</pre> | no |
| <a name="input_nat_ec2_prefix"></a> [nat\_ec2\_prefix](#input\_nat\_ec2\_prefix) | NAT EC2 Prefix Name | `string` | `"natgw_ec2"` | no |
| <a name="input_nat_prefix"></a> [nat\_prefix](#input\_nat\_prefix) | NAT Prefix Name | `string` | `"nat"` | no |
| <a name="input_nat_rt_prefix"></a> [nat\_rt\_prefix](#input\_nat\_rt\_prefix) | NAT Routing Table Prefix Name | `string` | `"nat-rt"` | no |
| <a name="input_peer_owner_id"></a> [peer\_owner\_id](#input\_peer\_owner\_id) | Core Infrastrucre VPC Peers Owner ID | `map(string)` | <pre>{<br/>  "default": "1234567890",<br/>  "lab": "1234567890",<br/>  "nonprod": "1234567890",<br/>  "prod": "0987654321",<br/>  "staging": "1234567890"<br/>}</pre> | no |
| <a name="input_propagating_vgws"></a> [propagating\_vgws](#input\_propagating\_vgws) | Core Infrastrucre VPC Gateway Propagating | `map(string)` | <pre>{<br/>  "default": "vgw-1234567890",<br/>  "lab": "vgw-1234567890",<br/>  "nonprod": "vgw-1234567890",<br/>  "prod": "vgw-0987654321",<br/>  "staging": "vgw-1234567890"<br/>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Core Infrastrucre CIDR Block | `map(string)` | <pre>{<br/>  "default": "10.16.0.0/16",<br/>  "lab": "10.16.0.0/16",<br/>  "nonprod": "10.32.0.0/16",<br/>  "prod": "10.48.0.0/16",<br/>  "staging": "10.32.0.0/16"<br/>}</pre> | no |
| <a name="input_vpc_peer"></a> [vpc\_peer](#input\_vpc\_peer) | Core Infrastrucre VPC Peers ID | `map(string)` | <pre>{<br/>  "default": "vpc-1234567890",<br/>  "lab": "vpc-1234567890",<br/>  "nonprod": "vpc-1234567890",<br/>  "prod": "vpc-0987654321",<br/>  "staging": "vpc-1234567890"<br/>}</pre> | no |
| <a name="input_workspace_env"></a> [workspace\_env](#input\_workspace\_env) | Workspace Environment Selection | `map(string)` | <pre>{<br/>  "default": "default",<br/>  "lab": "rnd",<br/>  "nonprod": "nonprod",<br/>  "prod": "prod",<br/>  "staging": "staging"<br/>}</pre> | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Workspace Environment Name | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_private_subnets"></a> [all\_private\_subnets](#output\_all\_private\_subnets) | All private subnet IDs (EC2 + SageMaker) |
| <a name="output_all_public_subnets"></a> [all\_public\_subnets](#output\_all\_public\_subnets) | All public subnet IDs |
| <a name="output_all_security_groups"></a> [all\_security\_groups](#output\_all\_security\_groups) | All security group IDs created by the module |
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
| <a name="output_firewall_subnets"></a> [firewall\_subnets](#output\_firewall\_subnets) | Network Firewall subnet IDs |
| <a name="output_ml_default_security_group_id"></a> [ml\_default\_security\_group\_id](#output\_ml\_default\_security\_group\_id) | ML Default Security Group ID |
| <a name="output_ml_nat_gateway_1a"></a> [ml\_nat\_gateway\_1a](#output\_ml\_nat\_gateway\_1a) | ML NAT Gateway Zone A |
| <a name="output_ml_nat_gateway_1b"></a> [ml\_nat\_gateway\_1b](#output\_ml\_nat\_gateway\_1b) | ML NAT Gateway Zone B |
| <a name="output_ml_nat_gateway_1c"></a> [ml\_nat\_gateway\_1c](#output\_ml\_nat\_gateway\_1c) | ML NAT Gateway Zone C |
| <a name="output_ml_security_config"></a> [ml\_security\_config](#output\_ml\_security\_config) | ML Security Configuration Status |
| <a name="output_monitoring_info"></a> [monitoring\_info](#output\_monitoring\_info) | Monitoring and logging information |
| <a name="output_network_firewall_arn"></a> [network\_firewall\_arn](#output\_network\_firewall\_arn) | Network Firewall ARN |
| <a name="output_network_firewall_id"></a> [network\_firewall\_id](#output\_network\_firewall\_id) | Network Firewall ID |
| <a name="output_network_info"></a> [network\_info](#output\_network\_info) | Network information for dependent modules |
| <a name="output_s3_gateway_endpoint_id"></a> [s3\_gateway\_endpoint\_id](#output\_s3\_gateway\_endpoint\_id) | S3 Gateway Endpoint ID |
| <a name="output_sagemaker_api_endpoint_id"></a> [sagemaker\_api\_endpoint\_id](#output\_sagemaker\_api\_endpoint\_id) | SageMaker API Endpoint ID |
| <a name="output_sagemaker_private_1a"></a> [sagemaker\_private\_1a](#output\_sagemaker\_private\_1a) | Private Subnet SageMaker Zone A |
| <a name="output_sagemaker_private_1a_cidr"></a> [sagemaker\_private\_1a\_cidr](#output\_sagemaker\_private\_1a\_cidr) | Private Subnet SageMaker CIDR Block of Zone A |
| <a name="output_sagemaker_private_1b"></a> [sagemaker\_private\_1b](#output\_sagemaker\_private\_1b) | Private Subnet SageMaker Zone B |
| <a name="output_sagemaker_private_1b_cidr"></a> [sagemaker\_private\_1b\_cidr](#output\_sagemaker\_private\_1b\_cidr) | Private Subnet SageMaker CIDR Block of Zone B |
| <a name="output_sagemaker_private_1c"></a> [sagemaker\_private\_1c](#output\_sagemaker\_private\_1c) | Private Subnet SageMaker Zone C |
| <a name="output_sagemaker_private_1c_cidr"></a> [sagemaker\_private\_1c\_cidr](#output\_sagemaker\_private\_1c\_cidr) | Private Subnet SageMaker CIDR Block of Zone C |
| <a name="output_sagemaker_runtime_endpoint_id"></a> [sagemaker\_runtime\_endpoint\_id](#output\_sagemaker\_runtime\_endpoint\_id) | SageMaker Runtime Endpoint ID |
| <a name="output_sagemaker_security_group_id"></a> [sagemaker\_security\_group\_id](#output\_sagemaker\_security\_group\_id) | SageMaker Studio Security Group ID |
| <a name="output_sagemaker_studio_endpoint_id"></a> [sagemaker\_studio\_endpoint\_id](#output\_sagemaker\_studio\_endpoint\_id) | SageMaker Studio Endpoint ID |
| <a name="output_sagemaker_subnets"></a> [sagemaker\_subnets](#output\_sagemaker\_subnets) | SageMaker private subnet IDs only |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Default Security Group of VPC Id's |
| <a name="output_summary"></a> [summary](#output\_summary) | Summary Core Infrastructure Configuration with ML Security |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC CIDR Block |
| <a name="output_vpc_endpoints_security_group_id"></a> [vpc\_endpoints\_security\_group\_id](#output\_vpc\_endpoints\_security\_group\_id) | VPC Endpoints Security Group ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC Identity |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | VPC Name |
<!-- END_TF_DOCS -->
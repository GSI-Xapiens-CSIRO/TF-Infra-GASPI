# Terraform Module Cloudfront SSL

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
| <a name="provider_aws.destination"></a> [aws.destination](#provider\_aws.destination) | 5.99.0 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | 5.99.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.alb_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate.cloudfront_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.alb_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_acm_certificate_validation.cloudfront_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.alb_cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.alb_direct](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cdn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cloudfront_cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.app_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_acm_certificate.existing_by_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_cloudfront_distribution.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_distribution) | data source |
| [aws_lb.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_existing_certificate_arn"></a> [alb\_existing\_certificate\_arn](#input\_alb\_existing\_certificate\_arn) | Existing ACM certificate ARN for ALB (must be in same region as ALB) | `string` | `null` | no |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Boolean to determine if the ALB is internal or internet-facing | `bool` | `false` | no |
| <a name="input_alb_target_group_port"></a> [alb\_target\_group\_port](#input\_alb\_target\_group\_port) | Port for the ALB target group | `number` | `80` | no |
| <a name="input_alb_target_group_protocol"></a> [alb\_target\_group\_protocol](#input\_alb\_target\_group\_protocol) | Protocol for the ALB target group | `string` | `"HTTP"` | no |
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | The AWS Access Key | `string` | n/a | yes |
| <a name="input_aws_account_id_destination"></a> [aws\_account\_id\_destination](#input\_aws\_account\_id\_destination) | The AWS Account ID to deploy the Budget in | `string` | n/a | yes |
| <a name="input_aws_account_id_source"></a> [aws\_account\_id\_source](#input\_aws\_account\_id\_source) | The AWS Account ID management | `string` | n/a | yes |
| <a name="input_aws_account_profile_destination"></a> [aws\_account\_profile\_destination](#input\_aws\_account\_profile\_destination) | The AWS Profile to deploy the Budget in | `string` | n/a | yes |
| <a name="input_aws_account_profile_source"></a> [aws\_account\_profile\_source](#input\_aws\_account\_profile\_source) | The AWS Profile management | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy the VPC certificate in | `string` | n/a | yes |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | The AWS Secret Key | `string` | n/a | yes |
| <a name="input_certificate_body_path"></a> [certificate\_body\_path](#input\_certificate\_body\_path) | Path to the SSL certificate body file (cert.crt) | `string` | `null` | no |
| <a name="input_certificate_chain_path"></a> [certificate\_chain\_path](#input\_certificate\_chain\_path) | Optional path to the SSL certificate chain file (chain.crt) | `string` | `null` | no |
| <a name="input_certificate_domain_override"></a> [certificate\_domain\_override](#input\_certificate\_domain\_override) | Override domain name for certificate search (e.g., *.example.com) | `string` | `null` | no |
| <a name="input_cloudfront_existing_certificate_arn"></a> [cloudfront\_existing\_certificate\_arn](#input\_cloudfront\_existing\_certificate\_arn) | Existing ACM certificate ARN for CloudFront (must be in us-east-1) | `string` | `null` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | CloudFront price class (only used if creating new distribution) | `string` | `"PriceClass_100"` | no |
| <a name="input_create_alb"></a> [create\_alb](#input\_create\_alb) | Whether to create ALB (set to false if you already have ALB) | `bool` | `true` | no |
| <a name="input_create_alb_dns_record"></a> [create\_alb\_dns\_record](#input\_create\_alb\_dns\_record) | Whether to create a separate DNS record for direct ALB access | `bool` | `false` | no |
| <a name="input_create_certificate"></a> [create\_certificate](#input\_create\_certificate) | Whether to create/import SSL certificate | `bool` | `true` | no |
| <a name="input_create_new_cloudfront"></a> [create\_new\_cloudfront](#input\_create\_new\_cloudfront) | Whether to create new CloudFront distribution | `bool` | `false` | no |
| <a name="input_department"></a> [department](#input\_department) | Department Owner | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The custom domain name (e.g., app.example.com) | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Target Environment (tags) | `map(string)` | n/a | yes |
| <a name="input_existing_alb_arn"></a> [existing\_alb\_arn](#input\_existing\_alb\_arn) | Existing ALB ARN if not creating new ALB | `string` | `null` | no |
| <a name="input_existing_alb_dns_name"></a> [existing\_alb\_dns\_name](#input\_existing\_alb\_dns\_name) | Existing ALB DNS name if not creating new ALB | `string` | `null` | no |
| <a name="input_existing_certificate_arn"></a> [existing\_certificate\_arn](#input\_existing\_certificate\_arn) | DEPRECATED: Use alb\_existing\_certificate\_arn and cloudfront\_existing\_certificate\_arn instead | `string` | `null` | no |
| <a name="input_existing_cloudfront_distribution_id"></a> [existing\_cloudfront\_distribution\_id](#input\_existing\_cloudfront\_distribution\_id) | Existing CloudFront distribution ID to import/manage | `string` | `null` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Health check path for the ALB target group | `string` | `"/"` | no |
| <a name="input_hosted_zone_name"></a> [hosted\_zone\_name](#input\_hosted\_zone\_name) | The Route 53 hosted zone name (e.g., example.com) | `string` | n/a | yes |
| <a name="input_import_existing_cloudfront"></a> [import\_existing\_cloudfront](#input\_import\_existing\_cloudfront) | Whether to import existing CloudFront distribution | `bool` | `true` | no |
| <a name="input_kms_env"></a> [kms\_env](#input\_kms\_env) | KMS Key Environment | `map(string)` | n/a | yes |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | KMS Key References | `map(string)` | n/a | yes |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | Path to the SSL certificate private key file (cert.key) | `string` | `null` | no |
| <a name="input_search_certificate_by_domain"></a> [search\_certificate\_by\_domain](#input\_search\_certificate\_by\_domain) | Search for certificate by domain name (fallback option) | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the Application Load Balancer | `list(string)` | n/a | yes |
| <a name="input_update_cloudfront_origin"></a> [update\_cloudfront\_origin](#input\_update\_cloudfront\_origin) | Whether to update CloudFront origin to point to new ALB | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where ALB will be deployed | `string` | n/a | yes |
| <a name="input_workspace_env"></a> [workspace\_env](#input\_workspace\_env) | Workspace Environment Selection | `map(string)` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Workspace Environment Name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN of the ACM certificate (ALB certificate) |
| <a name="output_acm_certificate_domain_name"></a> [acm\_certificate\_domain\_name](#output\_acm\_certificate\_domain\_name) | Domain name of the ACM certificate |
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | The ARN of the Application Load Balancer |
| <a name="output_alb_certificate_arn"></a> [alb\_certificate\_arn](#output\_alb\_certificate\_arn) | ARN of the ALB ACM certificate (regional) |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the Application Load Balancer |
| <a name="output_alb_listener_http_arn"></a> [alb\_listener\_http\_arn](#output\_alb\_listener\_http\_arn) | ARN of the ALB HTTP Listener (redirect) |
| <a name="output_alb_listener_https_arn"></a> [alb\_listener\_https\_arn](#output\_alb\_listener\_https\_arn) | ARN of the ALB HTTPS Listener |
| <a name="output_alb_security_group_arn"></a> [alb\_security\_group\_arn](#output\_alb\_security\_group\_arn) | ARN of the ALB Security Group |
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | ID of the ALB Security Group |
| <a name="output_alb_target_group_arn"></a> [alb\_target\_group\_arn](#output\_alb\_target\_group\_arn) | ARN of the ALB Target Group |
| <a name="output_alb_target_group_name"></a> [alb\_target\_group\_name](#output\_alb\_target\_group\_name) | Name of the ALB Target Group |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | The zone ID of the Application Load Balancer |
| <a name="output_app_security_group_arn"></a> [app\_security\_group\_arn](#output\_app\_security\_group\_arn) | ARN of the Application Security Group |
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | ID of the Application Security Group |
| <a name="output_cloudfront_certificate_arn"></a> [cloudfront\_certificate\_arn](#output\_cloudfront\_certificate\_arn) | ARN of the CloudFront ACM certificate (us-east-1) |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | The ARN of the CloudFront distribution |
| <a name="output_cloudfront_distribution_domain_name"></a> [cloudfront\_distribution\_domain\_name](#output\_cloudfront\_distribution\_domain\_name) | The domain name of the CloudFront distribution |
| <a name="output_cloudfront_distribution_hosted_zone_id"></a> [cloudfront\_distribution\_hosted\_zone\_id](#output\_cloudfront\_distribution\_hosted\_zone\_id) | The CloudFront distribution hosted zone ID |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The ID of the CloudFront distribution |
| <a name="output_resource_status"></a> [resource\_status](#output\_resource\_status) | Status of created resources |
| <a name="output_route53_hosted_zone_id"></a> [route53\_hosted\_zone\_id](#output\_route53\_hosted\_zone\_id) | The hosted zone ID used for Route 53 record |
| <a name="output_route53_record_fqdn"></a> [route53\_record\_fqdn](#output\_route53\_record\_fqdn) | The FQDN of the created Route 53 record |
| <a name="output_route53_record_name"></a> [route53\_record\_name](#output\_route53\_record\_name) | The name of the Route 53 record |
| <a name="output_summary"></a> [summary](#output\_summary) | Summary of CloudFront SSL Configuration |
<!-- END_TF_DOCS -->
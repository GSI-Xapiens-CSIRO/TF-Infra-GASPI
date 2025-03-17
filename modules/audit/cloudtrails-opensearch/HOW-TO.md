# AWS CloudTrail with OpenSearch Module for Genomic Services

## Overview

This Terraform module implements AWS CloudTrail configuration specifically designed for genomic services (sBeacon & sVEP), with comprehensive logging, monitoring, and analysis capabilities.

## Features

- Multi-region trail configuration
- Integration with CloudWatch Logs
- KMS encryption for logs
- S3 bucket with lifecycle policies
- CloudWatch metrics and alarms
- SNS notifications
- Athena integration for log analysis
- Cross-account logging capability

## Requirements

| Name      | Version  |
| --------- | -------- |
| terraform | >= 1.8.4 |
| aws       | >= 5.72  |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | >= 5.72 |

## Resources Created

- AWS CloudTrail configuration
- S3 bucket for log storage
- CloudWatch Log Groups
- IAM roles and policies
- KMS keys
- SNS topics
- Athena database and tables

## Module Structure

```
modules/
└── cloudtrail/
    ├── README.md                # Module documentation
    ├── athena.tf                # Athena configuration
    ├── cloudwatch.tf            # CloudWatch configuration
    ├── data.tf                  # Data sources
    ├── iam.tf                   # IAM roles and policies
    ├── kms.tf                   # KMS key configuration
    ├── locals.tf                # Local variables
    ├── main.tf                  # Main CloudTrail configuration
    ├── outputs.tf               # Output values
    ├── provider.tf              # Provider configuration
    ├── s3.tf                    # S3 bucket configuration
    ├── sns.tf                   # SNS topics configuration
    ├── variables.tf             # Input variables
    └── versions.tf              # Version constraints
```

## Usage

### Basic Usage

```hcl
module "cloudtrail" {
  source = "./modules/cloudtrail"

  aws_region                     = "ap-southeast-3"
  aws_account_id_source         = "864899849921"
  aws_account_id_destination    = "307946671795"
  aws_account_profile_source    = "management"
  aws_account_profile_destination = "hub01"

  environment = {
    default = "default"
    prod    = "production"
    staging = "staging"
    dev     = "development"
  }

  department = "GenomicServices"
}
```

## Inputs

| Name                            | Description                                    | Type        | Default | Required |
| ------------------------------- | ---------------------------------------------- | ----------- | ------- | :------: |
| aws_region                      | The AWS region to deploy the CloudTrail in     | string      | n/a     |   yes    |
| aws_account_id_source           | The AWS Account ID management                  | string      | n/a     |   yes    |
| aws_account_id_destination      | The AWS Account ID to deploy the CloudTrail in | string      | n/a     |   yes    |
| aws_account_profile_source      | The AWS Profile management                     | string      | n/a     |   yes    |
| aws_account_profile_destination | The AWS Profile to deploy the CloudTrail in    | string      | n/a     |   yes    |
| log_retention_days              | Number of days to retain CloudTrail logs       | number      | 365     |    no    |
| environment                     | Target Environment mapping                     | map(string) | n/a     |   yes    |
| department                      | Department Owner                               | string      | n/a     |   yes    |

## Outputs

| Name                     | Description                                       |
| ------------------------ | ------------------------------------------------- |
| cloudtrail_arn           | ARN of the CloudTrail trail                       |
| cloudtrail_bucket        | Name of the S3 bucket storing CloudTrail logs     |
| cloudtrail_log_group     | Name of the CloudWatch Log Group for CloudTrail   |
| cloudtrail_kms_key_arn   | ARN of the KMS key used for CloudTrail encryption |
| cloudtrail_sns_topic_arn | ARN of the SNS topic for CloudTrail alerts        |
| athena_database          | Name of the Athena database                       |

## Security Features

### Encryption

- S3 bucket server-side encryption using KMS
- CloudWatch Logs encryption
- SNS topic encryption

### Access Control

- IAM roles with least privilege
- S3 bucket policies
- KMS key policies

### Monitoring

- CloudWatch metrics for errors
- SNS alerts for unauthorized access
- Athena queries for analysis

## Log Analysis

### Available Queries

Pre-configured Athena queries for:

- API activity analysis
- Error pattern detection
- Service usage metrics
- User activity monitoring

### Monitoring Dashboards

CloudWatch dashboards for:

- API errors
- Service latency
- Resource access patterns

## Maintenance

### Log Management

- Configurable log retention in CloudWatch
- S3 lifecycle policies
- Athena partitioned tables

### Updates

Regular checks for:

- Security patches
- AWS service updates
- Terraform provider updates

## Troubleshooting

### Common Issues

1. Log Delivery Issues

   - Check S3 bucket permissions
   - Verify IAM role trust relationships
   - Check CloudWatch log delivery IAM permissions

2. Query Performance
   - Verify Athena table partitions
   - Check query optimization
   - Monitor query costs

### Support

For issues or questions:

1. Check CloudWatch logs
2. Review CloudTrail event history
3. Contact DevOps team

## Best Practices

- Use separate AWS profiles for different environments
- Regularly review CloudTrail logs
- Monitor CloudWatch metrics
- Optimize Athena queries
- Implement proper tag strategy
- Follow least privilege principle

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Copyright

- Author: **DevOps Engineer (devops@xapiens.id)**
- Vendor: **Xapiens Teknologi Indonesia (xapiens.id)**
- License: **Apache v2**
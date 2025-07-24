# ML Security Infrastructure Deployment Guide

This guide provides step-by-step instructions for deploying the enhanced core infrastructure with AWS Network Firewall to secure SageMaker Studio environments and prevent data exfiltration.

## 🎯 Overview

The enhanced infrastructure implements multiple layers of security:
- **Network Firewall** with domain allow/block lists
- **Deep Packet Inspection** to detect data leakage attempts
- **VPC-only SageMaker Studio** with no direct internet access
- **Restrictive Security Groups** blocking unauthorized protocols
- **VPC Endpoints** for secure AWS service access
- **Comprehensive Logging** for audit and monitoring

## 🏗️ Architecture Components

### Traffic Flow Path
```
SageMaker Studio → Network Firewall → NAT Gateway → Internet Gateway → Internet
                                   ↓
                            Traffic Inspection & Filtering
                                   ↓
                              CloudWatch Logs
```

### Security Layers
1. **Application Layer**: SageMaker Studio with VPC-only access
2. **Network Layer**: AWS Network Firewall with IPS rules
3. **Transport Layer**: Restrictive Security Groups
4. **Data Layer**: VPC Endpoints for AWS services only

## 📋 Prerequisites

Before deployment, ensure you have:
- AWS CLI configured with appropriate permissions
- Terraform >= 1.8.4 installed
- Appropriate IAM roles and policies for Network Firewall
- KMS key for encryption (referenced in variables)
- S3 bucket for Terraform state (if using remote backend)

## 🚀 Quick Start

### Step 1: Update Variables
Edit your `terraform.tfvars` or workspace variables:

```hcl
# Enable ML security features
enable_network_firewall = true
enable_sagemaker_studio = true

# Customize allowed domains for your organization
allowed_domains = [
  ".amazonaws.com",
  ".anaconda.com",
  ".pypi.org",
  ".pythonhosted.org",
  ".conda.io",
  ".github.com",
  ".huggingface.co",
  # Add your approved domains here
]

# Add domains to block for data exfiltration prevention
blocked_domains = [
  ".dropbox.com",
  ".box.com",
  ".onedrive.com",
  ".googledrive.com",
  ".wetransfer.com",
  # Add other file sharing services
]

# SageMaker configuration
sagemaker_domain_name = "secure-ml-domain"
sagemaker_user_profile_name = "ml-data-scientist"
```

### Step 2: Plan and Deploy

```bash
# Initialize Terraform
terraform init

# Select appropriate workspace
terraform workspace select prod  # or staging/lab

# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

### Step 3: Verify Security Controls

After deployment, verify the security controls are working:

```bash
# Check Network Firewall status
aws network-firewall describe-firewall \
  --firewall-name gxc-tf-mgmt-prod-ml-security-firewall

# Verify CloudWatch logs are being created
aws logs describe-log-groups \
  --log-group-name-prefix /aws/networkfirewall/

# Test domain blocking (should fail)
# From within SageMaker Studio notebook:
# !wget https://dropbox.com
```

## 🔧 Configuration Options

### Environment-Specific Deployment

For different environments (lab/staging/prod), the infrastructure automatically adjusts:

- **Lab Environment**: Relaxed rules, more domains allowed
- **Staging Environment**: Moderate security, testing-friendly
- **Production Environment**: Strict security, minimal allowed domains

### Firewall Rule Customization

The Network Firewall includes several rule types:

#### 1. Domain Allow/Block Lists
- **Allow List**: Only specified domains are accessible
- **Block List**: Explicitly blocked domains (takes precedence)
- **Default Action**: DROP all other traffic

#### 2. IPS Rules for Data Leak Prevention
- Detects AWS credentials in outbound traffic
- Blocks private key exports
- Monitors large file uploads
- Alerts on SSH connection attempts

#### 3. Stateless Rules
- Blocks email protocols (SMTP, SMTPS)
- Blocks file transfer protocols (FTP, SFTP)
- Allows HTTPS/HTTP for stateful inspection

### Security Group Rules

The security groups implement defense in depth:

- **SageMaker Security Group**: Restricts access to essential ports only
- **VPC Endpoints Security Group**: Allows secure AWS service access
- **Default Security Group**: Highly restrictive baseline

## 🔍 Monitoring and Logging

### CloudWatch Log Groups

The infrastructure creates several log groups:

1. **Alert Logs**: `/aws/networkfirewall/{project}-alerts`
   - Security violations and blocked attempts
   - Data exfiltration attempts
   - Policy violations

2. **Flow Logs**: `/aws/networkfirewall/{project}-flows`
   - Network traffic flows
   - Connection metadata
   - Performance metrics

### Key Metrics to Monitor

Set up CloudWatch alarms for:
- **Blocked connection attempts** (potential data exfiltration)
- **High volume outbound traffic** (unusual activity)
- **Failed authentication attempts** (security incidents)
- **Policy violations** (configuration issues)

## 🛠️ Operational Tasks

### Adding New Allowed Domains

To add a new domain to the allow list:

1. Update the `allowed_domains` variable
2. Run `terraform apply`
3. Changes take effect immediately (no downtime)

### Investigating Security Alerts

When security alerts are triggered:

1. Check CloudWatch logs for details
2. Identify the source (subnet, instance)
3. Investigate user activity in SageMaker Studio
4. Update rules if legitimate traffic was blocked

### Emergency Access

In case of emergency access needs:

1. Temporarily modify firewall rules via AWS Console
2. Document the change and reason
3. Update Terraform configuration ASAP
4. Apply Terraform to restore consistent state

## 🚨 Troubleshooting

### Common Issues

#### SageMaker Studio Cannot Access Package Repositories

**Symptoms**: Package installation fails in notebooks
**Solution**: Add required domains to allow list:

```hcl
allowed_domains = [
  ".pypi.org",
  ".pythonhosted.org",
  ".anaconda.com",
  ".conda.io"
]
```

#### VPC Endpoints Not Resolving

**Symptoms**: AWS service calls fail
**Solution**: Verify VPC endpoint DNS resolution:

```bash
# Test from within VPC
nslookup s3.ap-southeast-3.amazonaws.com
```

#### Firewall Rules Not Taking Effect

**Symptoms**: Traffic not being filtered as expected
**Solution**: Check rule order and priorities:

```bash
aws network-firewall describe-firewall-policy \
  --firewall-policy-arn <policy-arn>
```

### Log Analysis

Use CloudWatch Insights to analyze firewall logs:

```sql
-- Find blocked connection attempts
fields @timestamp, src_ip, dest_ip, dest_port, action
| filter action = "blocked"
| sort @timestamp desc

-- Analyze traffic patterns
fields @timestamp, protocol, dest_port
| stats count() by dest_port
| sort count desc
```

## 📊 Cost Optimization

### Network Firewall Costs
- **Firewall Endpoint**: ~$0.395/hour per AZ (3 AZ = ~$1.18/hour)
- **Rule Processing**: $0.065 per GB processed
- **Estimated Monthly**: ~$1,000-2,000 for moderate usage

### Cost Reduction Strategies
1. **Single AZ Deployment**: Reduce to 1 AZ for development
2. **Rule Optimization**: Reduce rule complexity
3. **Traffic Optimization**: Use VPC endpoints to reduce internet traffic

## 🔐 Security Best Practices

### Regular Security Reviews
- **Weekly**: Review CloudWatch alerts and logs
- **Monthly**: Audit allowed domains list
- **Quarterly**: Review and update IPS rules

### Access Control
- Implement least-privilege IAM policies
- Use separate roles for different ML teams
- Regular access reviews and rotation

### Data Classification
- Tag resources with data classification levels
- Implement data loss prevention policies
- Regular data flow audits

## 📚 Additional Resources

### AWS Documentation
- [AWS Network Firewall Developer Guide](https://docs.aws.amazon.com/network-firewall/latest/developerguide/)
- [SageMaker VPC Configuration](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-notebooks-and-internet-access.html)
- [VPC Endpoints Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints.html)

### Terraform Resources
- [AWS Network Firewall Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall)
- [SageMaker Terraform Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_domain)

## 🤝 Support and Contributing

For issues and feature requests:
1. Check existing issues in the repository
2. Create detailed bug reports with logs
3. Submit feature requests with business justification
4. Contribute improvements via pull requests

---

This infrastructure provides enterprise-grade security for ML workloads while maintaining operational flexibility. Regular monitoring and maintenance are essential for optimal security posture.
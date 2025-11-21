# AWS Temporary TF Central Role Management

## Overview

This toolkit provides automated management of `Temp-TF-Central-Role_${account_id}` across your AWS multi-account hospital network infrastructure. These temporary roles are designed to facilitate Terraform deployments with Administrator access while maintaining proper IAM security practices.

## 🏥 Infrastructure Context

**GSI Xapiens CSIRO - Genomic Data Platform**
- **Production Accounts**: 5 hospital networks (RSCM, RSPON, SARDJITO, RSNGOERAH, RSJPD)
- **UAT Accounts**: 5 corresponding UAT environments
- **Region**: ap-southeast-3 (Jakarta)
- **Purpose**: sBeacon and sVEP genomic variant analysis infrastructure

## 📋 Prerequisites

### Required Tools
- AWS CLI v2.x or higher
- Bash 4.x or higher
- jq (JSON processor)
- Valid AWS credentials configured in `~/.aws/credentials`

### AWS Credentials Setup

Ensure your `~/.aws/credentials` file contains:

```ini
# Production Accounts
[BGSI-TF-User-Executor-RSCM]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

[BGSI-TF-User-Executor-RSPON]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

# ... (and so on for all accounts)
```

### AWS Config Setup

Your `~/.aws/config` should reference the roles:

```ini
[profile BGSI-TF-User-Executor-RSCM]
role_arn = arn:aws:iam::442799077487:role/TF-Central-Role_442799077487
source_profile = BGSI-TF-User-Executor-RSCM
region = ap-southeast-3
output = json
```

## 📦 Scripts Included

### 1. `create-temp-tf-central-roles.sh`
Creates `Temp-TF-Central-Role_${account_id}` with Administrator access across all accounts.

**Features:**
- Creates IAM role with AdministratorAccess policy
- Sets appropriate trust relationships
- Configures 12-hour session duration
- Adds descriptive tags
- Validates role creation
- Tests role assumption

### 2. `verify-temp-tf-central-roles.sh`
Verifies role existence and configuration across all accounts.

**Checks:**
- Role existence
- AdministratorAccess policy attachment
- Trust policy configuration
- Role assumption capability
- Tag presence

### 3. `cleanup-temp-tf-central-roles.sh`
Safely removes temporary roles from all accounts.

**Safety Features:**
- Double confirmation required
- Countdown timer
- Comprehensive cleanup (policies + role)
- Deletion verification

## 🚀 Usage Guide

### Creating Roles

```bash
# Make scripts executable
chmod +x create-temp-tf-central-roles.sh
chmod +x verify-temp-tf-central-roles.sh
chmod +x cleanup-temp-tf-central-roles.sh

# Create roles across all accounts
./create-temp-tf-central-roles.sh
```

**Expected Output:**
```
╔══════════════════════════════════════════════════════════════╗
║   AWS Temporary TF Central Role Creator                      ║
║   Version 1.0.0                                              ║
╚══════════════════════════════════════════════════════════════╝

Total accounts to process: 10
  - Production: 5
  - UAT: 5

Do you want to proceed with role creation? (yes/no): yes

Processing: RSCM (442799077487) - Production
[INFO] Verifying AWS credentials...
[SUCCESS] Authenticated as: arn:aws:iam::442799077487:user/terraform-executor
[INFO] Creating IAM role: Temp-TF-Central-Role_442799077487
[SUCCESS] Created role: Temp-TF-Central-Role_442799077487
[SUCCESS] Attached AdministratorAccess policy
[SUCCESS] ✓ Role assumption test successful
```

### Verifying Roles

```bash
# Verify all roles are correctly configured
./verify-temp-tf-central-roles.sh
```

**Verification Checks:**
1. ✓ Role exists
2. ✓ AdministratorAccess policy attached
3. ✓ Trust policy configured
4. ✓ Role assumption works
5. ✓ Tags present

### Using Roles in Terraform

Once created, reference these roles in your Terraform provider configuration:

```hcl
# Example: RSCM Production Account
provider "aws" {
  alias  = "rscm-prod"
  region = "ap-southeast-3"

  assume_role {
    role_arn     = "arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487"
    session_name = "terraform-deployment"
  }
}
```

### Cleanup (When Done)

```bash
# Remove temporary roles
./cleanup-temp-tf-central-roles.sh
```

**Safety Confirmations:**
1. Type 'DELETE' to confirm
2. Enter number of accounts (10)
3. 5-second countdown

## 🔐 Security Considerations

### Why Temporary Roles?

1. **Principle of Least Privilege**: Temporary roles can be created/destroyed as needed
2. **Audit Trail**: Clear creation/deletion timestamps in CloudTrail
3. **Session Limits**: 12-hour maximum session duration
4. **Explicit Permissions**: Administrator access only when explicitly needed

### Trust Policy

The roles trust their own account root:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Best Practices

1. **Create only when needed**: Don't leave these roles permanently
2. **Clean up after use**: Remove roles when deployment is complete
3. **Monitor usage**: Check CloudTrail for any unexpected role assumptions
4. **Rotate credentials**: Regular rotation of source IAM user credentials
5. **Use with Atlantis**: These roles integrate well with Atlantis CI/CD

## 📊 Account Mapping

### Production Accounts

| Hospital | Account ID | Profile Name | Role ARN |
|----------|------------|--------------|----------|
| RSCM | 442799077487 | BGSI-TF-User-Executor-RSCM | arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487 |
| RSPON | 829990487185 | BGSI-TF-User-Executor-RSPON | arn:aws:iam::829990487185:role/Temp-TF-Central-Role_829990487185 |
| SARDJITO | 938674806253 | BGSI-TF-User-Executor-SARDJITO | arn:aws:iam::938674806253:role/Temp-TF-Central-Role_938674806253 |
| RSNGOERAH | 136839993415 | BGSI-TF-User-Executor-RSNGOERAH | arn:aws:iam::136839993415:role/Temp-TF-Central-Role_136839993415 |
| RSJPD | 602006056899 | BGSI-TF-User-Executor-RSJPD | arn:aws:iam::602006056899:role/Temp-TF-Central-Role_602006056899 |

### UAT Accounts

| Hospital | Account ID | Profile Name | Role ARN |
|----------|------------|--------------|----------|
| RSCM-UAT | 695094375681 | BGSI-TF-User-Executor-RSCM-UAT | arn:aws:iam::695094375681:role/Temp-TF-Central-Role_695094375681 |
| RSPON-UAT | 741464515101 | BGSI-TF-User-Executor-RSPON-UAT | arn:aws:iam::741464515101:role/Temp-TF-Central-Role_741464515101 |
| SARDJITO-UAT | 819520291687 | BGSI-TF-User-Executor-SARDJITO-UAT | arn:aws:iam::819520291687:role/Temp-TF-Central-Role_819520291687 |
| RSNGOERAH-UAT | 899630542732 | BGSI-TF-User-Executor-RSNGOERAH-UAT | arn:aws:iam::899630542732:role/Temp-TF-Central-Role_899630542732 |
| RSJPD-UAT | 148450585096 | BGSI-TF-User-Executor-RSJPD-UAT | arn:aws:iam::148450585096:role/Temp-TF-Central-Role_148450585096 |

## 📝 Logging

All operations are logged to the `logs/` directory:

```
logs/
├── create-temp-roles-20250120_143022.log
├── verify-temp-roles-20250120_144133.log
└── cleanup-temp-roles-20250120_151245.log
```

**Log Contents:**
- Timestamps for all operations
- Success/failure status
- Detailed error messages
- AWS API responses
- Role ARNs and configurations

## 🔍 Troubleshooting

### Issue: "Cannot authenticate with profile"

**Solution:**
```bash
# Check credentials are valid
aws sts get-caller-identity --profile BGSI-TF-User-Executor-RSCM

# Verify credentials file
cat ~/.aws/credentials | grep -A 2 "BGSI-TF-User-Executor-RSCM"
```

### Issue: "Role already exists"

**Solution:**
The script will detect existing roles and ask if you want to update them. Choose 'yes' to update trust policy and policies.

### Issue: "Role assumption test failed"

**Solution:**
This is often due to AWS propagation delay. Wait 30-60 seconds and run the verify script again.

### Issue: "Access Denied" when creating role

**Solution:**
Ensure your source IAM user has these permissions:
- `iam:CreateRole`
- `iam:AttachRolePolicy`
- `iam:UpdateAssumeRolePolicy`
- `iam:TagRole`

## 🔄 Integration with Terraform

### Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "tf-state-genomics-${var.account_id}"
    key            = "infrastructure/terraform.tfstate"
    region         = "ap-southeast-3"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"

    # Use temporary role for backend operations
    role_arn = "arn:aws:iam::${var.account_id}:role/Temp-TF-Central-Role_${var.account_id}"
  }
}
```

### Provider Configuration

```hcl
# Production RSCM
provider "aws" {
  alias  = "rscm"
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487"
    session_name = "terraform-${var.environment}"
  }

  default_tags {
    tags = {
      Environment = "Production"
      Hospital    = "RSCM"
      ManagedBy   = "Terraform"
      Project     = "Genomics-sBeacon"
    }
  }
}
```

## 🛡️ Compliance & Governance

### HIPAA Considerations

These roles facilitate infrastructure automation while maintaining:
1. **Audit Trail**: All actions logged to CloudTrail
2. **Temporary Access**: Time-limited sessions (12 hours max)
3. **Explicit Trust**: Only trusted accounts can assume
4. **Administrative Oversight**: Clear creation/deletion workflows

### Tags Applied

Each role is tagged with:
- `Environment`: Production or UAT
- `Purpose`: Terraform-Automation
- `ManagedBy`: DevOps-Team
- `Hospital`: Hospital name
- `CreatedDate`: Creation timestamp

## 📞 Support & Maintenance

### Regular Tasks

1. **Weekly**: Verify roles exist and are correctly configured
2. **Monthly**: Review CloudTrail logs for role assumptions
3. **Quarterly**: Rotate source IAM user credentials
4. **After Deployment**: Clean up temporary roles

### Contact

For issues or questions:
- **Team**: GSI Xapiens CSIRO DevOps
- **Project**: Genomic Data Platform (sBeacon/sVEP)
- **Documentation**: See project wiki for additional context

## 📚 Related Documentation

- [AWS IAM Roles Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Organizations Best Practices](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices.html)
- [Module 6: AWS Account Management](./Module_6_-_Management_Account_-_v2_0.pdf)

## 🔖 Version History

### v1.0.0 (2025-01-20)
- Initial release
- Support for 10 accounts (5 prod + 5 UAT)
- Create, verify, and cleanup functionality
- Comprehensive logging
- Safety confirmations for destructive operations

---

**Note**: These are TEMPORARY roles. Always clean up after infrastructure deployments are complete. Never leave these roles active indefinitely in production environments.
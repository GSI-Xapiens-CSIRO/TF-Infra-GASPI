# AWS Temp TF Central Role - Complete Toolkit

## 📦 Package Contents

This toolkit provides complete automation for managing `Temp-TF-Central-Role_${account_id}` across your 10-account AWS infrastructure (5 production + 5 UAT hospital networks).

### Files Included

```
📁 outputs/
├── 📄 README.md                              # Complete documentation
├── 📄 QUICK-REFERENCE.md                     # Quick command reference
├── 🔧 create-temp-tf-central-roles.sh       # Role creation script (13KB)
├── ✅ verify-temp-tf-central-roles.sh        # Role verification script (9.7KB)
├── 🗑️  cleanup-temp-tf-central-roles.sh      # Role cleanup script (12KB)
├── 📋 credentials.template                   # AWS credentials template
├── 📋 config.template                        # AWS config template
└── 📄 DEPLOYMENT-SUMMARY.md                  # This file
```

## 🎯 Purpose

Create temporary IAM roles with Administrator access across all hospital accounts to facilitate Terraform infrastructure deployments for the GSI Xapiens CSIRO genomics platform (sBeacon and sVEP services).

## 🏥 Target Infrastructure

### Production Accounts (5)
- **RSCM**: 442799077487
- **RSPON**: 829990487185
- **SARDJITO**: 938674806253
- **RSNGOERAH**: 136839993415
- **RSJPD**: 602006056899

### UAT Accounts (5)
- **RSCM-UAT**: 695094375681
- **RSPON-UAT**: 741464515101
- **SARDJITO-UAT**: 819520291687
- **RSNGOERAH-UAT**: 899630542732
- **RSJPD-UAT**: 148450585096

**Region**: ap-southeast-3 (Jakarta)

## 🚀 Quick Start (5 Minutes)

### Step 1: Setup AWS Credentials (2 min)

```bash
# Copy templates to AWS config directory
cp credentials.template ~/.aws/credentials
cp config.template ~/.aws/config

# Set proper permissions
chmod 600 ~/.aws/credentials ~/.aws/config

# Edit credentials file and add your access keys
vim ~/.aws/credentials
```

### Step 2: Make Scripts Executable (10 sec)

```bash
chmod +x create-temp-tf-central-roles.sh
chmod +x verify-temp-tf-central-roles.sh
chmod +x cleanup-temp-tf-central-roles.sh
```

### Step 3: Test One Account (30 sec)

```bash
# Test authentication
aws sts get-caller-identity --profile BGSI-TF-User-Executor-RSCM
```

### Step 4: Create All Roles (2 min)

```bash
# Run creation script
./create-temp-tf-central-roles.sh

# When prompted, type: yes
```

### Step 5: Verify (1 min)

```bash
# Verify all roles were created successfully
./verify-temp-tf-central-roles.sh
```

## ✅ What Gets Created

For each account, the script creates:

```
Role Name: Temp-TF-Central-Role_${account_id}
├── Permissions: AdministratorAccess (AWS managed policy)
├── Trust Policy: Account root principal
├── Session Duration: 43,200 seconds (12 hours)
└── Tags:
    ├── Environment: Production/UAT
    ├── Purpose: Terraform-Automation
    ├── ManagedBy: DevOps-Team
    ├── Hospital: [Hospital Name]
    └── CreatedDate: [YYYY-MM-DD]
```

## 🔐 Security Features

1. **Temporary Nature**: Roles are created only when needed, deleted after use
2. **Time-Limited Sessions**: Maximum 12-hour session duration
3. **Explicit Trust**: Roles only trust their own account root
4. **Audit Trail**: All assumptions logged to CloudTrail
5. **Tagged Resources**: Clear identification and tracking
6. **No Standing Access**: Roles don't exist permanently

## 📊 Expected Output

### Creation Script Success

```
╔══════════════════════════════════════════════════════════════╗
║   AWS Temporary TF Central Role Creator                      ║
║   Version 1.0.0                                              ║
╚══════════════════════════════════════════════════════════════╝

Total accounts to process: 10
  - Production: 5
  - UAT: 5

[SUCCESS] All accounts processed successfully! ✓

Created Roles Summary:
Account Name         Account ID      Role ARN
────────────        ──────────      ────────
RSCM                442799077487    arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487
RSPON               829990487185    arn:aws:iam::829990487185:role/Temp-TF-Central-Role_829990487185
...
```

### Verification Script Success

```
╔══════════════════════════════════════════════════════════════╗
║                  VERIFICATION SUMMARY                        ║
╚══════════════════════════════════════════════════════════════╝

Total accounts: 10
[SUCCESS] Passed: 10
═══════════════════════════════════════════════════════════════
[SUCCESS] ALL VERIFICATIONS PASSED! ✓
═══════════════════════════════════════════════════════════════
```

## 🔧 Using with Terraform

### Basic Provider Configuration

```hcl
terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.72"
    }
  }

  backend "s3" {
    bucket         = "tf-state-genomics-442799077487"
    key            = "infrastructure/terraform.tfstate"
    region         = "ap-southeast-3"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = "ap-southeast-3"

  assume_role {
    role_arn     = "arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487"
    session_name = "terraform-deployment"
  }

  default_tags {
    tags = {
      Environment = "Production"
      Hospital    = "RSCM"
      ManagedBy   = "Terraform"
      Project     = "Genomics-Platform"
    }
  }
}
```

### Multi-Account Deployment

```hcl
# Create providers for all production hospitals
locals {
  production_accounts = {
    rscm      = "442799077487"
    rspon     = "829990487185"
    sardjito  = "938674806253"
    rsngoerah = "136839993415"
    rsjpd     = "602006056899"
  }
}

# Generate providers dynamically
provider "aws" {
  for_each = local.production_accounts
  alias    = each.key
  region   = "ap-southeast-3"

  assume_role {
    role_arn     = "arn:aws:iam::${each.value}:role/Temp-TF-Central-Role_${each.value}"
    session_name = "terraform-${each.key}"
  }
}

# Deploy to RSCM
resource "aws_s3_bucket" "genomics_rscm" {
  provider = aws.rscm
  bucket   = "genomics-data-rscm-prod"
}
```

## 📝 Typical Workflow

```
1. Setup Phase (Once)
   ├── Configure AWS credentials
   ├── Test authentication
   └── Make scripts executable

2. Deployment Phase (Each Deployment)
   ├── Create temporary roles
   │   └── ./create-temp-tf-central-roles.sh
   │
   ├── Verify roles
   │   └── ./verify-temp-tf-central-roles.sh
   │
   ├── Run Terraform
   │   ├── terraform init
   │   ├── terraform plan
   │   └── terraform apply
   │
   └── Clean up roles
       └── ./cleanup-temp-tf-central-roles.sh

3. Verification Phase (Weekly)
   └── Run verification script to ensure no orphaned roles
```

## 🔍 Monitoring & Logging

### CloudTrail Events to Monitor

```bash
# View role assumptions
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=Temp-TF-Central-Role_442799077487 \
  --max-results 50

# Check for any admin actions
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole \
  --max-results 50
```

### Script Logs

All scripts generate detailed logs in the `logs/` directory:

```
logs/
├── create-temp-roles-20250120_143022.log    # Creation logs
├── verify-temp-roles-20250120_144133.log    # Verification logs
└── cleanup-temp-roles-20250120_151245.log   # Cleanup logs
```

## ⚠️ Important Warnings

1. **NEVER commit credentials**: The `.aws/credentials` file must never be in Git
2. **Clean up after use**: Always run cleanup script after deployments
3. **Monitor for drift**: Run weekly verifications to catch any manual changes
4. **Rotate regularly**: Rotate source IAM user credentials every 90 days
5. **Review CloudTrail**: Check for unexpected role assumptions

## 🛠️ Troubleshooting

### Issue: "Cannot authenticate with profile"

**Solution:**
```bash
# Check credentials file exists
ls -la ~/.aws/credentials

# Verify profile exists
cat ~/.aws/credentials | grep "BGSI-TF-User-Executor-RSCM"

# Test authentication
aws sts get-caller-identity --profile BGSI-TF-User-Executor-RSCM
```

### Issue: "Role already exists"

**Solution:**
The script will detect existing roles and ask if you want to update. Type `yes` to update.

### Issue: "Access Denied"

**Solution:**
Ensure your source IAM user has these permissions:
- `iam:CreateRole`
- `iam:AttachRolePolicy`
- `iam:GetRole`
- `iam:UpdateAssumeRolePolicy`
- `iam:TagRole`
- `iam:DeleteRole`
- `iam:DetachRolePolicy`

### Issue: "Role assumption test failed"

**Solution:**
This is usually due to AWS propagation delay. Wait 60 seconds and run verify again.

## 📞 Support

For issues or questions:
- **Team**: GSI Xapiens CSIRO DevOps
- **Project**: Genomic Data Platform
- **Components**: sBeacon, sVEP
- **Region**: ap-southeast-3 (Jakarta)

## 📚 Additional Resources

- [README.md](./README.md) - Complete documentation
- [QUICK-REFERENCE.md](./QUICK-REFERENCE.md) - Command quick reference
- [Module 6: AWS Account Management](../Module_6_-_Management_Account_-_v2_0.pdf)

## 🎯 Success Criteria

✅ All 10 roles created successfully
✅ All roles have AdministratorAccess attached
✅ All roles can be assumed successfully
✅ All roles have correct trust policies
✅ All roles are properly tagged
✅ Terraform can use roles for deployments
✅ Roles can be cleaned up successfully

## 📋 Checklist for Deployment

Before running scripts:
- [ ] AWS CLI installed and updated
- [ ] jq installed for JSON processing
- [ ] Credentials configured in ~/.aws/credentials
- [ ] Config configured in ~/.aws/config
- [ ] File permissions set (600)
- [ ] Authentication tested for at least one account
- [ ] Scripts made executable (chmod +x)

During deployment:
- [ ] Read warnings and confirmations carefully
- [ ] Monitor script output for errors
- [ ] Check logs if any failures occur
- [ ] Verify all accounts processed successfully

After deployment:
- [ ] Run verification script
- [ ] Test Terraform with one account first
- [ ] Deploy to all accounts as needed
- [ ] Run cleanup script when done
- [ ] Verify cleanup completed successfully

## 🔄 Maintenance Schedule

**Weekly**:
- Run verification script to check for orphaned roles
- Review CloudTrail logs for unexpected assumptions

**Monthly**:
- Audit all accounts for security compliance
- Review and update trust policies if needed

**Quarterly**:
- Rotate source IAM user credentials
- Review and update IAM permissions
- Test disaster recovery procedures

---

**Version**: 1.0.0
**Created**: 2025-01-20
**Last Updated**: 2025-01-20
**Author**: DevOps Team - GSI Xapiens CSIRO

**Remember**: These are TEMPORARY roles. Always clean up after deployments! 🧹
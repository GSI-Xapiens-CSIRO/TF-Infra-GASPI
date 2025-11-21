# Quick Reference Guide - Temp TF Central Roles

## ⚡ Quick Start

```bash
# 1. Make scripts executable
chmod +x *.sh

# 2. Create roles in all accounts
./create-temp-tf-central-roles.sh

# 3. Verify roles are working
./verify-temp-tf-central-roles.sh

# 4. Use in Terraform (see examples below)

# 5. Clean up when done
./cleanup-temp-tf-central-roles.sh
```

## 📋 One-Line Commands

### Check a specific account
```bash
aws iam get-role --role-name Temp-TF-Central-Role_442799077487 \
  --profile BGSI-TF-User-Executor-RSCM
```

### Test role assumption
```bash
aws sts assume-role \
  --role-arn arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487 \
  --role-session-name test \
  --profile BGSI-TF-User-Executor-RSCM
```

### List all roles in an account
```bash
aws iam list-roles --profile BGSI-TF-User-Executor-RSCM \
  --query 'Roles[?contains(RoleName, `Temp-TF-Central-Role`)].RoleName'
```

## 🔧 Terraform Quick Examples

### Single Account Deployment

```hcl
provider "aws" {
  region = "ap-southeast-3"

  assume_role {
    role_arn = "arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487"
    session_name = "terraform-rscm-prod"
  }
}
```

### Multi-Account Deployment

```hcl
# Production accounts
provider "aws" {
  alias  = "rscm"
  region = "ap-southeast-3"
  assume_role {
    role_arn = "arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487"
  }
}

provider "aws" {
  alias  = "rspon"
  region = "ap-southeast-3"
  assume_role {
    role_arn = "arn:aws:iam::829990487185:role/Temp-TF-Central-Role_829990487185"
  }
}

# Use in resources
resource "aws_s3_bucket" "rscm_bucket" {
  provider = aws.rscm
  bucket   = "genomics-data-rscm"
}
```

### With Variables

```hcl
variable "account_ids" {
  type = map(string)
  default = {
    rscm      = "442799077487"
    rspon     = "829990487185"
    sardjito  = "938674806253"
    rsngoerah = "136839993415"
    rsjpd     = "602006056899"
  }
}

provider "aws" {
  alias  = "rscm"
  region = "ap-southeast-3"

  assume_role {
    role_arn = "arn:aws:iam::${var.account_ids.rscm}:role/Temp-TF-Central-Role_${var.account_ids.rscm}"
  }
}
```

## 🎯 Common Tasks

### Export credentials for CLI use
```bash
# Get temporary credentials
CREDS=$(aws sts assume-role \
  --role-arn arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487 \
  --role-session-name cli-session \
  --profile BGSI-TF-User-Executor-RSCM \
  --output json)

# Export to environment
export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

# Now use AWS CLI without profile
aws s3 ls
```

### Verify all accounts at once
```bash
for profile in BGSI-TF-User-Executor-RSCM \
               BGSI-TF-User-Executor-RSPON \
               BGSI-TF-User-Executor-SARDJITO \
               BGSI-TF-User-Executor-RSNGOERAH \
               BGSI-TF-User-Executor-RSJPD; do
  echo "Checking $profile..."
  aws sts get-caller-identity --profile $profile
done
```

## 🔍 Troubleshooting Commands

### Check if role exists
```bash
aws iam get-role \
  --role-name Temp-TF-Central-Role_442799077487 \
  --profile BGSI-TF-User-Executor-RSCM 2>&1 | \
  grep -q "NoSuchEntity" && echo "Role NOT found" || echo "Role exists"
```

### Check attached policies
```bash
aws iam list-attached-role-policies \
  --role-name Temp-TF-Central-Role_442799077487 \
  --profile BGSI-TF-User-Executor-RSCM \
  --query 'AttachedPolicies[*].[PolicyName,PolicyArn]' \
  --output table
```

### View trust policy
```bash
aws iam get-role \
  --role-name Temp-TF-Central-Role_442799077487 \
  --profile BGSI-TF-User-Executor-RSCM \
  --query 'Role.AssumeRolePolicyDocument' \
  --output json | jq .
```

## 📊 Account Reference (Copy-Paste Ready)

### Production Role ARNs
```
arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487  # RSCM
arn:aws:iam::829990487185:role/Temp-TF-Central-Role_829990487185  # RSPON
arn:aws:iam::938674806253:role/Temp-TF-Central-Role_938674806253  # SARDJITO
arn:aws:iam::136839993415:role/Temp-TF-Central-Role_136839993415  # RSNGOERAH
arn:aws:iam::602006056899:role/Temp-TF-Central-Role_602006056899  # RSJPD
```

### UAT Role ARNs
```
arn:aws:iam::695094375681:role/Temp-TF-Central-Role_695094375681  # RSCM-UAT
arn:aws:iam::741464515101:role/Temp-TF-Central-Role_741464515101  # RSPON-UAT
arn:aws:iam::819520291687:role/Temp-TF-Central-Role_819520291687  # SARDJITO-UAT
arn:aws:iam::899630542732:role/Temp-TF-Central-Role_899630542732  # RSNGOERAH-UAT
arn:aws:iam::148450585096:role/Temp-TF-Central-Role_148450585096  # RSJPD-UAT
```

## 🚨 Emergency Procedures

### If role is locked/misconfigured
```bash
# 1. Check current state
aws iam get-role --role-name Temp-TF-Central-Role_${ACCOUNT_ID} \
  --profile ${PROFILE}

# 2. Detach all policies
aws iam list-attached-role-policies \
  --role-name Temp-TF-Central-Role_${ACCOUNT_ID} \
  --profile ${PROFILE} \
  --query 'AttachedPolicies[*].PolicyArn' \
  --output text | xargs -I {} aws iam detach-role-policy \
  --role-name Temp-TF-Central-Role_${ACCOUNT_ID} \
  --policy-arn {} \
  --profile ${PROFILE}

# 3. Delete role
aws iam delete-role \
  --role-name Temp-TF-Central-Role_${ACCOUNT_ID} \
  --profile ${PROFILE}

# 4. Recreate using the script
./create-temp-tf-central-roles.sh
```

### If credentials expired
```bash
# Update credentials in ~/.aws/credentials
vim ~/.aws/credentials

# Test new credentials
aws sts get-caller-identity --profile BGSI-TF-User-Executor-RSCM
```

## 📝 Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `InvalidClientTokenId` | Credentials invalid | Update `~/.aws/credentials` |
| `AccessDenied` | Insufficient permissions | Check source user has IAM permissions |
| `NoSuchEntity` | Role doesn't exist | Run create script |
| `EntityAlreadyExists` | Role exists | Choose update when prompted |
| `MalformedPolicyDocument` | Trust policy issue | Check account ID is correct |

## 🎓 Best Practices Checklist

- [ ] Create roles only when needed
- [ ] Verify after creation
- [ ] Use in Terraform with explicit session names
- [ ] Monitor CloudTrail for unexpected assumptions
- [ ] Clean up after deployment complete
- [ ] Never commit credentials to Git
- [ ] Rotate source IAM credentials regularly
- [ ] Document any manual role modifications
- [ ] Use consistent naming convention
- [ ] Tag all resources appropriately

## 📞 Quick Links

- [Full README](./README.md)
- [AWS IAM Console](https://console.aws.amazon.com/iam/)
- [CloudTrail Console](https://console.aws.amazon.com/cloudtrail/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**Remember**: These are TEMPORARY roles. Clean up after use! 🧹
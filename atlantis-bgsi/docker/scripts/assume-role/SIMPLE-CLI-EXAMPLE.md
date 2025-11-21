# Simple AWS CLI - Create Assume Role with Policies

## 🎯 Super Simple One-Liner Examples

### Example 1: Create Role with AdministratorAccess (Simplest)

```bash
# Replace with your account ID
ACCOUNT_ID="442799077487"

# Create the role
aws iam create-role \
  --role-name Temp-TF-Central-Role_${ACCOUNT_ID} \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::'${ACCOUNT_ID}':root"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach AdministratorAccess policy
aws iam attach-role-policy \
  --role-name Temp-TF-Central-Role_${ACCOUNT_ID} \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### Example 2: With Profile and Region

```bash
# For RSCM Production
aws iam create-role \
  --role-name Temp-TF-Central-Role_442799077487 \
  --assume-role-policy-document file://trust-policy.json \
  --profile BGSI-TF-User-Executor-RSCM \
  --region ap-southeast-3

aws iam attach-role-policy \
  --role-name Temp-TF-Central-Role_442799077487 \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
  --profile BGSI-TF-User-Executor-RSCM
```

---

## 📄 Trust Policy JSON Files

### trust-policy.json (Basic)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::442799077487:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### trust-policy-with-mfa.json (With MFA)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::442799077487:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
```

### trust-policy-specific-user.json (Specific IAM User)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::442799077487:user/terraform-executor"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### trust-policy-cross-account.json (Cross-Account)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::442799077487:root",
          "arn:aws:iam::829990487185:root"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

---

## 🔧 Complete Examples with Different Policy Attachments

### 1. Simple Role with Administrator Access

```bash
ACCOUNT_ID="442799077487"
ROLE_NAME="Temp-TF-Central-Role_${ACCOUNT_ID}"

# Create trust policy file
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"AWS": "arn:aws:iam::${ACCOUNT_ID}:root"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

# Create role
aws iam create-role \
  --role-name ${ROLE_NAME} \
  --assume-role-policy-document file://trust-policy.json \
  --description "Temporary Terraform Central Role" \
  --max-session-duration 43200

# Attach policy
aws iam attach-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Verify
aws iam get-role --role-name ${ROLE_NAME}
```

### 2. Role with Custom Inline Policy

```bash
ACCOUNT_ID="442799077487"
ROLE_NAME="Temp-TF-Central-Role_${ACCOUNT_ID}"

# Create custom policy
cat > custom-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "lambda:*",
        "iam:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create role (trust policy inline)
aws iam create-role \
  --role-name ${ROLE_NAME} \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::'${ACCOUNT_ID}':root"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach inline policy
aws iam put-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-name CustomTerraformPolicy \
  --policy-document file://custom-policy.json
```

### 3. Role with Multiple Managed Policies

```bash
ACCOUNT_ID="442799077487"
ROLE_NAME="Temp-TF-Central-Role_${ACCOUNT_ID}"

# Create role
aws iam create-role \
  --role-name ${ROLE_NAME} \
  --assume-role-policy-document file://trust-policy.json

# Attach multiple AWS managed policies
aws iam attach-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

aws iam attach-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-arn arn:aws:iam::aws:policy/IAMFullAccess

aws iam attach-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

### 4. Role with Tags

```bash
ACCOUNT_ID="442799077487"
ROLE_NAME="Temp-TF-Central-Role_${ACCOUNT_ID}"

# Create role with tags in one command
aws iam create-role \
  --role-name ${ROLE_NAME} \
  --assume-role-policy-document file://trust-policy.json \
  --tags \
    Key=Environment,Value=Production \
    Key=Purpose,Value=Terraform \
    Key=ManagedBy,Value=DevOps \
    Key=Hospital,Value=RSCM

# Attach policy
aws iam attach-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

---

## 🔄 Testing the Role

### Test 1: Get Role Details
```bash
aws iam get-role --role-name Temp-TF-Central-Role_442799077487
```

### Test 2: List Attached Policies
```bash
aws iam list-attached-role-policies \
  --role-name Temp-TF-Central-Role_442799077487
```

### Test 3: Assume the Role
```bash
aws sts assume-role \
  --role-arn arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487 \
  --role-session-name test-session
```

### Test 4: Use Assumed Role Credentials
```bash
# Get temporary credentials
CREDS=$(aws sts assume-role \
  --role-arn arn:aws:iam::442799077487:role/Temp-TF-Central-Role_442799077487 \
  --role-session-name cli-test \
  --output json)

# Export credentials
export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

# Test with assumed role
aws s3 ls
aws ec2 describe-instances
```

---

## 🗑️ Cleanup (Delete Role)

### Simple Cleanup
```bash
ACCOUNT_ID="442799077487"
ROLE_NAME="Temp-TF-Central-Role_${ACCOUNT_ID}"

# Detach all managed policies
aws iam list-attached-role-policies \
  --role-name ${ROLE_NAME} \
  --query 'AttachedPolicies[*].PolicyArn' \
  --output text | xargs -I {} aws iam detach-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-arn {}

# Delete all inline policies
aws iam list-role-policies \
  --role-name ${ROLE_NAME} \
  --query 'PolicyNames[*]' \
  --output text | xargs -I {} aws iam delete-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-name {}

# Delete role
aws iam delete-role --role-name ${ROLE_NAME}
```

---

## 📋 One-Liner for All 10 Accounts

### Create in All Accounts
```bash
# Array of account IDs
ACCOUNTS=(
  "442799077487"  # RSCM
  "829990487185"  # RSPON
  "938674806253"  # SARDJITO
  "136839993415"  # RSNGOERAH
  "602006056899"  # RSJPD
  "695094375681"  # RSCM-UAT
  "741464515101"  # RSPON-UAT
  "819520291687"  # SARDJITO-UAT
  "899630542732"  # RSNGOERAH-UAT
  "148450585096"  # RSJPD-UAT
)

PROFILES=(
  "BGSI-TF-User-Executor-RSCM"
  "BGSI-TF-User-Executor-RSPON"
  "BGSI-TF-User-Executor-SARDJITO"
  "BGSI-TF-User-Executor-RSNGOERAH"
  "BGSI-TF-User-Executor-RSJPD"
  "BGSI-TF-User-Executor-RSCM-UAT"
  "BGSI-TF-User-Executor-RSPON-UAT"
  "BGSI-TF-User-Executor-SARDJITO-UAT"
  "BGSI-TF-User-Executor-RSNGOERAH-UAT"
  "BGSI-TF-User-Executor-RSJPD-UAT"
)

# Loop through all accounts
for i in "${!ACCOUNTS[@]}"; do
  ACCOUNT_ID="${ACCOUNTS[$i]}"
  PROFILE="${PROFILES[$i]}"
  ROLE_NAME="Temp-TF-Central-Role_${ACCOUNT_ID}"

  echo "Creating role in account ${ACCOUNT_ID}..."

  # Create role
  aws iam create-role \
    --role-name ${ROLE_NAME} \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": {"AWS": "arn:aws:iam::'${ACCOUNT_ID}':root"},
        "Action": "sts:AssumeRole"
      }]
    }' \
    --profile ${PROFILE} 2>/dev/null

  # Attach policy
  aws iam attach-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
    --profile ${PROFILE}

  echo "✓ Created ${ROLE_NAME}"
done
```

---

## 🎓 Common AWS Managed Policies

Instead of AdministratorAccess, you can use:

```bash
# Power User (everything except IAM)
--policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Read Only
--policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

# Specific Services
--policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
--policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
--policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
--policy-arn arn:aws:iam::aws:policy/IAMFullAccess

# Security
--policy-arn arn:aws:iam::aws:policy/SecurityAudit
--policy-arn arn:aws:iam::aws:policy/ViewOnlyAccess
```

---

## 💡 Pro Tips

### 1. Use jq to Format Output
```bash
aws iam get-role --role-name Temp-TF-Central-Role_442799077487 | jq .
```

### 2. Save Trust Policy to File
```bash
aws iam get-role \
  --role-name Temp-TF-Central-Role_442799077487 \
  --query 'Role.AssumeRolePolicyDocument' > trust-policy.json
```

### 3. Copy Role to Another Account
```bash
# Get trust policy from source
aws iam get-role \
  --role-name SourceRole \
  --profile source-account \
  --query 'Role.AssumeRolePolicyDocument' > trust.json

# Create in destination
aws iam create-role \
  --role-name DestRole \
  --assume-role-policy-document file://trust.json \
  --profile dest-account
```

### 4. Dry Run with --generate-cli-skeleton
```bash
# Generate template
aws iam create-role --generate-cli-skeleton > role-template.json

# Edit template
vim role-template.json

# Use template
aws iam create-role --cli-input-json file://role-template.json
```

---

## 🔍 Verification Commands

```bash
# Check if role exists
aws iam get-role --role-name Temp-TF-Central-Role_442799077487

# List all policies
aws iam list-attached-role-policies \
  --role-name Temp-TF-Central-Role_442799077487

# Get trust policy
aws iam get-role \
  --role-name Temp-TF-Central-Role_442799077487 \
  --query 'Role.AssumeRolePolicyDocument'

# List inline policies
aws iam list-role-policies \
  --role-name Temp-TF-Central-Role_442799077487

# Get inline policy content
aws iam get-role-policy \
  --role-name Temp-TF-Central-Role_442799077487 \
  --policy-name PolicyName
```

---

## ⚡ Ultra-Simple Single Command

The absolute simplest way to create a role with AdministratorAccess:

```bash
# Single account - inline trust policy
aws iam create-role \
  --role-name Temp-TF-Central-Role_442799077487 \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::442799077487:root"},"Action":"sts:AssumeRole"}]}' \
&& aws iam attach-role-policy \
  --role-name Temp-TF-Central-Role_442799077487 \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# That's it! Role created with full admin access.
```

---

**Remember**: Always clean up temporary roles after use! 🧹
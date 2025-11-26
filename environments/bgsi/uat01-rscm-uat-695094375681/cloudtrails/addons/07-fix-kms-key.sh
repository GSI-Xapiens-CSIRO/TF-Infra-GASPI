#!/bin/bash

AWS_ACCOUNT_ID="695094375681"
KMS_KEY_ID="53a6c0ef-934f-4c8a-a3c9-3f0eba275509"

# Check if KMS key exists
echo "Checking KMS key..."
aws kms describe-key --key-id $KMS_KEY_ID --region ap-southeast-3

# Add OpenSearch service to KMS key policy
cat > kms-key-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::$AWS_ACCOUNT_ID:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Enable OpenSearch access",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::$AWS_ACCOUNT_ID:role/opensearch-snapshot-role"
      },
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
EOF

echo "Updating KMS key policy..."
aws kms put-key-policy \
  --key-id $KMS_KEY_ID \
  --policy-name default \
  --policy file://kms-key-policy.json \
  --region ap-southeast-3

echo "KMS key policy updated"
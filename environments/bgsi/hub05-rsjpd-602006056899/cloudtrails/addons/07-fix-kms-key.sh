#!/bin/bash

AWS_ACCOUNT_ID="602006056899"
KMS_KEY_ID="fee9e8a7-3898-4cb8-bf2a-87c3b1f29e8b"

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
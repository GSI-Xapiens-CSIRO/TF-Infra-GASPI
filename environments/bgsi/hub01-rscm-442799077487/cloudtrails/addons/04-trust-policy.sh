#!/bin/bash

AWS_ACCOUNT_ID="442799077487"
KMS_KEY_ID="e9eed03c-3edf-4c9c-8fb9-d5241f3023f8"
KMS_KEY_ARN="arn:aws:kms:ap-southeast-3:$AWS_ACCOUNT_ID:key/$KMS_KEY_ID"

# Save the trust policy to a file
# ==============================================================================
echo "Saving the trust policy to a file..."
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "opensearch.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:sts::480756163420:assumed-role/cp-sts-grant-role/swift-ap-southeast-3-prod-$AWS_ACCOUNT_ID"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::$AWS_ACCOUNT_ID:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
# ==============================================================================
echo "- DONE -"


# Update the role's trust policy
# ==============================================================================
echo "Updating the role's trust policy..."

aws iam update-assume-role-policy \
  --role-name opensearch-snapshot-role \
  --policy-document file://trust-policy.json

# Add additional permissions to the role policy
cat > role-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions"
      ],
      "Resource": "arn:aws:s3:::genomic-snapshot-$AWS_ACCOUNT_ID"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts"
      ],
      "Resource": "arn:aws:s3:::genomic-snapshot-$AWS_ACCOUNT_ID/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:ReEncrypt*",
        "kms:DescribeKey"
      ],
      "Resource": "$KMS_KEY_ARN"
    }
  ]
}
EOF
# ==============================================================================
echo "- DONE -"

# Update the role's policy
# ==============================================================================
echo "Updating the role's policy..."
aws iam put-role-policy \
  --role-name opensearch-snapshot-role \
  --policy-name opensearch-snapshot-s3-access \
  --policy-document file://role-policy.json
# ==============================================================================
echo "- DONE -"

# Verify the role's trust policy
# ==============================================================================
echo "Verifying the role's trust policy..."
aws iam get-role --role-name opensearch-snapshot-role
# ==============================================================================
echo "- ALL DONE -"

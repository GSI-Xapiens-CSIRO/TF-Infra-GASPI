#!/bin/bash

AWS_ACCOUNT_ID="602006056899"

# Add PassRole permission to the master role
cat > master-role-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::$AWS_ACCOUNT_ID:role/opensearch-snapshot-role"
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name opensearch-master-role \
  --policy-name opensearch-passrole-policy \
  --policy-document file://master-role-policy.json

echo "PassRole permission added to opensearch-master-role"
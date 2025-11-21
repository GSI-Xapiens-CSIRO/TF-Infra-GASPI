#!/bin/sh

# Replace with your account ID
ACCOUNT_ID="938674806253"
ROLE_NAME="Temp-TF-Central-Role_${ACCOUNT_ID}"

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

# Verify
aws iam get-role --role-name ${ROLE_NAME}
aws iam list-attached-role-policies --role-name ${ROLE_NAME}
aws iam list-role-tags --role-name ${ROLE_NAME}
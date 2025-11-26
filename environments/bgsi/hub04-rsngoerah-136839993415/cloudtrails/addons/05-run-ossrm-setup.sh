#!/bin/bash

AWS_ACCOUNT_ID="136839993415"
ENDPOINT_URL="https://search-opensearch-$AWS_ACCOUNT_ID-3josio2q53jdyxmluxrnrrypd4.ap-southeast-3.es.amazonaws.com"
REGION="ap-southeast-3"
MASTER_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/opensearch-master-role"
SNAPSHOT_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/opensearch-snapshot-role"
BUCKET_NAME="genomic-snapshot-$AWS_ACCOUNT_ID"

OPENSEARCH_USERNAME="bgsi-master"
OPENSEARCH_PASSWORD="SuperAdmin!123456"

python ossrm-setup.py \
  --endpoint $ENDPOINT_URL \
  --username $OPENSEARCH_USERNAME \
  --password $OPENSEARCH_PASSWORD \
  --role-arn $MASTER_ROLE_ARN \
  --no-verify-ssl

sleep 5

## Daily Snapshot
python ossrm.py \
  --endpoint $ENDPOINT_URL \
  --region "ap-southeast-3" \
  --repository "genomic-snapshot-daily" \
  --bucket $BUCKET_NAME \
  --base-path "snapshots/daily" \
  --role-arn $SNAPSHOT_ROLE_ARN \
  --master-role-arn $MASTER_ROLE_ARN \
  --no-verify-ssl

sleep 5

## Weekly Snapshot
python ossrm.py \
  --endpoint $ENDPOINT_URL \
  --region "ap-southeast-3" \
  --repository "genomic-snapshot-weekly" \
  --bucket $BUCKET_NAME \
  --base-path "snapshots/weekly" \
  --role-arn $SNAPSHOT_ROLE_ARN \
  --master-role-arn $MASTER_ROLE_ARN \
  --no-verify-ssl

sleep 5

## Monthly Snapshot
python ossrm.py \
  --endpoint $ENDPOINT_URL \
  --region "ap-southeast-3" \
  --repository "genomic-snapshot-monthly" \
  --bucket $BUCKET_NAME \
  --base-path "snapshots/monthly" \
  --role-arn $SNAPSHOT_ROLE_ARN \
  --master-role-arn $MASTER_ROLE_ARN \
  --no-verify-ssl
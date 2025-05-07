#!/bin/bash

python ossrm-setup.py \
  --endpoint "https://search-opensearch-YOUR_AWS_ACCOUNT-ezdw7b4jcnjyrmsue6tc3x75n4.ap-southeast-3.es.amazonaws.com" \
  --username "gxc-admin" \
  --password "GXC4dm1n-S3cr3t" \
  --role-arn "arn:aws:iam::YOUR_AWS_ACCOUNT:role/opensearch-master-role" \
  --no-verify-ssl

sleep 5

## Daily Snapshot
python ossrm.py \
  --endpoint "https://search-opensearch-YOUR_AWS_ACCOUNT-ezdw7b4jcnjyrmsue6tc3x75n4.ap-southeast-3.es.amazonaws.com" \
  --region "ap-southeast-3" \
  --repository "genomic-snapshot-daily" \
  --bucket "genomic-snapshot-YOUR_AWS_ACCOUNT" \
  --base-path "snapshots/daily" \
  --role-arn "arn:aws:iam::YOUR_AWS_ACCOUNT:role/opensearch-snapshot-role" \
  --master-role-arn "arn:aws:iam::YOUR_AWS_ACCOUNT:role/opensearch-master-role" \
  --no-verify-ssl

sleep 5

## Weekly Snapshot
python ossrm.py \
  --endpoint "https://search-opensearch-YOUR_AWS_ACCOUNT-ezdw7b4jcnjyrmsue6tc3x75n4.ap-southeast-3.es.amazonaws.com" \
  --region "ap-southeast-3" \
  --repository "genomic-snapshot-weekly" \
  --bucket "genomic-snapshot-YOUR_AWS_ACCOUNT" \
  --base-path "snapshots/weekly" \
  --role-arn "arn:aws:iam::YOUR_AWS_ACCOUNT:role/opensearch-snapshot-role" \
  --master-role-arn "arn:aws:iam::YOUR_AWS_ACCOUNT:role/opensearch-master-role" \
  --no-verify-ssl

sleep 5

## Monthly Snapshot
python ossrm.py \
  --endpoint "https://search-opensearch-YOUR_AWS_ACCOUNT-ezdw7b4jcnjyrmsue6tc3x75n4.ap-southeast-3.es.amazonaws.com" \
  --region "ap-southeast-3" \
  --repository "genomic-snapshot-monthly" \
  --bucket "genomic-snapshot-YOUR_AWS_ACCOUNT" \
  --base-path "snapshots/monthly" \
  --role-arn "arn:aws:iam::YOUR_AWS_ACCOUNT:role/opensearch-snapshot-role" \
  --master-role-arn "arn:aws:iam::YOUR_AWS_ACCOUNT:role/opensearch-master-role" \
  --no-verify-ssl
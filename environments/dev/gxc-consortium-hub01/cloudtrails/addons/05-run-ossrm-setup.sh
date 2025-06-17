#!/bin/bash

python ossrm-setup.py \
  --endpoint "https://search-opensearch-438465168484-ezdw7b4jcnjyrmsue6tc3x75n4.ap-southeast-3.es.amazonaws.com" \
  --username "gxc-admin" \
  --password "R4nd0m-P4ssW0Rd" \
  --role-arn "arn:aws:iam::438465168484:role/opensearch-master-role" \
  --no-verify-ssl

sleep 5

## Daily Snapshot
python ossrm.py \
  --endpoint "https://search-opensearch-438465168484-ezdw7b4jcnjyrmsue6tc3x75n4.ap-southeast-3.es.amazonaws.com" \
  --region "ap-southeast-3" \
  --repository "genomic-snapshot-daily" \
  --bucket "genomic-snapshot-438465168484" \
  --base-path "snapshots/daily" \
  --role-arn "arn:aws:iam::438465168484:role/opensearch-snapshot-role" \
  --master-role-arn "arn:aws:iam::438465168484:role/opensearch-master-role" \
  --no-verify-ssl

sleep 5

## Weekly Snapshot
python ossrm.py \
  --endpoint "https://search-opensearch-438465168484-ezdw7b4jcnjyrmsue6tc3x75n4.ap-southeast-3.es.amazonaws.com" \
  --region "ap-southeast-3" \
  --repository "genomic-snapshot-weekly" \
  --bucket "genomic-snapshot-438465168484" \
  --base-path "snapshots/weekly" \
  --role-arn "arn:aws:iam::438465168484:role/opensearch-snapshot-role" \
  --master-role-arn "arn:aws:iam::438465168484:role/opensearch-master-role" \
  --no-verify-ssl

sleep 5

## Monthly Snapshot
python ossrm.py \
  --endpoint "https://search-opensearch-438465168484-ezdw7b4jcnjyrmsue6tc3x75n4.ap-southeast-3.es.amazonaws.com" \
  --region "ap-southeast-3" \
  --repository "genomic-snapshot-monthly" \
  --bucket "genomic-snapshot-438465168484" \
  --base-path "snapshots/monthly" \
  --role-arn "arn:aws:iam::438465168484:role/opensearch-snapshot-role" \
  --master-role-arn "arn:aws:iam::438465168484:role/opensearch-master-role" \
  --no-verify-ssl
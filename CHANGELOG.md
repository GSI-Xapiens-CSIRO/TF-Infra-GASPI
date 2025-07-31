# CHANGELOG HISTORY

## Version 4.27.2

- Update bashscript import terraform state `tf-import-cloudwatch.sh`
  - Add `sbeacon` AWS CloudWatch Logs subscription
  - Add `svep` AWS CloudWatch Logs subscription

- Update module `audit/cloudtrail.var-mapping.tf`
  - Add function import AWS CloudWatch Logs group `sbeacon` & `svep`

- Remove core-infra security group, using onnly from core-infra-nat-ml
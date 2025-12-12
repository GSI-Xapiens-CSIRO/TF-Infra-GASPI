# ==========================================================================
#  Module CloudTrail Only: main.tf
# --------------------------------------------------------------------------
#  Description:
#    Main Terraform Module for CloudTrail without OpenSearch
# --------------------------------------------------------------------------
#    - Workspace Environment
#    - Common Tags
# ==========================================================================

# --------------------------------------------------------------------------
#  Workspace Environment
# --------------------------------------------------------------------------
locals {
  env = terraform.workspace
}

# --------------------------------------------------------------------------
#  Global Tags
# --------------------------------------------------------------------------
locals {
  tags = {
    Environment     = "${var.environment[local.env]}"
    Department      = "${var.department}"
    DepartmentGroup = "${var.environment[local.env]}-${var.department}"
    Terraform       = true
  }
}

# --------------------------------------------------------------------------
#  Data Sources
# --------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --------------------------------------------------------------------------
#  CloudTrail
# --------------------------------------------------------------------------
resource "aws_cloudtrail" "main" {
  name                          = "cloudtrail-${var.aws_account_id_destination}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch.arn

  advanced_event_selector {
    name = "Log all management events"
    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  tags = local.tags
}

# --------------------------------------------------------------------------
#  CloudWatch Log Group
# --------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/cloudtrail-${var.aws_account_id_destination}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.cloudtrail.arn

  tags = local.tags
}
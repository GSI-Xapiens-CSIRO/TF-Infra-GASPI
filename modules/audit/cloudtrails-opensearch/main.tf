locals {
  env        = terraform.workspace == "default" ? "default" : terraform.workspace
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  common_tags = {
    Environment     = var.environment[local.env]
    Department      = var.department
    DepartmentGroup = "${var.environment[local.env]}-${var.department}"
    ResourceGroup   = "${var.environment[local.env]}-cloudtrail"
    Terraform       = true
    ServiceName     = "cloudtrail"
    LastUpdate      = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
  }

  sbeacon_functions = [for func in local.genomic_services.sbeacon.functions : "arn:aws:lambda:${local.region}:${local.account_id}:function:${func}"]
  svep_functions    = [for func in local.genomic_services.svep.functions : "arn:aws:lambda:${local.region}:${local.account_id}:function:${func}"]
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_cloudtrail" "genomic_trail" {
  name                          = "genomic-services-trail-${var.aws_account_id_destination}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch.arn

  # Advanced Event Selectors for Genomic Services
  advanced_event_selector {
    name = "Log all management events"
    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  # Read events for Lambda functions
  advanced_event_selector {
    name = "Log read data events for Lambda functions"
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }
    field_selector {
      field  = "resources.type"
      equals = ["AWS::Lambda::Function"]
    }
    field_selector {
      field  = "readOnly"
      equals = ["true"]
    }
    field_selector {
      field       = "resources.ARN"
      starts_with = concat(local.sbeacon_functions, local.svep_functions)
    }
  }

  # Write events for Lambda functions
  advanced_event_selector {
    name = "Log write data events for Lambda functions"
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }
    field_selector {
      field  = "resources.type"
      equals = ["AWS::Lambda::Function"]
    }
    field_selector {
      field  = "readOnly"
      equals = ["false"]
    }
    field_selector {
      field       = "resources.ARN"
      starts_with = concat(local.sbeacon_functions, local.svep_functions)
    }
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  depends_on = [
    aws_cloudwatch_log_group.cloudtrail,
    aws_iam_role_policy.cloudtrail_cloudwatch
  ]

  tags = local.common_tags
}

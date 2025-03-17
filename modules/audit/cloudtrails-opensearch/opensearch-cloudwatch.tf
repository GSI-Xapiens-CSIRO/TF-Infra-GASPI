# ======================================== #
# CloudWatch Log Groups #
# ======================================== #

# CloudWatch Log Groups for sBeacon functions
resource "aws_cloudwatch_log_group" "sbeacon_functions" {
  for_each = toset(local.genomic_services.sbeacon.functions)

  name = "/aws/lambda/sbeacon-${each.value}"
  # retention_in_days = var.log_retention_days
  # kms_key_id        = aws_kms_key.cloudtrail.arn

  lifecycle {
    prevent_destroy = true
    # Ignore changes to tags and configuration for existing log groups
    ignore_changes = [
      retention_in_days,
      kms_key_id,
      tags,
      tags_all
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Service  = "sBeacon"
      Function = each.value
    }
  )
}

# CloudWatch Log Groups for sVEP functions
resource "aws_cloudwatch_log_group" "svep_functions" {
  for_each = toset(local.genomic_services.svep.functions)

  name = "/aws/lambda/svep-${each.value}"
  # retention_in_days = var.log_retention_days
  # kms_key_id        = aws_kms_key.cloudtrail.arn

  lifecycle {
    prevent_destroy = true
    # Ignore changes to tags and configuration for existing log groups
    ignore_changes = [
      retention_in_days,
      kms_key_id,
      tags,
      tags_all
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Service  = "sVEP"
      Function = each.value
    }
  )
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/genomic-services-${var.aws_account_id_destination}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.cloudtrail.arn

  tags = merge(
    local.common_tags,
    {
      Name        = "cloudtrail-logs"
      Description = "CloudWatch Logs for CloudTrail and OpenSearch monitoring"
    }
  )
}


# ======================================== #
# CloudWatch Log Subscription Filters #
# ======================================== #

# CloudWatch Log Subscription Filters for sBeacon
resource "aws_cloudwatch_log_subscription_filter" "sbeacon_to_kinesis" {
  for_each = toset(local.genomic_services.sbeacon.functions)

  name           = "sbeacon-${each.value}-to-kinesis"
  log_group_name = "/aws/lambda/sbeacon-${each.value}"
  filter_pattern = local.filter_pattern
  # Point to Kinesis Stream
  destination_arn = aws_kinesis_stream.cloudtrail.arn
  role_arn        = aws_iam_role.cloudwatch_to_kinesis.arn

  depends_on = [
    aws_cloudwatch_log_group.sbeacon_functions,
    aws_kinesis_stream.cloudtrail
  ]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      log_group_name
    ]
  }
}

# CloudWatch Log Subscription Filters for sVEP
resource "aws_cloudwatch_log_subscription_filter" "svep_to_kinesis" {
  for_each = toset(local.genomic_services.svep.functions)

  name           = "svep-${each.value}-to-kinesis"
  log_group_name = "/aws/lambda/svep-${each.value}"
  filter_pattern = local.filter_pattern
  # Point to Kinesis Stream
  destination_arn = aws_kinesis_stream.cloudtrail.arn
  role_arn        = aws_iam_role.cloudwatch_to_kinesis.arn

  depends_on = [
    aws_cloudwatch_log_group.svep_functions,
    aws_kinesis_stream.cloudtrail
  ]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      log_group_name
    ]
  }
}

# CloudWatch Log Subscription Filters for Genomic-Services (CloudTrail)
resource "aws_cloudwatch_log_subscription_filter" "cloudtrail_to_kinesis" {
  name           = "cloudtrail-to-kinesis"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  filter_pattern = local.filter_pattern
  # Point to Kinesis Stream
  destination_arn = aws_kinesis_stream.cloudtrail.arn
  role_arn        = aws_iam_role.cloudwatch_to_kinesis.arn

  depends_on = [
    aws_cloudwatch_log_group.cloudtrail_processor,
    aws_kinesis_stream.cloudtrail
  ]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      log_group_name
    ]
  }
}

# CloudWatch Log Subscription Filters for Genomic-CloudTrail-Processor (CloudTrail Lambda)
resource "aws_cloudwatch_log_subscription_filter" "genomic_to_kinesis" {
  name            = "cloudtrail-processor-to-kinesis"
  log_group_name  = "/aws/lambda/${aws_lambda_function.cloudtrail_processor.function_name}"
  filter_pattern  = local.filter_pattern
  destination_arn = aws_kinesis_stream.cloudtrail.arn
  role_arn        = aws_iam_role.cloudwatch_to_kinesis.arn

  depends_on = [
    aws_cloudwatch_log_group.cloudtrail_processor,
    aws_kinesis_stream.cloudtrail
  ]

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      log_group_name
    ]
  }
}


# ======================================== #
# CloudWatch Metric Filters #
# ======================================== #

# CloudWatch Metric Filters
resource "aws_cloudwatch_log_metric_filter" "api_errors" {
  name           = "cloudtrail-api-errors"
  pattern        = "[timestamp, eventName, errorCode != null]"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "APIErrors"
    namespace     = "GenomicServices/CloudTrail" # Changed from AWS/CloudTrail
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_access" {
  name           = "cloudtrail-unauthorized-access"
  pattern        = "[timestamp, eventName, errorCode = UnauthorizedOperation]"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "UnauthorizedAccess"
    namespace     = "GenomicServices/CloudTrail" # Changed from AWS/CloudTrail
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "opensearch_delivery" {
  name           = "opensearch-delivery-status"
  pattern        = "[timestamp, delivery_status, message]"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name      = "OpenSearchDeliveryStatus"
    namespace = "GenomicServices/CloudTrail"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_errors" {
  alarm_name          = "genomic-api-errors-${var.aws_account_id_destination}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApiErrors"
  namespace           = "GenomicServices/CloudTrail"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Monitor for API errors in genomic services"
  alarm_actions       = [aws_sns_topic.cloudtrail_alerts.arn]

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "cloudtrail-lambda-processor-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors lambda processing errors"
  alarm_actions       = [aws_sns_topic.cloudtrail_alerts.arn]

  dimensions = {
    FunctionName = aws_lambda_function.cloudtrail_processor.function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_dashboard" "cloudtrail" {
  dashboard_name = "genomic-cloudtrail-${var.aws_account_id_destination}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["GenomicServices/CloudTrail", "APIErrors", { "period" : 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "API Errors"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          query  = "SOURCE '${aws_cloudwatch_log_group.cloudtrail.name}' | fields @timestamp, eventName, errorCode, errorMessage | sort @timestamp desc | limit 1000"
          region = data.aws_region.current.name
          title  = "Recent CloudTrail Events"
          view   = "table"
        }
      }
    ]
  })
}

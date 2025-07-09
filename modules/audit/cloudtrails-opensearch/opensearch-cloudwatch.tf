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

# Document Count Index
resource "aws_cloudwatch_log_metric_filter" "document_count" {
  name           = "opensearch-document-count"
  pattern        = "Bulk index complete"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "DocumentsProcessed"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}

# CloudTrail API Errors
resource "aws_cloudwatch_log_metric_filter" "api_errors" {
  name           = "cloudtrail-api-errors"
  pattern        = "[timestamp, eventName, errorCode != null]"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "APIErrors"
    namespace     = "GenomicServices/CloudTrail"
    value         = "1"
    default_value = "0"
  }
}

# Unauthorized Access
resource "aws_cloudwatch_log_metric_filter" "unauthorized_access" {
  name           = "cloudtrail-unauthorized-access"
  pattern        = "[timestamp, eventName, errorCode = UnauthorizedOperation]"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "UnauthorizedAccess"
    namespace     = "GenomicServices/CloudTrail"
    value         = "1"
    default_value = "0"
  }
}

# OpenSearch Delivery Status
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

# FIXED: Simple metric filters for Lambda processor
resource "aws_cloudwatch_log_metric_filter" "batch_operations" {
  name           = "opensearch-batch-operations"
  pattern        = "successful batches"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "BatchOperations"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "error_tracking" {
  name           = "opensearch-error-tracking"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "ErrorCount"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "batch_strategy_events" {
  name           = "opensearch-batch-strategy"
  pattern        = "Batch strategy"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "BatchStrategyEvents"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "batch_completion" {
  name           = "opensearch-batch-completion"
  pattern        = "Batch complete"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "BatchCompletions"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "lambda_invocations" {
  name           = "lambda-processing-invocations"
  pattern        = "START RequestId"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "ProcessingInvocations"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "lambda_completions" {
  name           = "lambda-processing-completions"
  pattern        = "END RequestId"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "ProcessingCompletions"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}

# ======================================== #
# CloudWatch Alarms - FIXED VERSION #
# ======================================== #

resource "aws_cloudwatch_metric_alarm" "api_errors" {
  alarm_name          = "genomic-api-errors-${var.aws_account_id_destination}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "APIErrors"
  namespace           = "GenomicServices/CloudTrail"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Monitor for API errors in genomic services"
  alarm_actions       = [aws_sns_topic.cloudtrail_alerts.arn]
  treat_missing_data  = "notBreaching"

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
  alarm_description   = "Lambda function errors detected"
  alarm_actions       = [aws_sns_topic.cloudtrail_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.cloudtrail_processor.function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "cloudtrail-lambda-duration-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "600000" # 10 minutes
  alarm_description   = "Lambda function taking too long"
  alarm_actions       = [aws_sns_topic.cloudtrail_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.cloudtrail_processor.function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "processing_errors" {
  alarm_name          = "opensearch-processing-errors-${var.aws_account_id_destination}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ErrorCount"
  namespace           = "GenomicServices/OpenSearch"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "High number of processing errors detected"
  alarm_actions       = [aws_sns_topic.cloudtrail_alerts.arn]
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "low_processing_rate" {
  alarm_name          = "opensearch-low-processing-rate-${var.aws_account_id_destination}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "BatchOperations"
  namespace           = "GenomicServices/OpenSearch"
  period              = "900" # 15 minutes
  statistic           = "Sum"
  threshold           = "1" # Less than 1 batch operation in 15 minutes
  alarm_description   = "Low batch processing rate detected"
  alarm_actions       = [aws_sns_topic.cloudtrail_alerts.arn]
  treat_missing_data  = "breaching"

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "lambda-dlq-messages-${var.aws_account_id_destination}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfVisibleMessages"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "Messages detected in Lambda Dead Letter Queue"
  alarm_actions       = [aws_sns_topic.cloudtrail_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.lambda_dlq.name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_metric_filter" "document_processing" {
  name           = "opensearch-document-processing"
  pattern        = "Bulk index complete" # Simple pattern
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "BulkIndexOperations"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "batch_strategy" {
  name           = "opensearch-batch-strategy"
  pattern        = "Batch strategy" # Simple pattern
  log_group_name = aws_cloudwatch_log_group.cloudtrail_processor.name

  metric_transformation {
    name          = "BatchStrategyEvents"
    namespace     = "GenomicServices/OpenSearch"
    value         = "1"
    default_value = "0"
  }
}


# ======================================== #
# CloudWatch Dashboard #
# ======================================== #

resource "aws_cloudwatch_dashboard" "cloudtrail" {
  dashboard_name = "genomic-cloudtrail-${var.aws_account_id_destination}"

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: Lambda Performance Metrics
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.cloudtrail_processor.function_name, { "stat" = "Average" }],
            [".", "Errors", ".", ".", { "stat" = "Sum" }],
            [".", "Invocations", ".", ".", { "stat" = "Sum" }],
            [".", "Throttles", ".", ".", { "stat" = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Lambda Performance Metrics"
          period  = 300
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      # OpenSearch Processing Metrics
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["GenomicServices/OpenSearch", "BatchOperations", { "stat" = "Sum" }],
            [".", "ErrorCount", { "stat" = "Sum" }],
            [".", "DocumentsProcessed", { "stat" = "Sum" }],
            [".", "BatchStrategyEvents", { "stat" = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "OpenSearch Processing Metrics"
          period  = 300
        }
      },
      # Infrastructure Metrics
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfVisibleMessages", "QueueName", aws_sqs_queue.lambda_dlq.name, { "stat" = "Maximum" }],
            ["AWS/Kinesis", "IncomingRecords", "StreamName", aws_kinesis_stream.cloudtrail.name, { "stat" = "Sum" }],
            [".", "OutgoingRecords", ".", ".", { "stat" = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Infrastructure Metrics"
          period  = 300
        }
      },
      # Row 2: OpenSearch Domain Health
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ES", "IndexingRate", "DomainName", aws_opensearch_domain.cloudtrail.domain_name, "ClientId", var.aws_account_id_destination, { "stat" = "Average" }],
            [".", "IndexingErrors", ".", ".", ".", ".", { "stat" = "Sum" }],
            [".", "SearchLatency", ".", ".", ".", ".", { "stat" = "Average" }],
            [".", "ClusterStatus.yellow", ".", ".", ".", ".", { "stat" = "Maximum" }],
            [".", "ClusterStatus.red", ".", ".", ".", ".", { "stat" = "Maximum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "OpenSearch Domain Health"
          period  = 300
        }
      },
      # System Resource Utilization
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ES", "CPUUtilization", "DomainName", aws_opensearch_domain.cloudtrail.domain_name, "ClientId", var.aws_account_id_destination, { "stat" = "Average" }],
            [".", "MemoryUtilization", ".", ".", ".", ".", { "stat" = "Average" }],
            [".", "StorageUtilization", ".", ".", ".", ".", { "stat" = "Average" }],
            [".", "JVMMemoryPressure", ".", ".", ".", ".", { "stat" = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "OpenSearch Resource Utilization"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      # Row 3: Error Analysis
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 12
        height = 8
        properties = {
          query  = "SOURCE '${aws_cloudwatch_log_group.cloudtrail_processor.name}' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 100"
          region = var.aws_region
          title  = "Recent Errors"
          view   = "table"
        }
      },
      # Successful Processing Analysis
      {
        type   = "log"
        x      = 12
        y      = 12
        width  = 12
        height = 8
        properties = {
          query  = "SOURCE '${aws_cloudwatch_log_group.cloudtrail_processor.name}' | fields @timestamp, @message | filter @message like /successful batches/ | sort @timestamp desc | limit 50"
          region = var.aws_region
          title  = "Recent Successful Operations"
          view   = "table"
        }
      },
      # Row 4: Batch Processing Analysis
      {
        type   = "log"
        x      = 0
        y      = 20
        width  = 12
        height = 8
        properties = {
          query  = "SOURCE '${aws_cloudwatch_log_group.cloudtrail_processor.name}' | fields @timestamp, @message | filter @message like /Batch.*MB/ | parse @message 'Batch *: * docs, *MB' as batch_num, doc_count, payload_size | stats avg(payload_size), max(payload_size), count() by bin(5m) | sort @timestamp desc"
          region = var.aws_region
          title  = "Batch Size Analysis"
          view   = "table"
        }
      },
      # Performance Trends
      {
        type   = "log"
        x      = 12
        y      = 20
        width  = 12
        height = 8
        properties = {
          query  = "SOURCE '${aws_cloudwatch_log_group.cloudtrail_processor.name}' | fields @timestamp, @message | filter @message like /Duration.*ms/ | parse @message 'Duration: * ms' as duration | stats avg(duration), max(duration), min(duration) by bin(5m) | sort @timestamp desc"
          region = var.aws_region
          title  = "Lambda Duration Trends"
          view   = "table"
        }
      },
      # Row 5: CloudTrail API Activity
      {
        type   = "metric"
        x      = 0
        y      = 28
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["GenomicServices/CloudTrail", "APIErrors", { "stat" = "Sum" }],
            [".", "UnauthorizedAccess", { "stat" = "Sum" }],
            [".", "OpenSearchDeliveryStatus", { "stat" = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "CloudTrail API Activity"
          period  = 300
        }
      },
      # Kinesis Stream Health
      {
        type   = "metric"
        x      = 8
        y      = 28
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/Kinesis", "IncomingBytes", "StreamName", aws_kinesis_stream.cloudtrail.name, { "stat" = "Sum" }],
            [".", "OutgoingBytes", ".", ".", { "stat" = "Sum" }],
            [".", "WriteProvisionedThroughputExceeded", ".", ".", { "stat" = "Sum" }],
            [".", "ReadProvisionedThroughputExceeded", ".", ".", { "stat" = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Kinesis Stream Health"
          period  = 300
        }
      },
      # Processing Summary
      {
        type   = "metric"
        x      = 16
        y      = 28
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["GenomicServices/OpenSearch", "ProcessingInvocations", { "stat" = "Sum" }],
            [".", "ProcessingCompletions", { "stat" = "Sum" }],
            [".", "BatchCompletions", { "stat" = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Processing Summary"
          period  = 300
        }
      }
    ]
  })
}

# ======================================== #
# CloudWatch Dashboard - Overview Summary #
# ======================================== #

resource "aws_cloudwatch_dashboard" "cloudtrail_overview" {
  dashboard_name = "genomic-cloudtrail-overview-${var.aws_account_id_destination}"

  dashboard_body = jsonencode({
    widgets = [
      # High-level KPIs
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 6
        height = 3
        properties = {
          metrics = [
            ["GenomicServices/OpenSearch", "DocumentsProcessed"]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Documents Processed (24h)"
          period = 86400
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 0
        width  = 6
        height = 3
        properties = {
          metrics = [
            ["GenomicServices/OpenSearch", "ErrorCount"]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Errors (24h)"
          period = 86400
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 6
        height = 3
        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.cloudtrail_processor.function_name]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Avg Duration (1h)"
          period = 3600
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 0
        width  = 6
        height = 3
        properties = {
          metrics = [
            ["AWS/ES", "CPUUtilization", "DomainName", aws_opensearch_domain.cloudtrail.domain_name, "ClientId", var.aws_account_id_destination]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "OpenSearch CPU %"
          period = 300
          stat   = "Average"
        }
      },
      # System Health Overview
      {
        type   = "metric"
        x      = 0
        y      = 3
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["GenomicServices/OpenSearch", "BatchOperations", { "label" = "Successful Batches" }],
            [".", "ErrorCount", { "label" = "Processing Errors" }],
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.cloudtrail_processor.function_name, { "label" = "Lambda Invocations" }],
            [".", "Errors", ".", ".", { "label" = "Lambda Errors" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "System Health Overview - Last 6 Hours"
          period  = 300
          stat    = "Sum"
        }
      }
    ]
  })
}

# ======================================== #
# CloudWatch Dashboard URLs Output #
# ======================================== #

output "cloudwatch_dashboard_url" {
  description = "URL for enhanced CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.cloudtrail.dashboard_name}"
}

output "cloudwatch_dashboard_overview_url" {
  description = "URL for overview CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.cloudtrail_overview.dashboard_name}"
}

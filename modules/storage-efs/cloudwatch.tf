# --------------------------------------------------------------------------
# CloudWatch Metric Alarms for EFS
# --------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "storage_bytes" {
  alarm_name          = "${var.prefix_name}-efs-storage-bytes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "StorageBytes"
  namespace          = "AWS/EFS"
  period             = "300"  # 5 minutes
  statistic          = "Average"
  threshold          = var.storage_bytes_threshold
  alarm_description  = "EFS Storage Used exceeds threshold"
  alarm_actions      = [var.sns_topic_arn]
  ok_actions         = [var.sns_topic_arn]

  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix_name}-efs-storage-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "io_limit" {
  alarm_name          = "${var.prefix_name}-efs-io-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "PercentIOLimit"
  namespace          = "AWS/EFS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.io_limit_threshold
  alarm_description  = "EFS IO Limit percentage exceeds threshold"
  alarm_actions      = [var.sns_topic_arn]
  ok_actions         = [var.sns_topic_arn]

  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix_name}-efs-io-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "burst_credit_balance" {
  count               = var.throughput_mode == "bursting" ? 1 : 0
  alarm_name          = "${var.prefix_name}-efs-burst-credits"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "BurstCreditBalance"
  namespace          = "AWS/EFS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.burst_credit_threshold
  alarm_description  = "EFS Burst Credit Balance is below threshold"
  alarm_actions      = [var.sns_topic_arn]
  ok_actions         = [var.sns_topic_arn]

  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix_name}-efs-burst-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "client_connections" {
  alarm_name          = "${var.prefix_name}-efs-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "ClientConnections"
  namespace          = "AWS/EFS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.client_connections_threshold
  alarm_description  = "EFS Client Connections exceed threshold"
  alarm_actions      = [var.sns_topic_arn]
  ok_actions         = [var.sns_topic_arn]

  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix_name}-efs-connections-alarm"
    }
  )
}

# --------------------------------------------------------------------------
# CloudWatch Dashboard for EFS
# --------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "efs" {
  dashboard_name = "${var.prefix_name}-efs-dashboard"

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
            ["AWS/EFS", "StorageBytes", "FileSystemId", aws_efs_file_system.main.id, "StorageClass", "Total"],
            [".", ".", ".", ".", ".", "Standard"],
            [".", ".", ".", ".", ".", "IA"]
          ]
          view    = "timeSeries"
          stacked = true
          region  = var.aws_region
          title   = "EFS Storage Usage"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EFS", "PercentIOLimit", "FileSystemId", aws_efs_file_system.main.id]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "IO Limit Usage"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EFS", "BurstCreditBalance", "FileSystemId", aws_efs_file_system.main.id]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "Burst Credit Balance"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EFS", "ClientConnections", "FileSystemId", aws_efs_file_system.main.id]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "Client Connections"
          period  = 300
        }
      }
    ]
  })
}
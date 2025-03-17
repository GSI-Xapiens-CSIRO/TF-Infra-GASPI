# --------------------------------------------------------------------------
#  SNS Topic Policy
# --------------------------------------------------------------------------
resource "aws_sns_topic_policy" "cloudtrail_alerts" {
  arn = aws_sns_topic.cloudtrail_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.cloudtrail_alerts.arn
      }
    ]
  })
}


resource "aws_sns_topic" "cloudtrail_alerts" {
  name              = "genomic-cloudtrail-alerts-${var.aws_account_id_destination}"
  kms_master_key_id = aws_kms_key.cloudtrail.arn

  tags = local.common_tags
}

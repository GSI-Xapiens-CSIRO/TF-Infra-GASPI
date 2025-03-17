# --------------------------------------------------------------------------
# Bucket Notifications (Optional)
# --------------------------------------------------------------------------
resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.enable_notifications ? 1 : 0
  bucket = aws_s3_bucket.main.id

  topic {
    topic_arn     = var.sns_topic_arn
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix = ".log"
  }
}

# --------------------------------------------------------------------------
# Replication Configuration for Data Durability
# --------------------------------------------------------------------------
resource "aws_s3_bucket_replication_configuration" "main" {
  count  = var.enable_replication ? 1 : 0
  bucket = aws_s3_bucket.main.id
  role   = var.replication_role_arn

  rule {
    id       = local.env!= "prod" ? "default" : "LongTermDataReplication"
    status   = "Enabled"
    priority = 1

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }

    destination {
      bucket        = var.destination_bucket_arn
      storage_class = local.env!= "prod" ? "STANDARD" : "GLACIER"

      encryption_configuration {
        replica_kms_key_id = "${var.kms_key[local.env]}"
      }
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }
}

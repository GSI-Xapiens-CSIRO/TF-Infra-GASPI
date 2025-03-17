# --------------------------------------------------------------------------
# Intelligent Tiering Configuration
# --------------------------------------------------------------------------
resource "aws_s3_bucket_intelligent_tiering_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  name   = "LongTermStorage"

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 365
  }

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 180
  }
}

# --------------------------------------------------------------------------
# Lifecycle Rules for Long-term Storage
# --------------------------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "LongTermRetention"
    status = "Enabled"

    # Initial transition to Standard-IA
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier
    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    # Final transition to Deep Archive
    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = 180
      storage_class   = "DEEP_ARCHIVE"
    }

    # Keep all versions for compliance
    expiration {
      expired_object_delete_marker = true
    }
  }

  # Special handling for logs
  rule {
    id     = "LogsRetention"
    status = "Enabled"

    # filter {
    #   prefix = "CloudTrail/"
    # }

    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

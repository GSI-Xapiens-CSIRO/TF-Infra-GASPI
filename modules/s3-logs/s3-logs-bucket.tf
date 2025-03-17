# ==========================================================================
#  Module S3 Logs: s3-logs-bucket.tf
# --------------------------------------------------------------------------
#  Description:
#    S3 Logs Bucket
# --------------------------------------------------------------------------
#    - Bucket Logs
#    - Bucket Versioning
#    - Bucket Encryption
#    - Bucket Lifecycle
#    - Bucket Policy
# ==========================================================================

resource "aws_s3_bucket" "logs" {
  provider      = aws.destination
  bucket_prefix = var.bucket_prefix
  force_destroy = true

  tags = merge(
    local.tags,
    var.common_tags,
    {
      Name = "GXC sBeacon Central Logs"
    }
  )
}

resource "aws_s3_bucket_versioning" "logs" {
  provider = aws.destination
  bucket   = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  provider = aws.destination
  bucket   = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  provider = aws.destination
  bucket   = aws_s3_bucket.logs.id

  dynamic "rule" {
    for_each = var.retention_config

    content {
      id     = "${rule.key}-logs-lifecycle"
      status = "Enabled"

      filter {
        prefix = "${rule.key}/"
      }

      transition {
        days          = rule.value.standard_ia_days
        storage_class = "STANDARD_IA"
      }

      transition {
        days          = rule.value.glacier_days
        storage_class = "GLACIER"
      }

      expiration {
        days = rule.value.expiration_days
      }
    }
  }
}

data "aws_iam_policy_document" "logs" {
  dynamic "statement" {
    for_each = var.allowed_account_ids

    content {
      sid    = "Allow${statement.value.name}Logs"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${statement.value.account_id}:root"]
      }
      actions = [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ]
      resources = [
        "${aws_s3_bucket.logs.arn}/*/${statement.value.name}/*"
      ]
    }
  }

  statement {
    sid    = "EnforceSSLOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  provider = aws.destination
  bucket   = aws_s3_bucket.logs.id
  policy   = data.aws_iam_policy_document.logs.json
}

resource "aws_s3_bucket_public_access_block" "logs" {
  provider = aws.destination
  bucket   = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

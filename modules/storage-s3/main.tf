locals {
  env            = terraform.workspace
  prefix_name    = var.prefix_name
  aws_account_id = var.aws_account_id_destination
  aws_region     = var.aws_region
  bucket_name    = "${local.prefix_name}-${local.aws_account_id}"

  common_tags = {
    Environment     = "${var.environment[local.env]}"
    Department      = "${var.department}"
    DepartmentGroup = "${var.environment[local.env]}-${var.department}"
    Terraform       = true
  }
}

# --------------------------------------------------------------------------
# S3 Bucket with Long-term Retention
# --------------------------------------------------------------------------
resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  force_destroy = local.env != "prod" ? true : false

  tags = merge(
    var.common_tags,
    {
      Name               = "${local.bucket_name}"
      Service            = "S3"
      RetentionPeriod    = "25-Years"
      DataClassification = "Business-Critical"
    }
  )
}

# --------------------------------------------------------------------------
# Enhanced Bucket Versioning
# --------------------------------------------------------------------------
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.main]
}

# --------------------------------------------------------------------------
# Object Lock Configuration for Compliance
# --------------------------------------------------------------------------
resource "aws_s3_bucket_object_lock_configuration" "main" {
  # Only create if versioning is enabled
  count = var.enable_object_lock ? 1 : 0

  bucket = aws_s3_bucket.main.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 25 * 365 # 25 years
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}

# --------------------------------------------------------------------------
# Enhanced Server-Side Encryption
# --------------------------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key[local.env]
    }
    bucket_key_enabled = true
  }
}

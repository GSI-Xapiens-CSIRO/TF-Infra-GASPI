locals {
  env            = terraform.workspace
  prefix_name    = var.prefix_name
  aws_account_id = var.aws_account_id_destination
  aws_region     = var.aws_region
  bucket_name    = "${local.prefix_name}-s3-${local.env}"

  common_tags = {
    Environment     = "${var.environment[local.env]}"
    Department      = "${var.department}"
    DepartmentGroup = "${var.environment[local.env]}-${var.department}"
    Terraform       = true
  }
}

# --------------------------------------------------------------------------
# EFS File System
# --------------------------------------------------------------------------
resource "aws_efs_file_system" "main" {
  creation_token = "${var.prefix_name}-efs"
  encrypted      = true
  kms_key_id     = var.kms_key[local.env]

  performance_mode = var.performance_mode
  throughput_mode = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia != null ? [1] : []
    content {
      transition_to_ia = var.transition_to_ia
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix_name}-efs"
    }
  )
}

# --------------------------------------------------------------------------
# Mount Targets
# --------------------------------------------------------------------------
resource "aws_efs_mount_target" "main" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

# --------------------------------------------------------------------------
# Backup Policy
# --------------------------------------------------------------------------
resource "aws_efs_backup_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  backup_policy {
    status = var.enable_backup ? "ENABLED" : "DISABLED"
  }
}

# --------------------------------------------------------------------------
# Replication Configuration (Optional)
# --------------------------------------------------------------------------
resource "aws_efs_replication_configuration" "main" {
  count              = var.enable_replication ? 1 : 0
  source_file_system_id = aws_efs_file_system.main.id

  destination {
    region = var.replication_destination_region
    kms_key_id = var.replication_kms_key_id
  }
}
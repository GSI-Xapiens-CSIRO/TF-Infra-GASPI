# --------------------------------------------------------------------------
# Access Point (Optional)
# --------------------------------------------------------------------------
resource "aws_efs_access_point" "main" {
  count          = var.create_access_point ? 1 : 0
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    gid = var.access_point_gid
    uid = var.access_point_uid
  }

  root_directory {
    path = "/${var.access_point_path}"
    creation_info {
      owner_gid   = var.access_point_gid
      owner_uid   = var.access_point_uid
      permissions = "0755"
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix_name}-efs-ap"
    }
  )
}

# --------------------------------------------------------------------------
# Outputs
# --------------------------------------------------------------------------
output "efs_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.main.id
}

output "efs_arn" {
  description = "The ARN of the EFS file system"
  value       = aws_efs_file_system.main.arn
}

output "mount_targets" {
  description = "List of mount target IDs"
  value       = aws_efs_mount_target.main[*].id
}

output "mount_target_ips" {
  description = "List of mount target IPs"
  value       = aws_efs_mount_target.main[*].ip_address
}

output "security_group_id" {
  description = "ID of the EFS security group"
  value       = aws_security_group.efs.id
}

output "dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.main.dns_name
}

output "access_point_id" {
  description = "ID of the EFS access point"
  value       = var.create_access_point ? aws_efs_access_point.main[0].id : null
}
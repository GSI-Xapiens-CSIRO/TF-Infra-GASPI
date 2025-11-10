# ==========================================================================
#  Module IAM User: output.tf
# --------------------------------------------------------------------------
#  Description
#    Output Terraform Value
# --------------------------------------------------------------------------
#    - List Group
#    - List Policy
#    - List Role
#    - List User
# ==========================================================================

# --------------------------------------------------------------------------
#  List Group
# --------------------------------------------------------------------------
output "developer_group_name" {
  description = "Developer Group Name"
  value       = aws_iam_group.gxc_developer.name
}

output "developer_group_arn" {
  description = "Developer Group Name"
  value       = aws_iam_group.gxc_developer.arn
}

output "admin_group_name" {
  description = "Administrator Group Name"
  value       = aws_iam_group.gxc_administrator.name
}

output "admin_group_arn" {
  description = "Administrator Group Name"
  value       = aws_iam_group.gxc_administrator.arn
}

# --------------------------------------------------------------------------
#  List Policy
# --------------------------------------------------------------------------
output "gxc_developer_policy" {
  description = "GXC Developer Policy Name"
  value       = aws_iam_policy.gxc_developer_policy.name
}

output "gxc_developer_policy_arn" {
  description = "GXC Developer Policy ARN"
  value       = aws_iam_policy.gxc_developer_policy.arn
}

# --------------------------------------------------------------------------
#  List User
# --------------------------------------------------------------------------
output "list_xti_developer" {
  description = "XTI Developer Account"
  value       = var.xti_team_developer
}

output "list_xti_administrator" {
  description = "XTI Administrator Account"
  value       = var.xti_team_administrator
}

output "list_bgsi_developer" {
  description = "BGSI Developer Account"
  value       = var.bgsi_team_developer
}

output "list_bgsi_administrator" {
  description = "BGSI Administrator Account"
  value       = var.bgsi_team_administrator
}

# --------------------------------------------------------------------------
#  Summary
# --------------------------------------------------------------------------
locals {
  summary = <<SUMMARY
Developer:
  Group Name:        ${aws_iam_group.gxc_developer.name}
  Group ARN:         ${aws_iam_group.gxc_developer.arn}
  Policy Name:       ${aws_iam_policy.gxc_developer_policy.name}
  Policy ARN:
    - ${aws_iam_policy.gxc_developer_policy.arn}
    - ${local.ARN_Policy_AmazonDynamoDBFullAccess}
    - ${local.ARN_Policy_AWSLambda_FullAccess}
    - ${local.ARN_Policy_AmazonRedshiftFullAccess}
    - ${local.ARN_Policy_AmazonS3FullAccess}
    - ${aws_iam_policy.gxc_poweruser_acess.arn}
Administrator:
  Group Name:        ${aws_iam_group.gxc_administrator.name}
  Group ARN:         ${aws_iam_group.gxc_administrator.arn}
  Policy ARN:
    - ${local.ARN_Policy_AdministratorAccess}
    - ${local.ARN_Policy_AWSOrganizationsFullAccess}
    - ${aws_iam_policy.gxc_iamfull_acess.arn}
SUMMARY
}

output "summary" {
  description = "Summary IAM User Configuration"
  value       = local.summary
}
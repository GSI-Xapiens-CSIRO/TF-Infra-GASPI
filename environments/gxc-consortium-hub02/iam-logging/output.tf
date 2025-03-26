# ==========================================================================
#  127214202110 - IAM Logging: output.tf
# --------------------------------------------------------------------------
#  Description
#    Output Terraform Value
# --------------------------------------------------------------------------
#    - IAM Logging Roles
#    - IAM Logging Policies
#    - IAM Logging Enabled Services
# ==========================================================================

output "logging_roles" {
  description = "Created logging roles for hub01"
  value       = module.hub_logging_roles.logging_roles
}

output "logging_policies" {
  description = "Created logging policies for hub01"
  value       = module.hub_logging_roles.logging_policies
}

output "role_policy_attachments" {
  description = "Role policy attachments for hub01"
  value       = module.hub_logging_roles.role_policy_attachments
}
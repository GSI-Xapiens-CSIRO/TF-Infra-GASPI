# ==========================================================================
#  Module IAM User: iam-variable.tf
# --------------------------------------------------------------------------
#  Description:
#    IAM Variable
# --------------------------------------------------------------------------
#    - Group Developer
#    - Group Administrator
#    - Policy Developer
#    - Policy Administrator
#    - Role Developer
#    - Role Administrator
# ==========================================================================

# --------------------------------------------------------------------------
#  Group Name
# --------------------------------------------------------------------------
variable "group_gxc_developer" {
  description = "Developer Group Name"
  type        = string
}

variable "group_gxc_administrator" {
  description = "Administrator Group Name"
  type        = string
}

# --------------------------------------------------------------------------
#  Policy Name
# --------------------------------------------------------------------------
variable "policy_gxc_developer" {
  description = "Developer Policy Name"
  type        = string
}

variable "policy_gxc_administrator" {
  description = "Administrator Policy Name"
  type        = string
}

# --------------------------------------------------------------------------
#  TF-User Account
# --------------------------------------------------------------------------
variable "tf_user_executor" {
  description = "TF User Executor"
  type        = string
}

# --------------------------------------------------------------------------
#  User Team
# --------------------------------------------------------------------------
variable "xti_team_developer" {
  description = "XTI Developer Team Member"
  type        = list(any)
}

variable "xti_team_administrator" {
  description = "XTI Administrator Team Member"
  type        = list(any)
}

variable "bgsi_team_developer" {
  description = "BGSI Developer Team Member"
  type        = list(any)
}

variable "bgsi_team_administrator" {
  description = "BGSI Administrator Team Member"
  type        = list(any)
}
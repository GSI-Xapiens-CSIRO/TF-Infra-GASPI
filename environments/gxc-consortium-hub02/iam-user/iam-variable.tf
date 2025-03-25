# ==========================================================================
#  127214202110 - IAM: iam-variable.tf
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
  default     = "gxc-developer"
}

variable "group_gxc_administrator" {
  description = "Administrator Group Name"
  type        = string
  default     = "gxc-administrator"
}

# --------------------------------------------------------------------------
#  Policy Name
# --------------------------------------------------------------------------
variable "policy_gxc_developer" {
  description = "Developer Policy Name"
  type        = string
  default     = "gxc-developer-policy"
}

variable "policy_gxc_administrator" {
  description = "Administrator Policy Name"
  type        = string
  default     = "gxc-administrator-policy"
}

# --------------------------------------------------------------------------
#  TF-User Account
# --------------------------------------------------------------------------
variable "tf_user_executor" {
  description = "TF User Executor"
  type        = string
  default     = "TF-User-Executor-127214202110"
}

# --------------------------------------------------------------------------
#  User Team
# --------------------------------------------------------------------------
variable "xti_team_developer" {
  description = "XTI Developer Team Member"
  type        = list(any)
  default = [
    "xti.developer01@xapiens.id",
    "xti.developer02@xapiens.id",
    "xti.developer03@xapiens.id"
  ]
}

variable "xti_team_administrator" {
  description = "XTI Administrator Team Member"
  type        = list(any)
  default = [
    "xti.admin01@xapiens.id",
    "xti.admin02@xapiens.id"
  ]
}

variable "csiro_team_developer" {
  description = "CSIRO Developer Team Member"
  type        = list(any)
  default = [
    "csiro.developer01@csiro.au",
    "csiro.developer02@csiro.au",
    "csiro.developer03@csiro.au"
  ]
}

variable "csiro_team_administrator" {
  description = "CSIRO Administrator Team Member"
  type        = list(any)
  default = [
    "csiro.admin01@csiro.au",
    "csiro.admin02@csiro.au"
  ]
}
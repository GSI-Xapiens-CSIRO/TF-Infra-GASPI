# ==========================================================================
#  136839993415 - IAM: iam-variable.tf
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
  default     = "TF-User-Executor-136839993415"
}

# --------------------------------------------------------------------------
#  User Team
# --------------------------------------------------------------------------
variable "gxc_team_developer" {
  description = "XTI Developer Team Member"
  type        = list(any)
  default = [
    "gxc.developer01@xapiens.id",
    "gxc.developer02@xapiens.id",
    "gxc.developer03@xapiens.id"
  ]
}

variable "gxc_team_administrator" {
  description = "XTI Administrator Team Member"
  type        = list(any)
  default = [
    "gxc.admin01@xapiens.id",
    "gxc.admin02@xapiens.id"
  ]
}

variable "bgsi_team_developer" {
  description = "BGSI Developer Team Member"
  type        = list(any)
  default = [
    "bgsi.developer01@binomika.kemkes.go.id",
    "bgsi.developer02@binomika.kemkes.go.id",
    "bgsi.developer03@binomika.kemkes.go.id"
  ]
}

variable "bgsi_team_administrator" {
  description = "BGSI Administrator Team Member"
  type        = list(any)
  default = [
    "bgsi.admin01@binomika.kemkes.go.id",
    "bgsi.admin02@binomika.kemkes.go.id"
  ]
}
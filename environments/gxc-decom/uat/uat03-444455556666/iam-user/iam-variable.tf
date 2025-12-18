# ==========================================================================
#  111122223333 - IAM: iam-variable.tf
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
  default     = "TF-User-Executor-111122223333"
}

# --------------------------------------------------------------------------
#  User Team
# --------------------------------------------------------------------------
variable "xti_team_developer" {
  description = "XTI Developer Team Member"
  type        = list(any)
  default = [
    "eko.muhrodin@xapiens.id",
    "bagus.wisanggeni@xapiens.id",
    "indra.prabowo@xapiens.id",
    "azady.goenadhi@xapiens.id",
    "nugraha.ardi@xapiens.id",
    "erik.firmansyah@xapiens.id"
  ]
}

variable "xti_team_administrator" {
  description = "XTI Administrator Team Member"
  type        = list(any)
  default = [
    "dwi.denni@xapiens.id",
    "titus.prasetyo@xapiens.id",
    "fajar.septiawan@xapiens.id"
  ]
}

variable "csiro_team_developer" {
  description = "CSIRO Developer Team Member"
  type        = list(any)
  default = [
    "anuradha.wickramarachchi@csiro.au",
    "nick.edwards@csiro.au",
    "brendan.hosking@csiro.au",
    "mitchell.obrien@csiro.au"
  ]
}

variable "csiro_team_administrator" {
  description = "CSIRO Administrator Team Member"
  type        = list(any)
  default = [
    "yatish.jain@csiro.au"
  ]
}
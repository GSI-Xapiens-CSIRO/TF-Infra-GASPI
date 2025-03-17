# ==========================================================================
#  Module IAM User: iam-group.tf
# --------------------------------------------------------------------------
#  Description:
#    IAM Group Name
# --------------------------------------------------------------------------
#    - Group Developer
#    - Group Administrator
# ==========================================================================

# --------------------------------------------------------------------------
#  IAM Group
# --------------------------------------------------------------------------
resource "aws_iam_group" "gxc_developer" {
  provider = aws.destination
  name     = "${var.group_gxc_developer}_${var.aws_account_id_destination}_${var.workspace_env[local.env]}"
}

resource "aws_iam_group" "gxc_administrator" {
  provider = aws.destination
  name     = "${var.group_gxc_administrator}_${var.aws_account_id_destination}_${var.workspace_env[local.env]}"
}

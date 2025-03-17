# ==========================================================================
#  Module IAM User: iam-user-group.tf
# --------------------------------------------------------------------------
#  Description:
#    IAM Grouping User
# --------------------------------------------------------------------------
#    - Group Administrator
#    - Group Developer
# ==========================================================================

# --------------------------------------------------------------------------
#  IAM User Group (Developer)
# --------------------------------------------------------------------------
resource "aws_iam_user_group_membership" "xti_developer" {
  provider = aws.destination
  for_each = toset(
    local.xti_team_developer
  )

  user = lower(each.key)

  groups = [
    aws_iam_group.gxc_developer.name,
  ]
}

resource "aws_iam_user_group_membership" "csiro_developer" {
  provider = aws.destination
  for_each = toset(
    local.csiro_team_developer
  )

  user = lower(each.key)

  groups = [
    aws_iam_group.gxc_developer.name,
  ]
}


# --------------------------------------------------------------------------
#  IAM User Group (Administrator)
# --------------------------------------------------------------------------
resource "aws_iam_user_group_membership" "xti_team_administrator" {
  provider = aws.destination
  for_each = toset(
    local.xti_team_administrator
  )

  user = lower(each.key)

  groups = [
    aws_iam_group.gxc_administrator.name,
  ]
}

resource "aws_iam_user_group_membership" "csiro_team_administrator" {
  provider = aws.destination
  for_each = toset(
    local.csiro_team_administrator
  )

  user = lower(each.key)

  groups = [
    aws_iam_group.gxc_administrator.name,
  ]
}

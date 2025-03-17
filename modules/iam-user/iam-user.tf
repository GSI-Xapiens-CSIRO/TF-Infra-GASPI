# ==========================================================================
#  Module IAM User: iam-user.tf
# --------------------------------------------------------------------------
#  Description:
#    IAM List Account
# --------------------------------------------------------------------------
#    - List Administrator Account
#    - List Developer Account
# ==========================================================================

# --------------------------------------------------------------------------
#  IAM User
# --------------------------------------------------------------------------

locals {
  iam_xti_tags = {
    "Team" = "XTI"
  }

  iam_csiro_tags = {
    "Team" = "CSIRO"
  }

  xti_team_developer       = var.xti_team_developer
  xti_team_administrator   = var.xti_team_administrator
  csiro_team_developer     = var.csiro_team_developer
  csiro_team_administrator = var.csiro_team_administrator
}

# --------------------------------------------------------------------------
#  XTI Developer Team
# --------------------------------------------------------------------------
resource "aws_iam_user" "xti_developer" {
  provider = aws.destination

  ## Group: Developer
  for_each = toset(
    local.xti_team_developer
  )

  name = each.key

  tags = merge(
    local.tags,
    local.iam_xti_tags,
    {
      Name          = "${lower(each.key)}"
      ResourceGroup = "IAM-GXC"
      Services      = "IAM"
    }
  )
}

# --------------------------------------------------------------------------
#  XTI Administrator Team
# --------------------------------------------------------------------------
resource "aws_iam_user" "xti_admin" {
  provider = aws.destination

  ## Group: Administrator
  for_each = toset(
    local.xti_team_administrator
  )

  name = each.key

  tags = merge(
    local.tags,
    local.iam_xti_tags,
    {
      Name          = "${lower(each.key)}"
      ResourceGroup = "IAM-GXC"
      Services      = "IAM"
    }
  )
}

# --------------------------------------------------------------------------
#  CSIRO Developer Team
# --------------------------------------------------------------------------
resource "aws_iam_user" "csiro_developer" {
  provider = aws.destination

  ## Group: Developer
  for_each = toset(
    local.csiro_team_developer
  )

  name = each.key

  tags = merge(
    local.tags,
    local.iam_csiro_tags,
    {
      Name          = "${lower(each.key)}"
      ResourceGroup = "IAM-GXC"
      Services      = "IAM"
    }
  )
}

# --------------------------------------------------------------------------
#  CSIRO Administrator Team
# --------------------------------------------------------------------------
resource "aws_iam_user" "csiro_admin" {
  provider = aws.destination

  ## Group: Administrator
  for_each = toset(
    local.csiro_team_administrator
  )

  name = each.key

  tags = merge(
    local.tags,
    local.iam_csiro_tags,
    {
      Name          = "${lower(each.key)}"
      ResourceGroup = "IAM-GXC"
      Services      = "IAM"
    }
  )
}

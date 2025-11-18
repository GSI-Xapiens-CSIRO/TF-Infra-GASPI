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
  iam_gxc_tags = {
    "Team" = "XTI"
  }

  iam_bgsi_tags = {
    "Team" = "BGSI"
  }

  gxc_team_developer      = var.gxc_team_developer
  gxc_team_administrator  = var.gxc_team_administrator
  bgsi_team_developer     = var.bgsi_team_developer
  bgsi_team_administrator = var.bgsi_team_administrator
}

# --------------------------------------------------------------------------
#  XTI Developer Team
# --------------------------------------------------------------------------
resource "aws_iam_user" "gxc_developer" {
  provider = aws.destination

  ## Group: Developer
  for_each = toset(
    local.gxc_team_developer
  )

  name = each.key

  tags = merge(
    local.tags,
    local.iam_gxc_tags,
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
resource "aws_iam_user" "gxc_admin" {
  provider = aws.destination

  ## Group: Administrator
  for_each = toset(
    local.gxc_team_administrator
  )

  name = each.key

  tags = merge(
    local.tags,
    local.iam_gxc_tags,
    {
      Name          = "${lower(each.key)}"
      ResourceGroup = "IAM-GXC"
      Services      = "IAM"
    }
  )
}

# --------------------------------------------------------------------------
#  BGSI Developer Team
# --------------------------------------------------------------------------
resource "aws_iam_user" "bgsi_developer" {
  provider = aws.destination

  ## Group: Developer
  for_each = toset(
    local.bgsi_team_developer
  )

  name = each.key

  tags = merge(
    local.tags,
    local.iam_bgsi_tags,
    {
      Name          = "${lower(each.key)}"
      ResourceGroup = "IAM-GXC"
      Services      = "IAM"
    }
  )
}

# --------------------------------------------------------------------------
#  BGSI Administrator Team
# --------------------------------------------------------------------------
resource "aws_iam_user" "bgsi_admin" {
  provider = aws.destination

  ## Group: Administrator
  for_each = toset(
    local.bgsi_team_administrator
  )

  name = each.key

  tags = merge(
    local.tags,
    local.iam_bgsi_tags,
    {
      Name          = "${lower(each.key)}"
      ResourceGroup = "IAM-GXC"
      Services      = "IAM"
    }
  )
}

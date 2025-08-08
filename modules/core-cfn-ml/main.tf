# ==========================================================================
#  Module Core: main.tf
# --------------------------------------------------------------------------
#  Description:
#    Main Terraform Module - CloudFormation Compatible
# --------------------------------------------------------------------------
#    - Workspace Environment
#    - Common Tags
#    - CloudFormation-style naming
# ==========================================================================

# --------------------------------------------------------------------------
#  Workspace Environment
# --------------------------------------------------------------------------
locals {
  env = terraform.workspace
}

# --------------------------------------------------------------------------
#  CloudFormation Compatible Variables
# --------------------------------------------------------------------------
locals {
  project_name = var.project_name != "" ? var.project_name : "${var.coreinfra}-${var.workspace_env[local.env]}"
  
  # S3 bucket names (CloudFormation style)
  data_bucket_name  = "${local.project_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-data"
  model_bucket_name = "${local.project_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-models"
  
  # Single AZ deployment (CloudFormation default)
  primary_az = "${var.aws_region}a"
}

# --------------------------------------------------------------------------
#  Data Sources
# --------------------------------------------------------------------------
data "aws_caller_identity" "current" {
  provider = aws.destination
}

data "aws_region" "current" {
  provider = aws.destination
}

# --------------------------------------------------------------------------
#  Global Tags
# --------------------------------------------------------------------------
locals {
  tags = merge(
    {
      Environment     = "${var.environment[local.env]}"
      Department      = "${var.department}"
      DepartmentGroup = "${var.environment[local.env]}-${var.department}"
      ProjectName     = local.project_name
      Terraform       = true
    },
    var.custom_tags
  )
}

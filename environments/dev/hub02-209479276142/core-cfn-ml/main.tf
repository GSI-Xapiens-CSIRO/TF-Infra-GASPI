# ==========================================================================
#  209479276142 - Core: main.tf
# --------------------------------------------------------------------------
#  Description:
#    Main Terraform Module
# --------------------------------------------------------------------------
#    - Workspace Environment
#    - Common Tags
#    - Module Core
# ==========================================================================

# --------------------------------------------------------------------------
#  Workspace Environmet
# --------------------------------------------------------------------------
locals {
  env = terraform.workspace
}

# --------------------------------------------------------------------------
#  Global Tags
# --------------------------------------------------------------------------
locals {
  tags = {
    Environment     = "${var.environment[local.env]}"
    Department      = "${var.department}"
    DepartmentGroup = "${var.environment[local.env]}-${var.department}"
    Terraform       = true
  }
}

# --------------------------------------------------------------------------
#  Reuse Module: Core
# --------------------------------------------------------------------------
module "core" {
  source = "../../../../modules//core-cfn-ml"

  aws_region                      = var.aws_region
  aws_account_id_source           = var.aws_account_id_source
  aws_account_id_destination      = var.aws_account_id_destination
  aws_account_profile_source      = var.aws_account_profile_source
  aws_account_profile_destination = var.aws_account_profile_destination
  aws_access_key                  = var.aws_access_key
  aws_secret_key                  = var.aws_secret_key
  workspace_name                  = var.workspace_name
  workspace_env                   = var.workspace_env
  environment                     = var.environment
  department                      = var.department
  kms_key                         = var.kms_key
  kms_env                         = var.kms_env

  coreinfra        = var.coreinfra
  vpc_cidr         = var.vpc_cidr
  vpc_peer         = var.vpc_peer
  peer_owner_id    = var.peer_owner_id
  propagating_vgws = var.propagating_vgws
  ec2_prefix       = var.ec2_prefix
  nat_ec2_prefix   = var.nat_ec2_prefix
  ec2_private_a    = var.ec2_private_a
  ec2_private_b    = var.ec2_private_b
  ec2_private_c    = var.ec2_private_c
  ec2_public_a     = var.ec2_public_a
  ec2_public_b     = var.ec2_public_b
  ec2_public_c     = var.ec2_public_c
  ec2_rt_prefix    = var.ec2_rt_prefix
  igw_prefix       = var.igw_prefix
  igw_rt_prefix    = var.igw_rt_prefix
  nat_prefix       = var.nat_prefix
  nat_rt_prefix    = var.nat_rt_prefix

  # ML Security Features
  enable_network_firewall = true
  enable_sagemaker_studio = false
  data_classification     = "confidential"

  # Custom Domain Lists
  allowed_domains = [
    ".amazonaws.com",
    ".aws.amazon.com",
    ".kaggle.com",
    ".typicode.com"
  ]

  blocked_domains = [
    # Wildcard Domain
    # ".com",
    ".org.id",
    ".id",

    # File sharing and storage services
    ".dropbox.com",
    ".box.com",
    ".onedrive.com",
    ".googledrive.com",
    ".icloud.com",
    ".mega.nz",
    ".mediafire.com",
    ".rapidshare.com",
    ".sendspace.com",
    ".wetransfer.com",
    ".fileserve.com",
    ".4shared.com",

    # Communication and social platforms
    ".telegram.org",
    ".whatsapp.com",
    ".slack.com",
    ".discord.com",
    ".teams.microsoft.com",

    # Code repositories (non-approved)
    ".gitlab.com",
    ".bitbucket.org",
    ".sourceforge.net",

    # Potential data exfiltration vectors
    ".pastebin.com",
    ".hastebin.com",
    ".ghostbin.co",
    ".termbin.com"
  ]

  allowed_cidr_blocks = [
    "10.16.0.0/16",
    "10.32.0.0/16",
    "10.48.0.0/16"
  ]

  # Monitoring
  alert_email_addresses         = ["support.gxc@xapiens.id"]
  enable_security_notifications = true
  firewall_log_retention_days   = 30

  # SageMaker Configuration
  sagemaker_domain_name           = "gxc-secure-ml-domain"
  sagemaker_user_profile_name     = "gxc-ml-user"
  sagemaker_default_instance_type = "ml.t3.medium"

  # Compliance
  compliance_framework         = ["sox", "gdpr"]
  enable_encryption_at_rest    = true
  enable_encryption_in_transit = true
}

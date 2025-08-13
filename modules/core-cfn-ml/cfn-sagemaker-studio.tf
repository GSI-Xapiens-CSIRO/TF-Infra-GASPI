# ==========================================================================
#  Module Core: cfn-sagemaker-studio.tf
# --------------------------------------------------------------------------
#  Description
#    CloudFormation-Compatible SageMaker Studio Configuration
# --------------------------------------------------------------------------
#    - SageMaker Studio Domain
#    - User Profile
#    - Apps (optional)
# ==========================================================================

# --------------------------------------------------------------------------
#  SageMaker Studio Domain
# --------------------------------------------------------------------------
resource "aws_sagemaker_domain" "sagemaker_studio_domain" {
  count                   = var.enable_sagemaker_studio ? 1 : 0
  provider                = aws.destination
  domain_name             = "${var.sagemaker_domain_name}-${var.aws_region}"
  auth_mode               = "IAM"
  vpc_id                  = aws_vpc.infra_vpc.id
  subnet_ids              = [aws_subnet.ml_sagemaker_studio_subnet[0].id]
  app_network_access_type = "VpcOnly"
  kms_key_id              = aws_kms_key.sagemaker_kms_key[0].arn

  default_user_settings {
    execution_role  = aws_iam_role.sagemaker_execution_role[0].arn
    security_groups = [aws_security_group.ml_sagemaker_security_group[0].id]
  }

  tags = merge(local.tags, {
    Name        = "${var.sagemaker_domain_name}-${var.aws_region}"
    ProjectName = local.project_name
  })

  depends_on = [
    aws_iam_role.sagemaker_execution_role,
    aws_security_group.ml_sagemaker_security_group,
    aws_subnet.ml_sagemaker_studio_subnet
  ]
}

# --------------------------------------------------------------------------
#  SageMaker User Profile
# --------------------------------------------------------------------------
resource "aws_sagemaker_user_profile" "sagemaker_user_profile" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  domain_id         = aws_sagemaker_domain.sagemaker_studio_domain[0].id
  user_profile_name = "${var.sagemaker_user_profile_name}-${var.aws_region}"

  user_settings {
    execution_role  = aws_iam_role.sagemaker_execution_role[0].arn
    security_groups = [aws_security_group.ml_sagemaker_security_group[0].id]
  }

  tags = merge(local.tags, {
    Name        = "${var.sagemaker_user_profile_name}-${var.aws_region}"
    ProjectName = local.project_name
  })

  depends_on = [aws_sagemaker_domain.sagemaker_studio_domain]
}

# --------------------------------------------------------------------------
#  Jupyter Server App (always created)
# --------------------------------------------------------------------------
resource "aws_sagemaker_app" "jupyter_app" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  domain_id         = aws_sagemaker_domain.sagemaker_studio_domain[0].id
  user_profile_name = aws_sagemaker_user_profile.sagemaker_user_profile[0].user_profile_name
  app_name          = "default"
  app_type          = "JupyterServer"

  tags = merge(local.tags, {
    Name        = "jupyter-app-${local.project_name}"
    ProjectName = local.project_name
  })

  depends_on = [aws_sagemaker_user_profile.sagemaker_user_profile]
}

# --------------------------------------------------------------------------
#  Data Science Kernel Gateway App (optional)
# --------------------------------------------------------------------------
resource "aws_sagemaker_app" "data_science_app" {
  count             = var.enable_sagemaker_studio && var.start_kernel_gateway_apps ? 1 : 0
  provider          = aws.destination
  domain_id         = aws_sagemaker_domain.sagemaker_studio_domain[0].id
  user_profile_name = aws_sagemaker_user_profile.sagemaker_user_profile[0].user_profile_name
  app_name          = "instance-event-engine-datascience-ml-t3-medium"
  app_type          = "KernelGateway"

  resource_spec {
    instance_type       = "ml.t3.medium"
    sagemaker_image_arn = local.sagemaker_images[var.aws_region]["datascience"]
  }

  tags = merge(local.tags, {
    Name        = "datascience-app-${local.project_name}"
    ProjectName = local.project_name
  })

  depends_on = [aws_sagemaker_user_profile.sagemaker_user_profile]
}

# --------------------------------------------------------------------------
#  Data Wrangler Kernel Gateway App (optional)
# --------------------------------------------------------------------------
resource "aws_sagemaker_app" "data_wrangler_app" {
  count             = var.enable_sagemaker_studio && var.start_kernel_gateway_apps ? 1 : 0
  provider          = aws.destination
  domain_id         = aws_sagemaker_domain.sagemaker_studio_domain[0].id
  user_profile_name = aws_sagemaker_user_profile.sagemaker_user_profile[0].user_profile_name
  app_name          = "instance-event-engine-datawrangler-ml-m5-4xlarge"
  app_type          = "KernelGateway"

  resource_spec {
    instance_type       = "ml.m5.4xlarge"
    sagemaker_image_arn = local.sagemaker_images[var.aws_region]["datawrangler"]
  }

  tags = merge(local.tags, {
    Name        = "datawrangler-app-${local.project_name}"
    ProjectName = local.project_name
  })

  depends_on = [aws_sagemaker_user_profile.sagemaker_user_profile]
}

# --------------------------------------------------------------------------
#  SageMaker Images Mapping (from CloudFormation)
# --------------------------------------------------------------------------
locals {
  sagemaker_images = {
    "us-east-1" = {
      datascience  = "arn:aws:sagemaker:us-east-1:081325390199:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:us-east-1:663277389841:image/sagemaker-data-wrangler-1.0"
    }
    "us-east-2" = {
      datascience  = "arn:aws:sagemaker:us-east-2:429704687514:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:us-east-2:415577184552:image/sagemaker-data-wrangler-1.0"
    }
    "us-west-1" = {
      datascience  = "arn:aws:sagemaker:us-west-1:742091327244:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:us-west-1:926135532090:image/sagemaker-data-wrangler-1.0"
    }
    "us-west-2" = {
      datascience  = "arn:aws:sagemaker:us-west-2:236514542706:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:us-west-2:174368400705:image/sagemaker-data-wrangler-1.0"
    }
    "ap-southeast-1" = {
      datascience  = "arn:aws:sagemaker:ap-southeast-1:492261229750:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:ap-southeast-1:119527597002:image/sagemaker-data-wrangler-1.0"
    }
    "ap-southeast-2" = {
      datascience  = "arn:aws:sagemaker:ap-southeast-2:452832661640:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:ap-southeast-2:422173101802:image/sagemaker-data-wrangler-1.0"
    }
    "ap-northeast-1" = {
      datascience  = "arn:aws:sagemaker:ap-northeast-1:102112518831:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:ap-northeast-1:649008135260:image/sagemaker-data-wrangler-1.0"
    }
    "eu-central-1" = {
      datascience  = "arn:aws:sagemaker:eu-central-1:936697816551:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:eu-central-1:024640144536:image/sagemaker-data-wrangler-1.0"
    }
    "eu-west-1" = {
      datascience  = "arn:aws:sagemaker:eu-west-1:470317259841:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:eu-west-1:245179582081:image/sagemaker-data-wrangler-1.0"
    }
    "eu-west-2" = {
      datascience  = "arn:aws:sagemaker:eu-west-2:712779665605:image/datascience-1.0"
      datawrangler = "arn:aws:sagemaker:eu-west-2:894491911112:image/sagemaker-data-wrangler-1.0"
    }
  }
}
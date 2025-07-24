# ==========================================================================
#  Module Core: ml-security-groups.tf
# --------------------------------------------------------------------------
#  Description
#    Security Groups for ML Workloads
# --------------------------------------------------------------------------
#    - SageMaker Studio Security Group
#    - VPC Endpoints Security Group
#    - Network Firewall Security Group
#    - Restrictive Rules for Data Protection
# ==========================================================================

# --------------------------------------------------------------------------
#  SageMaker Studio Security Group
# --------------------------------------------------------------------------
resource "aws_security_group" "sagemaker_studio" {
  count       = var.enable_sagemaker_studio ? 1 : 0
  provider    = aws.destination
  name        = "${var.coreinfra}-${var.workspace_env[local.env]}-sagemaker-studio-sg"
  description = "Security Group for SageMaker Studio - Restrictive ML workload access"
  vpc_id      = aws_vpc.infra_vpc.id

  # Ingress rules - very restrictive
  ingress {
    description = "HTTPS from VPC only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr[local.env]]
  }

  ingress {
    description = "NFS for EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [
      var.sagemaker_private_a[local.env],
      var.sagemaker_private_b[local.env],
      var.sagemaker_private_c[local.env]
    ]
  }

  # Allow communication within SageMaker subnets only
  ingress {
    description = "Internal SageMaker communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Egress rules - controlled outbound access
  egress {
    description = "HTTPS to internet (via Network Firewall)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP to internet (via Network Firewall)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS resolution
  egress {
    description = "DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NTP for time sync
  egress {
    description = "NTP"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # AWS services access within VPC
  egress {
    description = "AWS services within VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr[local.env]]
  }

  # NFS for EFS
  egress {
    description = "NFS for EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr[local.env]]
  }

  # Internal communication within security group
  egress {
    description = "Internal SageMaker communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  tags = merge(local.tags, {
    Name           = "${var.coreinfra}-${var.workspace_env[local.env]}-sagemaker-studio-sg"
    Purpose        = "SageMakerStudioSecurity"
    SecurityLevel  = "High"
    DataProtection = "Enabled"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------------------------
#  VPC Endpoints Security Group
# --------------------------------------------------------------------------
resource "aws_security_group" "vpc_endpoints" {
  count       = var.enable_sagemaker_studio ? 1 : 0
  provider    = aws.destination
  name        = "${var.coreinfra}-${var.workspace_env[local.env]}-vpc-endpoints-sg"
  description = "Security Group for VPC Endpoints - AWS services access"
  vpc_id      = aws_vpc.infra_vpc.id

  # Allow HTTPS from SageMaker subnets
  ingress {
    description = "HTTPS from SageMaker subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      var.sagemaker_private_a[local.env],
      var.sagemaker_private_b[local.env],
      var.sagemaker_private_c[local.env]
    ]
  }

  # Allow HTTPS from EC2 subnets (if needed)
  ingress {
    description = "HTTPS from EC2 subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      var.ec2_private_a[local.env],
      var.ec2_private_b[local.env],
      var.ec2_private_c[local.env]
    ]
  }

  # Outbound - restricted to essential services only
  egress {
    description = "HTTPS to AWS services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name          = "${var.coreinfra}-${var.workspace_env[local.env]}-vpc-endpoints-sg"
    Purpose       = "VPCEndpointsSecurity"
    SecurityLevel = "Medium"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------------------------
#  Network Firewall Management Security Group
# --------------------------------------------------------------------------
resource "aws_security_group" "network_firewall_mgmt" {
  count       = var.enable_network_firewall ? 1 : 0
  provider    = aws.destination
  name        = "${var.coreinfra}-${var.workspace_env[local.env]}-firewall-mgmt-sg"
  description = "Security Group for Network Firewall Management"
  vpc_id      = aws_vpc.infra_vpc.id

  # No direct access to firewall - managed by AWS
  # This is just for compliance and management purposes

  egress {
    description = "AWS service communication"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name          = "${var.coreinfra}-${var.workspace_env[local.env]}-firewall-mgmt-sg"
    Purpose       = "NetworkFirewallManagement"
    SecurityLevel = "Critical"
  })
}

# --------------------------------------------------------------------------
#  Enhanced Default VPC Security Group (Override)
# --------------------------------------------------------------------------
resource "aws_security_group" "ml_default" {
  provider    = aws.destination
  name        = "${var.coreinfra}-${var.workspace_env[local.env]}-ml-default-sg"
  description = "Default Security Group for ML Environment - Highly Restrictive"
  vpc_id      = aws_vpc.infra_vpc.id

  # Very restrictive default rules
  # Only allow essential internal communication
  ingress {
    description = "SSH from bastion/admin subnets only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      var.ec2_public_a[local.env],
      var.ec2_public_b[local.env],
      var.ec2_public_c[local.env]
    ]
  }

  # Block all SSH from SageMaker subnets (data exfiltration prevention)
  ingress {
    description = "Block SSH from SageMaker subnets"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      var.sagemaker_private_a[local.env],
      var.sagemaker_private_b[local.env],
      var.sagemaker_private_c[local.env]
    ]
    self = false
  }

  # Essential outbound only
  egress {
    description = "HTTPS only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "NTP"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name           = "${var.coreinfra}-${var.workspace_env[local.env]}-ml-default-sg"
    Purpose        = "MLDefaultSecurity"
    SecurityLevel  = "Critical"
    DataProtection = "Maximum"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------------------------
#  Data Loss Prevention Security Group Rules
# --------------------------------------------------------------------------
resource "aws_security_group_rule" "block_ftp_from_sagemaker" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  type              = "egress"
  from_port         = 20
  to_port           = 21
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sagemaker_studio[0].id
  description       = "Block FTP - Data exfiltration prevention"
}

resource "aws_security_group_rule" "block_sftp_from_sagemaker" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sagemaker_studio[0].id
  description       = "Block SSH/SFTP - Data exfiltration prevention"
}

resource "aws_security_group_rule" "block_smtp_from_sagemaker" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  type              = "egress"
  from_port         = 25
  to_port           = 25
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sagemaker_studio[0].id
  description       = "Block SMTP - Email data exfiltration prevention"
}

resource "aws_security_group_rule" "block_smtps_from_sagemaker" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  type              = "egress"
  from_port         = 465
  to_port           = 465
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sagemaker_studio[0].id
  description       = "Block SMTPS - Secure email data exfiltration prevention"
}

resource "aws_security_group_rule" "block_submission_from_sagemaker" {
  count             = var.enable_sagemaker_studio ? 1 : 0
  provider          = aws.destination
  type              = "egress"
  from_port         = 587
  to_port           = 587
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sagemaker_studio[0].id
  description       = "Block email submission - Data exfiltration prevention"
}
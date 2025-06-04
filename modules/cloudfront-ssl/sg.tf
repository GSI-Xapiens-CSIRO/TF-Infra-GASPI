# ==========================================================================
#  Module CloudFront SSL: sg.tf
# --------------------------------------------------------------------------
#  Description
#    Security Group - Fixed Protocol Issue
# ==========================================================================

# --------------------------------------------------------------------------
#  ALB Security Group
# --------------------------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  count    = var.create_alb ? 1 : 0
  provider = aws.destination

  name        = "${var.domain_name}-alb-sg"
  description = "Security group for ALB for ${var.domain_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name     = "${var.domain_name}-alb-sg"
      Services = "SecurityGroup"
    }
  )
}

# --------------------------------------------------------------------------
#  Application Security Group
# --------------------------------------------------------------------------
resource "aws_security_group" "app_sg" {
  provider = aws.destination

  name        = "${var.domain_name}-app-sg"
  description = "Security group for application instances for ${var.domain_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.alb_target_group_port
    to_port         = var.alb_target_group_port
    protocol        = "tcp"
    security_groups = var.create_alb ? [aws_security_group.alb_sg[0].id] : []
    description     = "Allow traffic from ALB"
  }

  # If using existing ALB, allow from VPC CIDR
  dynamic "ingress" {
    for_each = var.create_alb ? [] : [1]
    content {
      from_port   = var.alb_target_group_port
      to_port     = var.alb_target_group_port
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      description = "Allow traffic from existing ALB"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name     = "${var.domain_name}-app-sg"
      Services = "SecurityGroup"
    }
  )
}
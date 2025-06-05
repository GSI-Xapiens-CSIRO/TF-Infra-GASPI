# ==========================================================================
#  Module CloudFront SSL: sg.tf
# --------------------------------------------------------------------------
#  Description
#    Security Group Default
# --------------------------------------------------------------------------
#    - ALB Security Group
#    - Application Security Group
# ==========================================================================

# --------------------------------------------------------------------------
#  ALB Security Group
# --------------------------------------------------------------------------
resource "aws_security_group" "alb_sg" {
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
    protocol        = lower(var.alb_target_group_protocol)
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow traffic from ALB"
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
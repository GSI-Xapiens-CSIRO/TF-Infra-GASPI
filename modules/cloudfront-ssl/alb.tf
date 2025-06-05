# ==========================================================================
#  Module CloudFront SSL: alb.tf
# --------------------------------------------------------------------------
#  Description
#    Application Load Balancer (ALB)
# --------------------------------------------------------------------------
#    - ALB Resources
#    - ALB Group Tags
#    - ALB Listener HTTP Redirect
#    - ALB Listener HTTPS
# ==========================================================================

# --------------------------------------------------------------------------
#  Application Load Balancer (ALB)
# --------------------------------------------------------------------------
resource "aws_lb" "main" {
  provider = aws.destination

  name               = substr("alb-${replace(var.domain_name, ".", "-")}", 0, 32)
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(
    local.tags,
    {
      Name     = "${var.domain_name}-alb"
      Services = "ALB"
    }
  )
}

resource "aws_lb_target_group" "main" {
  provider = aws.destination

  name        = substr("tg-${replace(var.domain_name, ".", "-")}", 0, 32)
  port        = var.alb_target_group_port
  protocol    = var.alb_target_group_protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.alb_target_group_protocol
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    local.tags,
    {
      Name     = "${var.domain_name}-tg"
      Services = "ALB"
    }
  )
}

resource "aws_lb_listener" "http_redirect" {
  provider = aws.destination

  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  provider = aws.destination

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
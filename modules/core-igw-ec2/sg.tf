# ==========================================================================
#  Module Core: sg.tf
# --------------------------------------------------------------------------
#  Description
#    Security Group Default
# --------------------------------------------------------------------------
#    - Security Group Tags
#    - Security Group Allow Ingress
#    - Security Group Allow Egress
# ==========================================================================

# --------------------------------------------------------------------------
#  Security Group Tags
# --------------------------------------------------------------------------
locals {
  sg_tags = {
    Name          = "gxc-sg-ssh-${var.workspace_env[local.env]}"
    ResourceGroup = "${var.environment[local.env]}-SG-VPC"
  }
}

resource "aws_security_group" "default" {
  provider    = aws.destination
  name        = "gxc-sg-ssh-${var.workspace_env[local.env]}"
  description = "SSH Private Subnet"
  vpc_id      = aws_vpc.infra_vpc.id

  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      var.ec2_public_a[local.env],
      var.ec2_public_b[local.env],
      var.ec2_public_c[local.env],
    ]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Node all egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, local.sg_tags)

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# opensearch-sg.tf

# Security Groups
resource "aws_security_group" "opensearch" {
  name        = "genomic-cloudtrail-opensearch-${var.aws_account_id_destination}"
  description = "Security group for OpenSearch domain"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "lambda" {
  name        = "genomic-cloudtrail-lambda-${var.aws_account_id_destination}"
  description = "Security group for Lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "genomic-cloudtrail-lambda-${var.aws_account_id_destination}"
    }
  )
}

resource "aws_security_group" "firehose" {
  name        = "genomic-cloudtrail-firehose-${var.aws_account_id_destination}"
  description = "Security group for Kinesis Firehose"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "genomic-cloudtrail-firehose-${var.aws_account_id_destination}"
    }
  )
}

# Add ingress rules directly to the OpenSearch security group
# resource "aws_vpc_security_group_ingress_rule" "opensearch_lambda" {
#   security_group_id            = aws_security_group.opensearch.id
#   referenced_security_group_id = aws_security_group.lambda.id
#   from_port                    = 443
#   to_port                      = 443
#   ip_protocol                  = "tcp"
#   description                  = "Allow HTTPS from Lambda"
# }

# resource "aws_vpc_security_group_ingress_rule" "opensearch_firehose" {
#   security_group_id            = aws_security_group.opensearch.id
#   referenced_security_group_id = aws_security_group.firehose.id
#   from_port                    = 443
#   to_port                      = 443
#   ip_protocol                  = "tcp"
#   description                  = "Allow HTTPS from Firehose"
# }
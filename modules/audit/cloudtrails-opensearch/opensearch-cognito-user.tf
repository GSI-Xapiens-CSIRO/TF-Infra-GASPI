# Add Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "opensearch" {
  domain       = "opensearch-${var.aws_account_id_destination}"
  user_pool_id = aws_cognito_user_pool.opensearch.id
}

# Update Cognito Identity Pool with roles
resource "aws_cognito_identity_pool_roles_attachment" "opensearch" {
  identity_pool_id = aws_cognito_identity_pool.opensearch.id

  roles = {
    "authenticated"   = aws_iam_role.cognito_authenticated.arn
    "unauthenticated" = aws_iam_role.cognito_unauthenticated.arn
  }
}

# IAM role for authenticated Cognito users
resource "aws_iam_role" "cognito_authenticated" {
  name        = "opensearch-cognito-authenticated"
  description = "IAM role for authenticated Cognito users"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.opensearch.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM role for unauthenticated Cognito users
resource "aws_iam_role" "cognito_unauthenticated" {
  name        = "opensearch-cognito-unauthenticated"
  description = "IAM role for unauthenticated Cognito users"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.opensearch.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM Role for Cognito-OpenSearch Authentication
resource "aws_iam_role" "cognito_opensearch" {
  name = "cognito-opensearch-role-${var.aws_account_id_destination}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

# IAM Policy for Cognito-OpenSearch Role
resource "aws_iam_role_policy" "cognito_opensearch" {
  name = "cognito-opensearch-policy"
  role = aws_iam_role.cognito_opensearch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPool",
          "cognito-idp:CreateUserPoolClient",
          "cognito-idp:DeleteUserPoolClient",
          "cognito-idp:DescribeUserPoolClient",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminUserGlobalSignOut",
          "cognito-idp:ListUserPoolClients",
          "cognito-identity:DescribeIdentityPool",
          "cognito-identity:UpdateIdentityPool",
          "cognito-identity:SetIdentityPoolRoles",
          "cognito-identity:GetIdentityPoolRoles"
        ]
        Resource = [
          aws_cognito_user_pool.opensearch.arn,
          aws_cognito_identity_pool.opensearch.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.cognito_authenticated.arn,
          aws_iam_role.cognito_unauthenticated.arn
        ]
      }
    ]
  })
}

# IAM Policy for authenticated users
resource "aws_iam_role_policy" "authenticated" {
  name = "opensearch-cognito-authenticated-policy"
  role = aws_iam_role.cognito_authenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttp*",
          "es:DescribeElasticsearch*",
          "opensearch:Describe*",
          "opensearch:ESHttp*"
        ]
        Resource = "${aws_opensearch_domain.cloudtrail.arn}/*"
      }
    ]
  })
}

# IAM Policy for unauthenticated users (denying access)
resource "aws_iam_role_policy" "unauthenticated" {
  name = "opensearch-cognito-unauthenticated-policy"
  role = aws_iam_role.cognito_unauthenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "es:*",
          "opensearch:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "cognito_user_setup" {
  filename         = data.archive_file.cognito_setup.output_path
  source_code_hash = data.archive_file.cognito_setup.output_base64sha256
  function_name    = "cognito-user-setup-${var.aws_account_id_destination}"
  description      = "Lambda function to setup Cognito users"
  role             = aws_iam_role.cognito_setup_lambda.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  timeout          = 300
  memory_size      = 128

  environment {
    variables = {
      OPENSEARCH_DOMAIN_ENDPOINT = aws_opensearch_domain.cloudtrail.endpoint
      COGNITO_ROLE_ARN           = aws_iam_role.cognito_authenticated.arn
      MASTER_USER                = var.opensearch_master_user
      MASTER_PASSWORD            = var.opensearch_master_password
      USER_POOL_ID               = aws_cognito_user_pool.opensearch.id
      USERS                      = jsonencode(var.cognito_users)
    }
  }

  depends_on = [
    aws_opensearch_domain.cloudtrail
  ]

  tags = merge(
    local.common_tags,
    {
      Name      = "OpenSearch Cognito Setup"
      Function  = "OpenSearch Setup for Cognito Users"
      UpdatedAt = timestamp()
    }
  )
}

data "archive_file" "cognito_setup" {
  type        = "zip"
  output_path = "${path.module}/cognito_setup.zip"
  source {
    content  = <<EOF
import os
import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def create_user(client, user_pool_id, user_data):
    try:
        # Create user
        response = client.admin_create_user(
            UserPoolId=user_pool_id,
            Username=user_data['username'],
            TemporaryPassword=user_data['password'],
            UserAttributes=[
                {'Name': key, 'Value': value}
                for key, value in user_data['attributes'].items()
            ],
            MessageAction='SUPPRESS'
        )

        # Set permanent password
        client.admin_set_user_password(
            UserPoolId=user_pool_id,
            Username=user_data['username'],
            Password=user_data['password'],
            Permanent=True
        )

        # Add user to groups
        for group_name in user_data['groups']:
            try:
                # Create group if it doesn't exist
                try:
                    client.get_group(
                        GroupName=group_name,
                        UserPoolId=user_pool_id
                    )
                except client.exceptions.ResourceNotFoundException:
                    client.create_group(
                        GroupName=group_name,
                        UserPoolId=user_pool_id
                    )

                # Add user to group
                client.admin_add_user_to_group(
                    UserPoolId=user_pool_id,
                    Username=user_data['username'],
                    GroupName=group_name
                )
            except Exception as e:
                logger.error(f"Error adding user to group {group_name}: {str(e)}")

        return True
    except Exception as e:
        logger.error(f"Error creating user {user_data['username']}: {str(e)}")
        return False

def handler(event, context):
    client = boto3.client('cognito-idp')
    user_pool_id = os.environ['USER_POOL_ID']
    users = json.loads(os.environ['USERS'])

    results = []
    for user_data in users:
        success = create_user(client, user_pool_id, user_data)
        results.append({
            'username': user_data['username'],
            'success': success
        })

    return {
        'statusCode': 200,
        'body': json.dumps(results)
    }
EOF
    filename = "index.py"
  }
}


resource "aws_iam_role" "cognito_setup_lambda" {
  name        = "cognito-setup-lambda-${var.aws_account_id_destination}"
  description = "IAM role for Lambda function to setup Cognito users"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "cognito_setup_lambda" {
  name = "cognito-setup-lambda-policy"
  role = aws_iam_role.cognito_setup_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttp*",
          "es:DescribeElasticsearchDomain",
          "es:DescribeElasticsearchDomains",
          "es:DescribeElasticsearchDomainConfig"
        ]
        Resource = [
          aws_opensearch_domain.cloudtrail.arn,
          "${aws_opensearch_domain.cloudtrail.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminSetUserPassword",
          "cognito-idp:AdminAddUserToGroup",
          "cognito-idp:CreateGroup",
          "cognito-idp:GetGroup"
        ]
        Resource = aws_cognito_user_pool.opensearch.arn
      }
    ]
  })
}

resource "null_resource" "cognito_setup_trigger" {
  triggers = {
    user_pool_id = aws_cognito_user_pool.opensearch.id
  }

  provisioner "local-exec" {
    command = "aws lambda invoke --function-name ${aws_lambda_function.cognito_user_setup.function_name} --region ${var.aws_region} cognito_response.json"
  }

  depends_on = [
    aws_lambda_function.cognito_user_setup,
    aws_cognito_user_pool.opensearch
  ]
}

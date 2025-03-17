# random_password.tf
resource "random_password" "opensearch_master" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}:?"
}

# ssm.tf
resource "aws_ssm_parameter" "opensearch_master_password" {
  name        = "/genomic/cloudtrail/opensearch/master-password"
  description = "Master password for OpenSearch domain"
  type        = "SecureString"
  value       = coalesce(var.opensearch_master_password, random_password.opensearch_master.result)

  tags = local.common_tags
}

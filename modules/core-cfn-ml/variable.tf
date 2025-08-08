# ==========================================================================
#  Module Core: variable.tf
# --------------------------------------------------------------------------
#  Description:
#    Global Variable - Enhanced for ML Security
# --------------------------------------------------------------------------
#    - Original AWS and Workspace Variables
#    - Enhanced KMS and Security Variables
#    - ML Security Feature Flags
#    - Network Firewall Configuration
#    - SageMaker Studio Configuration
#    - Data Protection Settings
# ==========================================================================

# --------------------------------------------------------------------------
#  KMS Key & Environment
# --------------------------------------------------------------------------
variable "kms_key" {
  description = "KMS Key References for encryption"
  type        = map(string)
  validation {
    condition = alltrue([
      for k, v in var.kms_key : can(regex("^arn:aws:kms:", v))
    ])
    error_message = "All KMS key values must be valid KMS key ARNs."
  }
}

variable "kms_env" {
  description = "KMS Key Environment mapping"
  type        = map(string)
  default = {
    lab     = "RnD"
    staging = "Staging"
    nonprod = "NonProduction"
    prod    = "Production"
  }
}

# --------------------------------------------------------------------------
#  Project Configuration (CloudFormation Compatible)
# --------------------------------------------------------------------------
variable "project_name" {
  description = "Project name for CloudFormation compatibility"
  type        = string
  default     = ""
}

# CloudFormation-style subnet CIDRs
variable "firewall_subnet_cidr" {
  description = "Network Firewall subnet CIDR"
  type        = map(string)
  default = {
    default = "10.16.1.0/24"
    lab     = "10.16.1.0/24"
    staging = "10.32.1.0/24"
    nonprod = "10.32.1.0/24"
    prod    = "10.48.1.0/24"
  }
}

variable "nat_gateway_subnet_cidr" {
  description = "NAT Gateway subnet CIDR"
  type        = map(string)
  default = {
    default = "10.16.2.0/24"
    lab     = "10.16.2.0/24"
    staging = "10.32.2.0/24"
    nonprod = "10.32.2.0/24"
    prod    = "10.48.2.0/24"
  }
}

variable "sagemaker_subnet_cidr" {
  description = "SageMaker Studio subnet CIDR"
  type        = map(string)
  default = {
    default = "10.16.3.0/24"
    lab     = "10.16.3.0/24"
    staging = "10.32.3.0/24"
    nonprod = "10.32.3.0/24"
    prod    = "10.48.3.0/24"
  }
}

# --------------------------------------------------------------------------
#  AWS Configuration
# --------------------------------------------------------------------------
variable "aws_region" {
  description = "The AWS region to deploy the VPC and resources in"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be in format like 'us-east-1' or 'ap-southeast-3'."
  }
}

variable "aws_account_id_source" {
  description = "The AWS Account ID for management/source account"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id_source))
    error_message = "AWS Account ID must be exactly 12 digits."
  }
}

variable "aws_account_id_destination" {
  description = "The AWS Account ID to deploy the infrastructure in"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id_destination))
    error_message = "AWS Account ID must be exactly 12 digits."
  }
}

variable "aws_account_profile_source" {
  description = "The AWS CLI profile for management/source account"
  type        = string
}

variable "aws_account_profile_destination" {
  description = "The AWS CLI profile to deploy the infrastructure with"
  type        = string
}

variable "aws_access_key" {
  description = "The AWS Access Key (use with caution, prefer IAM roles)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS Secret Key (use with caution, prefer IAM roles)"
  type        = string
  default     = ""
  sensitive   = true
}

# --------------------------------------------------------------------------
#  Workspace Configuration
# --------------------------------------------------------------------------
variable "workspace_name" {
  description = "Workspace Environment Name"
  type        = string
  default     = "default"
}

variable "workspace_env" {
  description = "Workspace Environment Selection mapping"
  type        = map(string)
  default = {
    default = "default"
    lab     = "rnd"
    staging = "staging"
    nonprod = "nonprod"
    prod    = "prod"
  }
}

# --------------------------------------------------------------------------
#  Environment and Tagging
# --------------------------------------------------------------------------
variable "environment" {
  description = "Target Environment mapping for resource tags"
  type        = map(string)
  default = {
    default = "DEF"
    lab     = "RND"
    staging = "STG"
    nonprod = "NONPROD"
    prod    = "PROD"
  }
}

# --------------------------------------------------------------------------
#  Department Tags
# --------------------------------------------------------------------------
variable "department" {
  description = "Department Owner for resource tagging"
  type        = string
  default     = "DEVOPS"
  validation {
    condition     = can(regex("^[A-Z0-9_-]+$", var.department))
    error_message = "Department must contain only uppercase letters, numbers, hyphens, and underscores."
  }
}

# --------------------------------------------------------------------------
#  ML Security Feature Flags
# --------------------------------------------------------------------------
variable "enable_network_firewall" {
  description = "Enable AWS Network Firewall for ML security and data loss prevention"
  type        = bool
  default     = false
}

variable "enable_sagemaker_studio" {
  description = "Enable Amazon SageMaker Studio deployment with VPC-only access"
  type        = bool
  default     = false
}

variable "enable_ml_monitoring" {
  description = "Enable enhanced monitoring and logging for ML workloads"
  type        = bool
  default     = true
}

variable "enable_data_loss_prevention" {
  description = "Enable advanced data loss prevention rules and monitoring"
  type        = bool
  default     = true
}

# --------------------------------------------------------------------------
#  Network Firewall Configuration
# --------------------------------------------------------------------------
variable "firewall_deletion_protection" {
  description = "Enable deletion protection for Network Firewall"
  type        = bool
  default     = true
}

variable "allowed_domains" {
  description = "List of allowed domains for ML workloads (domain allowlist)"
  type        = list(string)
  default = [
    ".amazonaws.com",         # AWS services
    ".anaconda.com",          # Anaconda packages
    ".anaconda.org",          # Anaconda community
    ".pypi.org",              # Python Package Index
    ".pythonhosted.org",      # Python packages hosting
    ".conda.io",              # Conda packages
    ".continuum.io",          # Continuum Analytics
    ".github.com",            # GitHub repositories
    ".githubusercontent.com", # GitHub raw content
    ".huggingface.co",        # Hugging Face models
    ".kaggle.com",            # Kaggle datasets
    ".pytorch.org",           # PyTorch framework
    ".tensorflow.org",        # TensorFlow framework
    ".jupyter.org",           # Jupyter documentation
    ".scipy.org",             # SciPy ecosystem
    ".numpy.org"              # NumPy library
  ]

  validation {
    condition = alltrue([
      for domain in var.allowed_domains : can(regex("^\\.", domain))
    ])
    error_message = "All domains in allowed_domains must start with a dot (.) for wildcard matching."
  }
}

variable "blocked_domains" {
  description = "List of explicitly blocked domains for data exfiltration prevention"
  type        = list(string)
  default = [
    # File sharing and storage services
    ".dropbox.com",
    ".box.com",
    ".onedrive.com",
    ".googledrive.com",
    ".icloud.com",
    ".mega.nz",
    ".mediafire.com",
    ".rapidshare.com",
    ".sendspace.com",
    ".wetransfer.com",
    ".fileserve.com",
    ".4shared.com",

    # Communication and social platforms
    ".telegram.org",
    ".whatsapp.com",
    ".slack.com",
    ".discord.com",
    ".teams.microsoft.com",

    # Code repositories (non-approved)
    ".gitlab.com",
    ".bitbucket.org",
    ".sourceforge.net",

    # Potential data exfiltration vectors
    ".pastebin.com",
    ".hastebin.com",
    ".ghostbin.co",
    ".termbin.com"
  ]

  validation {
    condition = alltrue([
      for domain in var.blocked_domains : can(regex("^\\.", domain))
    ])
    error_message = "All domains in blocked_domains must start with a dot (.) for wildcard matching."
  }
}

variable "custom_firewall_rules" {
  description = "Custom firewall rules for specific organizational requirements"
  type = list(object({
    name        = string
    priority    = number
    action      = string
    protocol    = string
    source_port = string
    dest_port   = string
    content     = optional(string)
    description = string
  }))
  default = []
}

# --------------------------------------------------------------------------
#  SageMaker Studio Configuration
# --------------------------------------------------------------------------
variable "sagemaker_domain_name" {
  description = "Name for the SageMaker Studio Domain"
  type        = string
  default     = "secure-ml-domain"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,63}$", var.sagemaker_domain_name))
    error_message = "SageMaker domain name must be 1-63 characters, alphanumeric and hyphens only."
  }
}

variable "sagemaker_user_profile_name" {
  description = "Default user profile name for SageMaker Studio"
  type        = string
  default     = "ml-user"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,63}$", var.sagemaker_user_profile_name))
    error_message = "SageMaker user profile name must be 1-63 characters, alphanumeric and hyphens only."
  }
}

variable "sagemaker_execution_role_name" {
  description = "Name for the SageMaker execution role"
  type        = string
  default     = "SageMakerExecutionRole"
}

variable "sagemaker_default_instance_type" {
  description = "Default instance type for SageMaker Studio notebooks"
  type        = string
  default     = "ml.t3.medium"

  validation {
    condition = contains([
      "ml.t3.micro", "ml.t3.small", "ml.t3.medium", "ml.t3.large",
      "ml.m5.large", "ml.m5.xlarge", "ml.m5.2xlarge", "ml.m5.4xlarge",
      "ml.c5.large", "ml.c5.xlarge", "ml.c5.2xlarge", "ml.c5.4xlarge"
    ], var.sagemaker_default_instance_type)
    error_message = "Must be a valid SageMaker instance type."
  }
}

variable "start_kernel_gateway_apps" {
  description = "Start the KernelGateway Apps (Data Science and Data Wrangler)"
  type        = bool
  default     = false
}

# --------------------------------------------------------------------------
#  Logging and Monitoring Configuration
# --------------------------------------------------------------------------
variable "firewall_log_retention_days" {
  description = "CloudWatch log retention period for firewall logs"
  type        = number
  default     = 30

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.firewall_log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = true
}

variable "vpc_flow_logs_retention_days" {
  description = "CloudWatch log retention period for VPC Flow Logs"
  type        = number
  default     = 14
}

# --------------------------------------------------------------------------
#  Cost Optimization Settings
# --------------------------------------------------------------------------
variable "single_az_deployment" {
  description = "Deploy in single AZ to reduce costs (not recommended for production)"
  type        = bool
  default     = false
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to deploy (1-3, affects availability and cost)"
  type        = number
  default     = 3

  validation {
    condition     = var.nat_gateway_count >= 1 && var.nat_gateway_count <= 3
    error_message = "NAT Gateway count must be between 1 and 3."
  }
}

# --------------------------------------------------------------------------
#  Security and Compliance Settings
# --------------------------------------------------------------------------
variable "data_classification" {
  description = "Data classification level for tagging and compliance"
  type        = string
  default     = "confidential"

  validation {
    condition = contains([
      "public", "internal", "confidential", "restricted"
    ], var.data_classification)
    error_message = "Data classification must be: public, internal, confidential, or restricted."
  }
}

variable "compliance_framework" {
  description = "Compliance framework requirements (affects security settings)"
  type        = list(string)
  default     = ["general"]

  validation {
    condition = alltrue([
      for framework in var.compliance_framework :
      contains(["general", "sox", "hipaa", "pci", "gdpr", "fedramp"], framework)
    ])
    error_message = "Compliance framework must be one or more of: general, sox, hipaa, pci, gdpr, fedramp."
  }
}

variable "enable_encryption_at_rest" {
  description = "Enable encryption at rest for all supported resources"
  type        = bool
  default     = true
}

variable "enable_encryption_in_transit" {
  description = "Enforce encryption in transit for all communications"
  type        = bool
  default     = true
}

# --------------------------------------------------------------------------
#  Advanced Configuration
# --------------------------------------------------------------------------
variable "custom_tags" {
  description = "Additional custom tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "resource_naming_prefix" {
  description = "Additional prefix for resource naming (useful for multi-tenant deployments)"
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]*$", var.resource_naming_prefix))
    error_message = "Resource naming prefix must contain only alphanumeric characters and hyphens."
  }
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup for critical resources"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Retention period for automated backups"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 1 and 35."
  }
}

# --------------------------------------------------------------------------
#  Notification and Alerting
# --------------------------------------------------------------------------
variable "alert_email_addresses" {
  description = "List of email addresses for security alerts"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.alert_email_addresses :
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All email addresses must be valid email format."
  }
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for security notifications (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_security_notifications" {
  description = "Enable security event notifications via SNS"
  type        = bool
  default     = true
}

# --------------------------------------------------------------------------
#  Development and Testing
# --------------------------------------------------------------------------
variable "enable_debug_logging" {
  description = "Enable debug logging for troubleshooting (disable in production)"
  type        = bool
  default     = false
}

variable "allow_ssh_from_anywhere" {
  description = "Allow SSH access from anywhere (DANGEROUS - only for testing)"
  type        = bool
  default     = false
}



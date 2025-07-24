# Atlantis Dynamic Deployment System for BGSI

A comprehensive, dynamic deployment system for managing multiple AWS environments using Atlantis, Terraform, and OpenTelemetry-based infrastructure.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🏗️ Overview

This system provides a unified approach to managing Terraform deployments across multiple AWS environments using Atlantis. It supports:

- **8 Environments**: hub01-04, uat01-04
- **Dynamic Configuration**: Single script handles all environments
- **GitHub Integration**: Secure submodule authentication
- **Multi-Account AWS**: Separate AWS profiles per environment
- **Observability Focus**: Built for Xignals (OpenTelemetry-based) infrastructure

## 🎯 Architecture

```
┌─────────────────┐    ┌───────────────────┐    ┌─────────────────┐
│   GitHub PR     │    │    Atlantis       │    │  AWS Accounts   │
│                 │    │                   │    │                 │
│ ┌─────────────┐ │    │ ┌───────────────┐ │    │ ┌─────────────┐ │
│ │ hub01 branch│ │───▶│ │atlantis-deploy│ │───▶│ │ HUB01 Acct  │ │
│ └─────────────┘ │    │ └───────────────┘ │    │ └─────────────┘ │
│ ┌─────────────┐ │    │ ┌───────────────┐ │    │ ┌─────────────┐ │
│ │ uat02 branch│ │───▶│ │atlantis-deploy│ │───▶│ │ UAT02 Acct  │ │
│ └─────────────┘ │    │ └───────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └───────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### Required Software
- **Atlantis Server** v0.19.0+
- **Terraform** v1.5.0+
- **AWS CLI** v2.0+
- **Git** v2.30+
- **jq** v1.6+

### Required Accounts & Access
- **GitHub Account**: DevOps XTI bot account
- **AWS Accounts**: 8 separate AWS accounts (hub01-04, uat01-04)
- **Permissions**: Terraform deployment permissions in each AWS account

### Environment Variables
```bash
# GitHub Authentication
GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
GITHUB_USERNAME="DevOps-XTI"
GIT_USER_NAME="DevOps XTI"
GIT_USER_EMAIL="support.gxc@xapiens.id"

# Atlantis Configuration
ATLANTIS_GH_TOKEN="$GITHUB_TOKEN"
ATLANTIS_GH_USER="DevOps-XTI"
ATLANTIS_CONFIG_PATH="/atlantis/config"
```

## 🚀 Installation

### Step 1: Clone Repository

```bash
git clone https://github.com/GSI-Xapiens-CSIRO/BGSI-GeneticAnalysisSupportPlatformIndonesia-GASPI.git
cd BGSI-GeneticAnalysisSupportPlatformIndonesia-GASPI
```

### Step 2: Install System-Wide Script

```bash
# Make installation script executable
chmod +x install-atlantis-deploy

# Install as root/sudo
sudo ./install-atlantis-deploy
```

**Expected Output:**
```
🚀 Installing atlantis-deploy system-wide...
📋 Copying script to /usr/local/bin/atlantis-deploy...
🔧 Making script executable...
✅ atlantis-deploy installed successfully!
📍 Location: /usr/local/bin/atlantis-deploy
📖 Usage: atlantis-deploy <environment> [plan|apply]
💡 Example: atlantis-deploy hub01 plan
🔍 Testing installation...
atlantis-deploy v1.0.0
```

### Step 3: Verify Installation

```bash
# Check version
atlantis-deploy --version

# Show help
atlantis-deploy --help

# Test with environment
atlantis-deploy hub01 --help
```

## ⚙️ Configuration

### Directory Structure

```
repository/
├── scripts/
│   ├── atlantis-deploy              # Source script
│   └── install-atlantis-deploy      # Installation script
├── atlantis.yaml                       # Project configuration
├── repo.yaml                           # Repository workflows
├── README.md                           # This documentation
└── /atlantis/config/                   # Configuration files
    ├── hub01/
    │   ├── backend.tf
    │   ├── backend.tfvars
    │   └── hub01.tfvars
    ├── hub02/
    │   ├── backend.tf
    │   ├── backend.tfvars
    │   └── hub02.tfvars
    ├── hub03/
    │   ├── backend.tf
    │   ├── backend.tfvars
    │   └── hub03.tfvars
    ├── hub04/
    │   ├── backend.tf
    │   ├── backend.tfvars
    │   └── hub04.tfvars
    ├── uat01/
    │   ├── backend.tf
    │   ├── backend.tfvars
    │   └── uat01.tfvars
    ├── uat02/
    │   ├── backend.tf
    │   ├── backend.tfvars
    │   └── uat02.tfvars
    ├── uat03/
    │   ├── backend.tf
    │   ├── backend.tfvars
    │   └── uat03.tfvars
    └── uat04/
        ├── backend.tf
        ├── backend.tfvars
        └── uat04.tfvars
```

### Environment Configuration

Each environment requires three configuration files:

#### backend.tf
```hcl
terraform {
  backend "s3" {
    # Configuration provided via backend.tfvars
  }
}
```

#### backend.tfvars
```hcl
bucket         = "gaspi-terraform-state-hub01"
key            = "hub01/terraform.tfstate"
region         = "ap-southeast-3"
encrypt        = true
dynamodb_table = "gaspi-terraform-locks-hub01"
```

#### hub01.tfvars
```hcl
# Environment: hub01
environment = "hub01"
region      = "ap-southeast-3"
project     = "GASPI"

# Environment-specific tags
tags = {
  Environment = "hub01"
  Project     = "GASPI"
  ManagedBy   = "Terraform"
  Owner       = "DevOps-XTI"
}

# Environment-specific settings
instance_type = "t3.large"
min_size      = 2
max_size      = 10
```

### AWS Profile Configuration

Configure AWS profiles in `~/.aws/config`:

```ini
[profile BGSI-TF-User-Executor-HUB01]
region = ap-southeast-3
role_arn = arn:aws:iam::ACCOUNT-ID:role/TerraformExecutionRole
source_profile = default

[profile BGSI-TF-User-Executor-HUB02]
region = ap-southeast-3
role_arn = arn:aws:iam::ACCOUNT-ID:role/TerraformExecutionRole
source_profile = default

# ... continue for all environments
```

## 🎮 Usage

### Command Line Interface

```bash
# Basic usage
atlantis-deploy <environment> [operation]

# Available environments
hub01, hub02, hub03, hub04, uat01, uat02, uat03, uat04

# Available operations
plan, apply (default: plan)
```

### Examples

#### Plan Deployment
```bash
# Plan deployment for hub01
atlantis-deploy hub01 plan

# Plan deployment for uat02
atlantis-deploy uat02 plan

# Plan deployment (default operation)
atlantis-deploy hub03
```

#### Apply Deployment
```bash
# Apply deployment for hub01
atlantis-deploy hub01 apply

# Apply deployment for uat04
atlantis-deploy uat04 apply
```

#### Help and Version
```bash
# Show help
atlantis-deploy --help

# Show version
atlantis-deploy --version

# Environment-specific help
atlantis-deploy hub01 --help
```

### Atlantis Integration

#### Through Pull Requests

1. **Create Branch**: Create a branch matching your environment
   ```bash
   git checkout -b hub01
   # Make your changes
   git commit -m "Update hub01 infrastructure"
   git push origin hub01
   ```

2. **Create Pull Request**: Open PR against main branch

3. **Atlantis Commands**: Use Atlantis commands in PR comments
   ```
   atlantis plan -p bgsi-hub01
   atlantis apply -p bgsi-hub01
   ```

#### Automatic Triggers

Atlantis automatically triggers on changes to:
- `*.tf` files
- `*.tfvars` files
- `*.hcl` files
- `modules/**/*.tf` files
- `.terraform.lock.hcl`

### Environment-Specific Workflows

Each environment has its dedicated workflow:

| Environment | Workflow | AWS Account | Region |
|-------------|----------|-------------|---------|
| hub01 | hub01-workflow | HUB01 | ap-southeast-3 |
| hub02 | hub02-workflow | HUB02 | ap-southeast-3 |
| hub03 | hub03-workflow | HUB03 | ap-southeast-3 |
| hub04 | hub04-workflow | HUB04 | ap-southeast-3 |
| uat01 | uat01-workflow | UAT01 | ap-southeast-3 |
| uat02 | uat02-workflow | UAT02 | ap-southeast-3 |
| uat03 | uat03-workflow | UAT03 | ap-southeast-3 |
| uat04 | uat04-workflow | UAT04 | ap-southeast-3 |

## 🔧 Troubleshooting

### Common Issues

#### 1. GitHub Authentication Failed
**Error**: `fatal: could not read Username for 'https://github.com'`

**Solution**:
```bash
# Check GitHub token
echo $GITHUB_TOKEN

# Test GitHub access
git ls-remote https://github.com/GSI-Xapiens-CSIRO/report_templates.git

# Verify DevOps XTI has repository access
```

#### 2. AWS Authentication Failed
**Error**: `AWS credential validation failed`

**Solution**:
```bash
# Check AWS profile
aws configure list-profiles

# Test AWS access
aws sts get-caller-identity --profile BGSI-TF-User-Executor-HUB01

# Verify IAM role permissions
```

#### 3. Configuration Files Not Found
**Error**: `Configuration file not found: /atlantis/config/hub01/backend.tf`

**Solution**:
```bash
# Check configuration directory
ls -la /atlantis/config/hub01/

# Verify file permissions
ls -la /atlantis/config/hub01/*.tf*

# Check ATLANTIS_CONFIG_PATH
echo $ATLANTIS_CONFIG_PATH
```

#### 4. Submodule Initialization Failed
**Error**: `Submodule initialization failed`

**Solution**:
```bash
# Check submodule configuration
cat .gitmodules

# Test submodule access
git submodule status

# Manual submodule update
git submodule update --init --recursive --progress
```

### Debug Mode

Enable debug mode for detailed logging:

```bash
# Set debug environment variable
export ATLANTIS_DEBUG=true

# Run with verbose output
atlantis-deploy hub01 plan 2>&1 | tee debug.log
```

### Log Analysis

Check Atlantis logs for issues:

```bash
# View Atlantis server logs
kubectl logs -f deployment/atlantis

# Check specific workflow logs
kubectl logs -f deployment/atlantis | grep "hub01-workflow"
```

## 🔐 Security Considerations

### Secrets Management

1. **GitHub Token**: Store in Kubernetes secrets
2. **AWS Credentials**: Use IAM roles, not access keys
3. **Terraform State**: Encrypted S3 backend with DynamoDB locking

### Access Control

1. **Branch Protection**: Require PR approval
2. **RBAC**: Role-based access to Atlantis
3. **MFA**: Multi-factor authentication for AWS

### Audit Trail

1. **CloudTrail**: All AWS API calls logged
2. **Git History**: All infrastructure changes tracked
3. **Atlantis Logs**: All deployment activities logged

## 🛠️ Maintenance

### Updating the Script

```bash
# Update source script
vim scripts/atlantis-deploy

# Reinstall system-wide
sudo ./install-atlantis-deploy

# Verify update
atlantis-deploy --version
```

### Adding New Environments

1. **Create Configuration Directory**:
   ```bash
   mkdir -p /atlantis/config/hub05
   ```

2. **Add Configuration Files**:
   ```bash
   # Copy from existing environment
   cp /atlantis/config/hub01/* /atlantis/config/hub05/

   # Update environment-specific values
   vim /atlantis/config/hub05/hub05.tfvars
   ```

3. **Update Atlantis Configuration**:
   ```yaml
   # Add to atlantis.yaml
   - name: bgsi-hub05
     branch: /hub05/
     workflow: hub05-workflow
   ```

4. **Update Repo Configuration**:
   ```yaml
   # Add to repo.yaml
   hub05-workflow:
     plan:
       steps:
       - run: atlantis-deploy hub05 plan
   ```

### Monitoring

Monitor deployment health:

```bash
# Check system status
atlantis-deploy --version

# Test all environments
for env in hub01 hub02 hub03 hub04 uat01 uat02 uat03 uat04; do
  echo "Testing $env..."
  atlantis-deploy $env --help
done
```

## 📚 Advanced Usage

### Custom Environment Variables

```bash
# Override default configuration
export ATLANTIS_CONFIG_PATH="/custom/config/path"
export GIT_USER_NAME="Custom Bot"
export GIT_USER_EMAIL="custom-bot@company.com"

# Run with custom settings
atlantis-deploy hub01 plan
```

### Batch Operations

```bash
#!/bin/bash
# batch-deploy.sh

environments=("hub01" "hub02" "hub03" "hub04")

for env in "${environments[@]}"; do
  echo "Planning $env..."
  atlantis-deploy "$env" plan
done
```

### Integration with CI/CD

```yaml
# .github/workflows/atlantis-check.yml
name: Atlantis Configuration Check

on:
  pull_request:
    paths:
      - 'atlantis.yaml'
      - 'repo.yaml'
      - 'scripts/atlantis-deploy'

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install atlantis-deploy
        run: sudo ./install-atlantis-deploy
      - name: Test script
        run: atlantis-deploy --version
```

## 🤝 Contributing

### Development Setup

```bash
# Clone repository
git clone https://github.com/GSI-Xapiens-CSIRO/BGSI-GeneticAnalysisSupportPlatformIndonesia-GASPI.git

# Create feature branch
git checkout -b feature/new-enhancement

# Make changes
vim scripts/atlantis-deploy

# Test changes
./scripts/atlantis-deploy hub01 plan

# Commit and push
git commit -m "Add new enhancement"
git push origin feature/new-enhancement
```

### Testing

```bash
# Run tests
./scripts/test-atlantis-deploy

# Lint script
shellcheck scripts/atlantis-deploy

# Test installation
sudo ./install-atlantis-deploy
```

### Code Style

- Use `set -euo pipefail` for error handling
- Include comprehensive logging
- Follow bash best practices
- Add comments for complex logic

## 📞 Support

### Contact Information

- **Team**: DevOps XTI
- **Email**: support.gxc@xapiens.id
- **Repository**: [BGSI-GASPI](https://github.com/GSI-Xapiens-CSIRO/BGSI-GeneticAnalysisSupportPlatformIndonesia-GASPI)

### Documentation

- [Atlantis Documentation](https://www.runatlantis.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Xignals Documentation](https://xignals.xapiens.id/)

### Community

- [DORA Community](https://dora.community)
- [DevOps Indonesia](https://www.devops.id/)
- [AWS User Group Indonesia](https://www.meetup.com/AWS-User-Group-Indonesia/)

---

## 📄 License

This project is licensed under *Apache v2* - see the [LICENSE](../LICENSE) file for details.

## 🙏 Acknowledgments

- **DORA Research**: For DevOps metrics and best practices
- **OpenTelemetry Community**: For observability standards
- **Atlantis Team**: For the excellent GitOps tool
- **Xapiens Team**: For the Xignals observability platform

---

**Made with ❤️ by the DevOps XTI Team**

*"Simplify Process. Maximize Productivity."*
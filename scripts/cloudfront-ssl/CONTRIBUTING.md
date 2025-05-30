# Contributing to CloudFront SSL Setup

Thank you for your interest in contributing to the CloudFront SSL Setup project! This guide will help you get started with development, testing, and submitting contributions.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Documentation](#documentation)
- [Release Process](#release-process)

## 🤝 Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/). By participating, you are expected to uphold this code. Please report unacceptable behavior to [support@xapiens.id](mailto:support@xapiens.id).

### Our Standards

- **Be respectful** and inclusive
- **Be constructive** in feedback and discussions
- **Focus on the issue**, not the person
- **Help create a welcoming environment** for all contributors

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Bash 4.0+** (check with `bash --version`)
- **Git** for version control
- **AWS CLI v2+** for testing
- **jq** for JSON processing
- **ShellCheck** for code quality
- **bats-core** for testing (optional)

### Development Environment Setup

```bash
# 1. Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/cloudfront-ssl-setup.git
cd cloudfront-ssl-setup

# 2. Install development dependencies
./scripts/install-dev-deps.sh

# 3. Set up pre-commit hooks
./scripts/setup-hooks.sh

# 4. Verify your setup
./scripts/verify-setup.sh
```

### Repository Structure

```
cloudfront-ssl-setup/
├── README.md                     # Main documentation
├── HOW-TO.md                     # Detailed setup guide
├── cloudfront-ssl-setup.sh       # Refactored main script
├── cloudfront-config.template    # Configuration template
├── CONTRIBUTING.md               # Development guidelines
├── LICENSE                       # Apache v2 License
├── examples/                     # Usage examples
│   ├── dev.conf
│   ├── staging.conf
│   ├── production.conf
│   └── xignals-prod.conf
├── scripts/                      # Utility scripts
│   ├── install-deps.sh
│   ├── run-tests.sh
│   └── disaster-recovery.sh
└── docs/                         # Additional documentation
    ├── architecture.md
    ├── security.md
    └── troubleshooting.md
```

## 💻 Development Setup

### Setting Up Your Environment

```bash
# Install development tools
sudo apt-get update
sudo apt-get install -y shellcheck bats

# Or on macOS
brew install shellcheck bats-core

# Install pre-commit (optional but recommended)
pip install pre-commit
pre-commit install
```

### Creating a Development Configuration

```bash
# Copy and customize the template for testing
cp cloudfront-config.template dev-test.conf

# Edit with your test values
nano dev-test.conf
```

### Running the Script in Development Mode

```bash
# Enable debug mode
export DEBUG=true

# Run with dry-run mode (no AWS changes)
./cloudfront-ssl-setup.sh --config dev-test.conf --dry-run

# Run with verbose logging
bash -x cloudfront-ssl-setup.sh --config dev-test.conf
```

## 📝 Coding Standards

### Bash Coding Guidelines

We follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) with the following additions:

#### 1. Script Header

```bash
#!/bin/bash
#
# Script Name: script-name.sh
# Description: Brief description of what the script does
# Author: Your Name <your.email@xapiens.id>
# Version: 1.0.0
# Created: YYYY-MM-DD
# Modified: YYYY-MM-DD
#
```

#### 2. Function Documentation

```bash
# Function: function_name
# Description: What this function does
# Parameters:
#   $1 - First parameter description
#   $2 - Second parameter description
# Returns:
#   0 - Success
#   1 - Error description
# Example:
#   function_name "param1" "param2"
function_name() {
    local param1="$1"
    local param2="$2"

    # Function implementation
}
```

#### 3. Error Handling

```bash
# Always use strict error handling
set -euo pipefail

# Trap errors for cleanup
trap cleanup_on_error ERR

# Use proper error reporting
error() {
    echo -e "\033[0;31m[ERROR]\033[0m $*" >&2
    exit 1
}
```

#### 4. Variable Naming

```bash
# Constants: UPPER_CASE
readonly SCRIPT_VERSION="2.0.0"

# Global variables: UPPER_CASE
CONFIG_FILE="cloudfront-config.conf"

# Local variables: lower_case
local file_name="example.txt"

# Arrays: lower_case
declare -a required_tools=("aws" "jq" "openssl")
```

#### 5. Code Organization

```bash
# Group related functionality
# ================================
# UTILITY FUNCTIONS
# ================================

log() { ... }
warn() { ... }
error() { ... }

# ================================
# AWS OPERATIONS
# ================================

create_certificate() { ... }
configure_security_group() { ... }
```

### Code Quality Checks

#### ShellCheck Compliance

All bash code must pass ShellCheck validation:

```bash
# Run ShellCheck on all scripts
./scripts/lint.sh

# Check specific file
shellcheck cloudfront-ssl-setup.sh

# Fix common issues automatically (when possible)
./scripts/fix-lint.sh
```

#### Common ShellCheck Rules We Follow

- **SC2086**: Quote variables to prevent word splitting
- **SC2034**: Mark unused variables as intentional with `_`
- **SC2016**: Use single quotes for literal strings
- **SC2155**: Declare and assign separately for better error handling

### JSON and Configuration Standards

```bash
# Always validate JSON before use
validate_json() {
    local file="$1"
    if ! jq empty "$file" 2>/dev/null; then
        error "Invalid JSON file: $file"
    fi
}

# Use consistent indentation (2 spaces)
cat > config.json << 'EOF'
{
  "key": "value",
  "nested": {
    "array": [
      "item1",
      "item2"
    ]
  }
}
EOF
```

## 🧪 Testing

### Test Structure

We use a multi-level testing approach:

1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test AWS service interactions
3. **End-to-End Tests**: Test complete workflows
4. **Configuration Tests**: Validate different configurations

### Running Tests

```bash
# Run all tests
./scripts/run-tests.sh

# Run specific test categories
./scripts/run-tests.sh --unit
./scripts/run-tests.sh --integration
./scripts/run-tests.sh --e2e

# Run tests with coverage
./scripts/run-tests.sh --coverage

# Run tests for specific environment
./scripts/run-tests.sh --env staging
```

### Writing Unit Tests

Create test files in `tests/unit/` following this pattern:

```bash
#!/usr/bin/env bats

# File: tests/unit/test_utilities.bats

load '../helpers/test_helper'

setup() {
    # Setup before each test
    source cloudfront-ssl-setup.sh
}

teardown() {
    # Cleanup after each test
    cleanup_test_environment
}

@test "log function outputs correctly formatted message" {
    result=$(log "test message")
    [[ "$result" =~ ^\[.*\].*test\ message$ ]]
}

@test "error function exits with code 1" {
    run error "test error"
    [ "$status" -eq 1 ]
    [[ "$output" =~ ERROR.*test\ error ]]
}

@test "validate_config detects missing required fields" {
    CONFIG[ALB_DNS_NAME]=""
    run validate_config
    [ "$status" -eq 1 ]
}
```

### Writing Integration Tests

```bash
#!/usr/bin/env bats

# File: tests/integration/test_aws_operations.bats

load '../helpers/aws_helper'

setup() {
    setup_aws_test_environment
    source cloudfront-ssl-setup.sh
}

teardown() {
    cleanup_aws_test_resources
}

@test "certificate request creates valid ARN" {
    skip_if_no_aws_credentials

    result=$(request_ssl_certificate_test)
    [[ "$result" =~ ^arn:aws:acm: ]]
}

@test "security group configuration adds correct rules" {
    skip_if_no_aws_credentials

    configure_security_group_test

    # Verify rules were added
    aws ec2 describe-security-groups \
        --group-ids "$TEST_SECURITY_GROUP_ID" \
        --query 'SecurityGroups[0].IpPermissions[?FromPort==`80`]'
}
```

### Test Helpers

Common test utilities in `tests/helpers/`:

```bash
# File: tests/helpers/test_helper.bash

# Load common test utilities
load '/usr/lib/bats/bats-support/load'
load '/usr/lib/bats/bats-assert/load'

# Test environment setup
setup_test_environment() {
    export TEST_MODE=true
    export AWS_DEFAULT_REGION=us-east-1

    # Create temporary directory
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

cleanup_test_environment() {
    cd /
    rm -rf "$TEST_DIR"
}

skip_if_no_aws_credentials() {
    if ! aws sts get-caller-identity &>/dev/null; then
        skip "AWS credentials not configured"
    fi
}

# Mock AWS commands for unit tests
mock_aws() {
    aws() {
        case "$1 $2" in
            "sts get-caller-identity")
                echo '{"Account":"123456789012","UserId":"AIDACKCEVSQ6C2EXAMPLE","Arn":"arn:aws:iam::123456789012:user/test"}'
                ;;
            "acm request-certificate")
                echo "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
                ;;
            *)
                command aws "$@"
                ;;
        esac
    }
}
```

### Test Configuration

```bash
# File: tests/fixtures/test.conf
DOMAIN="example.com"
SUBDOMAIN="test.example.com"
ALB_DNS_NAME="test-alb.us-east-1.elb.amazonaws.com"
SECURITY_GROUP_ID="sg-test123456"
ALB_REGION="us-east-1"
CUSTOM_HEADER_VALUE="test-secret-value"
```

## 📤 Submitting Changes

### Workflow Overview

1. **Create an Issue** (for bugs or feature requests)
2. **Fork the Repository**
3. **Create a Feature Branch**
4. **Make Your Changes**
5. **Test Thoroughly**
6. **Submit a Pull Request**

### Branch Naming Conventions

```bash
# Feature branches
feature/add-waf-integration
feature/improve-error-handling

# Bug fix branches
bugfix/fix-certificate-validation
bugfix/security-group-timeout

# Documentation branches
docs/update-readme
docs/add-troubleshooting-guide

# Hotfix branches (for urgent production fixes)
hotfix/critical-security-patch
```

### Commit Message Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format: type(scope): description

# Examples:
feat(ssl): add support for wildcard certificates
fix(security): resolve security group rule duplication
docs(readme): update installation instructions
test(unit): add tests for configuration validation
refactor(aws): improve error handling in AWS operations
style(lint): fix shellcheck warnings
perf(cache): optimize CloudFront cache behaviors
```

### Pull Request Process

#### 1. Pre-submission Checklist

- [ ] **Code Quality**: All ShellCheck warnings resolved
- [ ] **Tests**: All tests pass (`./scripts/run-tests.sh`)
- [ ] **Documentation**: Updated relevant documentation
- [ ] **Configuration**: Added example configurations if needed
- [ ] **Backwards Compatibility**: No breaking changes (or clearly documented)
- [ ] **Security**: No hardcoded secrets or credentials

#### 2. Pull Request Template

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Tested with multiple AWS environments

## Configuration Changes
- [ ] No configuration changes
- [ ] Backward compatible configuration changes
- [ ] New configuration options added
- [ ] Breaking configuration changes (migration guide provided)

## Documentation
- [ ] Code is self-documenting
- [ ] README.md updated
- [ ] HOW-TO.md updated
- [ ] CHANGELOG.md updated
- [ ] Example configurations provided

## Security Considerations
- [ ] No security implications
- [ ] Security improvements
- [ ] Potential security concerns (explain in description)

## Checklist
- [ ] My code follows the project's coding standards
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
```

#### 3. Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
2. **Code Review**: Maintainers review code and provide feedback
3. **Testing**: Changes are tested in staging environment
4. **Approval**: At least one maintainer approval required
5. **Merge**: Squash and merge to main branch

### CI/CD Pipeline

Our GitHub Actions workflow automatically:

```yaml
# .github/workflows/ci.yml
name: Continuous Integration

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run ShellCheck
        run: shellcheck *.sh scripts/*.sh

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
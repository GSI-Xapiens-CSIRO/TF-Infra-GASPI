# CloudFront SSL Setup for xapiens.id

[![aWS](https://img.shields.io/badge/AWS-CloudFront-orange)](https://aws.amazon.com/cloudfront/)
[![shell](https://img.shields.io/badge/Shell-Bash-green)](https://www.gnu.org/software/bash/)
![all contributors](https://img.shields.io/github/contributors/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
![tags](https://img.shields.io/github/v/tag/GSI-Xapiens-CSIRO/TF-Infra-GASPI?sort=semver)
![view](https://views.whatilearened.today/views/github/GSI-Xapiens-CSIRO/TF-Infra-GASPI.svg)
![issues](https://img.shields.io/github/issues/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
![pull requests](https://img.shields.io/github/issues-pr/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
![forks](https://img.shields.io/github/forks/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
![stars](https://img.shields.io/github/stars/GSI-Xapiens-CSIRO/TF-Infra-GASPI)
[![license](https://img.shields.io/github/license/GSI-Xapiens-CSIRO/TF-Infra-GASPI)](https://img.shields.io/github/license/GSI-Xapiens-CSIRO/TF-Infra-GASPI)

A comprehensive, production-ready bash script for automating CloudFront SSL setup with custom domains. Designed specifically for the Xapiens Observability Platform but adaptable for any AWS infrastructure.

## 🚀 Features

- **🔒 SSL Certificate Management**: Automated ACM certificate request and validation
- **🛡️ Security First**: CloudFront managed prefix lists and custom header protection
- **⚙️ Configuration Management**: Template-based configuration with environment support
- **📊 Built-in Monitoring**: CloudWatch dashboards and alarms
- **🧪 Automated Testing**: Post-deployment validation
- **🔄 CI/CD Ready**: Non-interactive mode for automation
- **🎯 DRY & Clean**: Modular, maintainable code architecture
- **📋 Comprehensive Logging**: Colored output with progress indicators

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## ⚡ Quick Start

```bash
# 1. Download the script and configuration
curl -O https://raw.githubusercontent.com/xapiens/cloudfront-ssl-setup/main/cloudfront-ssl-setup.sh
curl -O https://raw.githubusercontent.com/xapiens/cloudfront-ssl-setup/main/cloudfront-config.template

# 2. Make executable and create config
chmod +x cloudfront-ssl-setup.sh
cp cloudfront-config.template cloudfront-config.conf

# 3. Edit configuration with your values
nano cloudfront-config.conf

# 4. Run the setup
./cloudfront-ssl-setup.sh --config cloudfront-config.conf
```

## 📦 What This Script Does

1. **SSL Certificate**: Requests and validates ACM certificate for your domain
2. **Security Groups**: Configures ALB security groups with CloudFront managed prefix lists
3. **CloudFront Distribution**: Creates optimized distribution with custom SSL
4. **DNS Configuration**: Updates Route 53 with CNAME records
5. **Origin Protection**: Implements custom header security
6. **Monitoring Setup**: Creates CloudWatch dashboards and alarms
7. **Validation Testing**: Runs comprehensive post-deployment tests

## 🛠️ Prerequisites

### Required Tools
- **AWS CLI v2+** with configured credentials
- **jq** for JSON processing
- **openssl** for secret generation
- **dig** for DNS testing (optional, for validation)

### AWS Permissions
Your AWS user/role needs permissions for:
- ACM (Certificate Manager)
- CloudFront
- Route 53
- EC2 (Security Groups)
- CloudWatch
- SNS (optional, for notifications)

### Infrastructure Requirements
- **Application Load Balancer** (ALB) or origin server
- **Route 53 Hosted Zone** for your domain
- **Security Group** attached to your ALB

## 📥 Installation

### Option 1: Direct Download
```bash
# Download script
curl -O https://raw.githubusercontent.com/xapiens/cloudfront-ssl-setup/main/cloudfront-ssl-setup.sh
chmod +x cloudfront-ssl-setup.sh

# Download configuration template
curl -O https://raw.githubusercontent.com/xapiens/cloudfront-ssl-setup/main/cloudfront-config.template
```

### Option 2: Git Clone
```bash
git clone https://github.com/xapiens/cloudfront-ssl-setup.git
cd cloudfront-ssl-setup
chmod +x cloudfront-ssl-setup.sh
```

### Option 3: Package Manager (if available)
```bash
# Using npm (if published)
npm install -g @xapiens/cloudfront-ssl-setup

# Using brew (if published)
brew install xapiens/tap/cloudfront-ssl-setup
```

## 🎯 Usage

### Interactive Mode
```bash
# Run with guided prompts
./cloudfront-ssl-setup.sh
```

### Configuration File Mode
```bash
# Use pre-configured settings
./cloudfront-ssl-setup.sh --config production.conf
```

### Testing Mode
```bash
# Validate existing setup
./cloudfront-ssl-setup.sh --test-only --config production.conf
```

### Monitoring Setup
```bash
# Setup monitoring for existing distribution
./cloudfront-ssl-setup.sh --monitor-only --config production.conf
```

### Help
```bash
# Show all options
./cloudfront-ssl-setup.sh --help
```

## ⚙️ Configuration

### Basic Configuration Template

Create `cloudfront-config.conf` from template:

```bash
# Domain configuration
DOMAIN="xapiens.id"
SUBDOMAIN="rscm-dev.xapiens.id"

# Infrastructure
ALB_DNS_NAME="alb-123456789.ap-southeast-1.elb.amazonaws.com"
SECURITY_GROUP_ID="sg-0123456789abcdef0"
ALB_REGION="ap-southeast-1"

# CloudFront settings
PRICE_CLASS="PriceClass_All"
MIN_PROTOCOL_VERSION="TLSv1.2_2021"

# Security
CUSTOM_HEADER_NAME="X-CloudFront-Secret"
# CUSTOM_HEADER_VALUE will be auto-generated
```

### Environment-Specific Configurations

**Development (`dev.conf`)**:
```bash
SUBDOMAIN="dev.xapiens.id"
PRICE_CLASS="PriceClass_100"
DEFAULT_TTL="300"
ERROR_RATE_THRESHOLD="15"
```

**Production (`production.conf`)**:
```bash
SUBDOMAIN="www.xapiens.id"
PRICE_CLASS="PriceClass_All"
DEFAULT_TTL="86400"
ERROR_RATE_THRESHOLD="5"
ENABLE_ACCESS_LOGS="true"
NOTIFICATION_EMAIL="alerts@xapiens.id"
```

## 📝 Examples

### Complete Setup for Xignals Platform

```bash
# 1. Create Xignals-specific configuration
cat > xignals-prod.conf << EOF
DOMAIN="xapiens.id"
SUBDOMAIN="xignals.xapiens.id"
ALB_DNS_NAME="xignals-alb-prod.ap-southeast-1.elb.amazonaws.com"
SECURITY_GROUP_ID="sg-xignals-prod"
ALB_REGION="ap-southeast-1"

# Optimized for observability platform
FORWARD_HEADERS="Host,Authorization,X-API-Key,X-Observability-Source"
FORWARD_COOKIES="none"
QUERY_STRING="true"
DEFAULT_TTL="300"
COMPRESS="true"

# Monitoring
ENABLE_MONITORING="true"
ERROR_RATE_THRESHOLD="2"
NOTIFICATION_EMAIL="sre@xapiens.id"
EOF

# 2. Deploy Xignals CloudFront
./cloudfront-ssl-setup.sh --config xignals-prod.conf

# 3. Test the deployment
./cloudfront-ssl-setup.sh --config xignals-prod.conf --test-only
```

### Multi-Environment Deployment

```bash
# Deploy to all environments
for env in dev staging production; do
    echo "Deploying to $env..."
    ./cloudfront-ssl-setup.sh --config "${env}.conf"

    echo "Testing $env deployment..."
    ./cloudfront-ssl-setup.sh --config "${env}.conf" --test-only
done
```

### CI/CD Pipeline Integration

**GitHub Actions Workflow:**
```yaml
name: Deploy CloudFront Infrastructure
on:
  push:
    branches: [main]
    paths: ['infrastructure/**']

jobs:
  deploy-cloudfront:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [staging, production]

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y jq dnsutils

      - name: Deploy CloudFront
        run: |
          chmod +x cloudfront-ssl-setup.sh
          ./cloudfront-ssl-setup.sh --config ${{ matrix.environment }}.conf

      - name: Validate deployment
        run: |
          ./cloudfront-ssl-setup.sh --config ${{ matrix.environment }}.conf --test-only

      - name: Setup monitoring
        if: matrix.environment == 'production'
        run: |
          ./cloudfront-ssl-setup.sh --config production.conf --monitor-only
```

### Docker Integration

```dockerfile
FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    aws-cli \
    jq \
    openssl \
    bind-tools \
    bash

# Copy script and configs
COPY cloudfront-ssl-setup.sh /usr/local/bin/
COPY *.conf /configs/

# Make executable
RUN chmod +x /usr/local/bin/cloudfront-ssl-setup.sh

ENTRYPOINT ["/usr/local/bin/cloudfront-ssl-setup.sh"]
```

**Usage with Docker:**
```bash
# Build the container
docker build -t cloudfront-ssl-setup .

# Run deployment
docker run -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
    cloudfront-ssl-setup --config /configs/production.conf
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### 1. Certificate Validation Fails
```bash
# Check DNS propagation
dig _validation-record.xapiens.id CNAME

# Verify record exists in Route 53
aws route53 list-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --query 'ResourceRecordSets[?Type==`CNAME`]'

# Manual validation check
aws acm describe-certificate \
    --certificate-arn arn:aws:acm:us-east-1:123456789012:certificate/abc123 \
    --query 'Certificate.DomainValidationOptions'
```

**Solution**: Wait up to 30 minutes for DNS propagation. Ensure validation records are added correctly.

#### 2. 403 Forbidden Errors
```bash
# Check security group rules
aws ec2 describe-security-groups \
    --group-ids sg-0123456789abcdef0 \
    --query 'SecurityGroups[0].IpPermissions'

# Test with custom header
curl -H "X-CloudFront-Secret: your-secret-value" https://xignals.xapiens.id

# Check ALB target health
aws elbv2 describe-target-health \
    --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/name
```

**Solution**: Verify security group allows CloudFront IPs and custom header is configured correctly.

#### 3. DNS Not Resolving
```bash
# Check CNAME record
dig xignals.xapiens.id CNAME

# Verify in Route 53
aws route53 list-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --query 'ResourceRecordSets[?Name==`xignals.xapiens.id.`]'

# Force DNS cache flush
sudo systemctl restart systemd-resolved  # Ubuntu
sudo dscacheutil -flushcache            # macOS
ipconfig /flushdns                      # Windows
```

**Solution**: Wait for DNS propagation (up to 48 hours globally, usually 5-10 minutes).

#### 4. CloudFront Distribution Creation Fails
```bash
# Check distribution limits
aws cloudfront describe-account-attributes \
    --query 'AccountAttributes[?Name==`max-distributions`]'

# Verify certificate is in us-east-1
aws acm list-certificates --region us-east-1

# Check for existing distributions
aws cloudfront list-distributions \
    --query 'DistributionList.Items[?Aliases.Items[0]==`xignals.xapiens.id`]'
```

**Solution**: Ensure certificate is in us-east-1 and you haven't exceeded CloudFront limits.

#### 5. Script Permission Errors
```bash
# Fix script permissions
chmod +x cloudfront-ssl-setup.sh

# Check AWS permissions
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::123456789012:user/username \
    --action-names cloudfront:CreateDistribution \
    --resource-arns "*"
```

### Debug Mode

Enable detailed debugging:
```bash
# Run with debug output
bash -x cloudfront-ssl-setup.sh --config debug.conf

# Check generated files
ls -la *.txt *.json

# View CloudFront distribution config
cat distribution-config.json | jq '.'
```

### Log Analysis

```bash
# Script generates several log files:
tail -f setup.log                    # Main execution log
cat alb-security-config.txt         # Security configuration
cat dns_validation.txt              # DNS validation records

# CloudFront access logs (if enabled)
aws s3 ls s3://your-logs-bucket/cloudfront-logs/

# CloudWatch logs
aws logs describe-log-groups \
    --log-group-name-prefix /aws/cloudfront
```

## 🤝 Contributing

### Development Setup

```bash
# Clone the repository
git clone https://github.com/xapiens/cloudfront-ssl-setup.git
cd cloudfront-ssl-setup

# Install development dependencies
./scripts/install-dev-deps.sh

# Run tests
./scripts/run-tests.sh

# Check code style
shellcheck cloudfront-ssl-setup.sh
```

### Code Standards

- **Bash Best Practices**: Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- **Error Handling**: Use `set -euo pipefail` and proper error trapping
- **Documentation**: Document all functions and complex logic
- **Testing**: Include tests for new functionality
- **Logging**: Use structured logging with timestamps

### Submitting Changes

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Reporting Issues

When reporting issues, please include:
- **Script version** and commit hash
- **AWS CLI version** (`aws --version`)
- **Operating system** and version
- **Complete error message** and stack trace
- **Configuration file** (with sensitive data removed)
- **Steps to reproduce** the issue

## 📊 Monitoring and Observability

### Built-in Monitoring

The script automatically sets up:

1. **CloudWatch Dashboard** with key metrics
2. **CloudWatch Alarms** for error rates and request volume
3. **SNS Notifications** (optional) for alerts

### Custom Metrics for Xignals Platform

```bash
# Add custom metrics to your configuration
cat >> xignals-monitoring.conf << EOF
# Xignals-specific monitoring
CUSTOM_METRICS_NAMESPACE="Xignals/Observability"
ALERT_THRESHOLDS_CONFIG="high-availability"

# Metrics endpoints to monitor
HEALTH_CHECK_ENDPOINTS="
/health
/metrics
/api/v1/status
/synthetic/health
"

# Custom alarms
RESPONSE_TIME_THRESHOLD="500"  # milliseconds
ERROR_RATE_THRESHOLD="1"       # percentage
AVAILABILITY_THRESHOLD="99.9"  # percentage
EOF
```

### Integration with Xignals Platform

```bash
# Configure Xignals to monitor itself
./cloudfront-ssl-setup.sh \
    --config xignals-monitoring.conf \
    --monitor-only \
    --enable-synthetic-monitoring
```

## 🔐 Security Considerations

### Production Security Checklist

- [ ] **Custom Headers**: Verify secret header is configured
- [ ] **Security Groups**: Remove 0.0.0.0/0 rules after setup
- [ ] **SSL/TLS**: Use TLS 1.2+ minimum
- [ ] **Access Logs**: Enable for audit trails
- [ ] **WAF Integration**: Consider AWS WAF for additional protection
- [ ] **Secrets Management**: Use AWS Secrets Manager for production
- [ ] **IAM Policies**: Follow principle of least privilege

### Security Best Practices

```bash
# Generate strong secrets
CUSTOM_HEADER_VALUE=$(openssl rand -base64 32)

# Use AWS Secrets Manager
aws secretsmanager create-secret \
    --name "xignals/cloudfront/custom-header" \
    --secret-string "$CUSTOM_HEADER_VALUE"

# Rotate secrets regularly
aws secretsmanager rotate-secret \
    --secret-id "xignals/cloudfront/custom-header"
```

## 📈 Performance Optimization

### CloudFront Optimization for Observability

```bash
# Optimized configuration for metrics and monitoring data
CACHE_POLICY_ID="metrics-optimized"
ORIGIN_REQUEST_POLICY_ID="observability-headers"

# Custom cache behaviors for different endpoints
CACHE_BEHAVIORS="
/api/v1/metrics:no-cache
/api/v1/logs:no-cache
/static/*:long-cache
/assets/*:long-cache
"
```

### Cost Optimization

```bash
# Development environment - cost optimized
PRICE_CLASS="PriceClass_100"        # US, Europe, Asia only
DEFAULT_TTL="300"                   # 5 minutes
MAX_TTL="3600"                      # 1 hour

# Production environment - performance optimized
PRICE_CLASS="PriceClass_All"        # Global edge locations
DEFAULT_TTL="86400"                 # 24 hours
MAX_TTL="31536000"                  # 1 year
```

## 🧪 Testing

### Automated Testing Suite

```bash
# Run all tests
./scripts/run-tests.sh

# Run specific test categories
./scripts/run-tests.sh --unit
./scripts/run-tests.sh --integration
./scripts/run-tests.sh --e2e

# Test with different configurations
./scripts/test-configs.sh dev staging production
```

### Manual Testing Checklist

```bash
# 1. SSL Certificate Test
echo | openssl s_client -connect xignals.xapiens.id:443 -servername xignals.xapiens.id

# 2. HTTP to HTTPS Redirect
curl -I http://xignals.xapiens.id

# 3. CloudFront Headers
curl -I https://xignals.xapiens.id | grep -i x-cache

# 4. Custom Header Protection
curl -H "X-CloudFront-Secret: wrong-secret" https://xignals.xapiens.id

# 5. Performance Test
curl -w "@curl-format.txt" -o /dev/null -s https://xignals.xapiens.id
```

## 📚 Additional Resources

### AWS Documentation
- [CloudFront Developer Guide](https://docs.aws.amazon.com/cloudfront/)
- [ACM User Guide](https://docs.aws.amazon.com/acm/)
- [Route 53 Developer Guide](https://docs.aws.amazon.com/route53/)

### Xignals Platform Documentation
- [Xignals Observability Platform](https://docs.xapiens.id/xignals/)
- [API Documentation](https://api-docs.xapiens.id/)
- [Architecture Guide](https://docs.xapiens.id/architecture/)

### Related Tools
- [AWS CDK for Infrastructure as Code](https://aws.amazon.com/cdk/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [CloudFormation Templates](https://aws.amazon.com/cloudformation/)

## 📄 License

This project is licensed under Apache v2 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **AWS CloudFront Team** for the managed prefix lists feature
- **Xapiens Engineering Team** for observability platform requirements
- **Open Source Community** for bash scripting best practices
- **Contributors** who helped improve this script

## 📞 Support

- **Documentation**: [HOW-TO.md](HOW-TO.md)
- **Issues**: [GitHub Issues](https://github.com/xapiens/cloudfront-ssl-setup/issues)
- **Discussions**: [GitHub Discussions](https://github.com/xapiens/cloudfront-ssl-setup/discussions)
- **Email**: [support@xapiens.id](mailto:support@xapiens.id)

---

**Made with ❤️ by the Xapiens Team**

*Simplify Process. Maximize Productivity.*
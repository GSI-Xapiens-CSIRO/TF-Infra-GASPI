# CloudTrail Infrastructure Cleanup Script

A comprehensive Python script for safely cleaning up AWS CloudTrail infrastructure deployed with Terraform, while preserving CloudWatch log groups and only removing CloudTrail-related subscription filters.

## 🎯 Purpose

This script is designed for **genomic data exchange platforms using sBeacon and sVEP** in AWS environments. It safely removes CloudTrail infrastructure while preserving valuable application logs from Lambda functions.

## ✨ Features

- **🔒 Safe CloudWatch Log Group Handling**: Only removes `cloudtrail-to-kinesis` subscription filters, preserves all log groups
- **📁 Flexible Configuration**: Supports `.env` files, `cloudtrails.txt` (Terraform outputs), and environment variables
- **🔍 Dry-Run Mode**: Preview what will be deleted without making changes
- **⚡ Smart Resource Detection**: Automatically handles missing resources gracefully
- **🚀 Complete Infrastructure Cleanup**: Handles all CloudTrail-related AWS resources
- **📊 Detailed Progress Tracking**: Real-time status updates with color-coded output

## 📋 Prerequisites

### System Requirements
- **Python 3.8+**
- **AWS CLI configured** with appropriate credentials
- **Terraform** (optional, for running `terraform destroy`)

### AWS Permissions Required
The AWS credentials used must have permissions for:
- CloudWatch Logs (describe/delete subscription filters)
- CloudTrail (stop logging, delete trail)
- Kinesis (delete streams and firehose)
- Lambda (delete functions)
- OpenSearch (delete domains)
- S3 (list/delete objects)
- IAM (for role operations)
- SSM (delete parameters)

## 🚀 Quick Start

### 1. Installation

```bash
# Clone or download the script
curl -O https://your-repo/cloudtrail_cleanup.py

# Install dependencies
pip install -r requirements.txt

# Make executable (optional)
chmod +x cloudtrail_cleanup.py
```

### 2. Prepare Configuration

**Option A: Use existing Terraform outputs**
```bash
# If you have cloudtrails.txt from terraform output
terraform output > cloudtrails.txt
```

**Option B: Create .env file**
```bash
# Create .env file with your configuration
cat > .env << EOF
AWS_REGION=ap-southeast-3
AWS_ACCOUNT_ID=209479276142
TERRAFORM_DIR=./environments/bgsi-hub01/cloudtrails
OPENSEARCH_DOMAIN_NAME=opensearch-209479276142
EOF
```

### 3. Verify Configuration

```bash
# Check what configuration will be used
python cloudtrail_cleanup.py --show-config
```

### 4. Test Run (Recommended)

```bash
# See what would be deleted without making changes
python cloudtrail_cleanup.py --dry-run
```

### 5. Execute Cleanup

```bash
# Run the actual cleanup
python cloudtrail_cleanup.py
```

## 📖 Detailed Usage

### Command Line Options

```bash
python cloudtrail_cleanup.py [OPTIONS]

Options:
  --terraform-dir PATH     Path to terraform directory (default: from config or ".")
  --env-file PATH         Path to .env file (default: ".env")
  --cloudtrails-file PATH Path to cloudtrails.txt file (default: "cloudtrails.txt")
  --dry-run              Show what would be deleted without actually deleting
  --show-config          Show loaded configuration and exit
  -h, --help             Show help message
```

### Configuration Sources (Priority Order)

1. **`.env` file** (highest priority)
2. **`cloudtrails.txt`** (Terraform outputs)
3. **Environment variables**
4. **Command line arguments**

### Configuration File Examples

#### `.env` File Format
```bash
# AWS Configuration
AWS_REGION=ap-southeast-3
AWS_ACCOUNT_ID=209479276142
TERRAFORM_DIR=./terraform/cloudtrails

# Resource Names (override defaults)
OPENSEARCH_DOMAIN_NAME=opensearch-209479276142
LAMBDA_FUNCTION_NAME=genomic-cloudtrail-processor-209479276142
KINESIS_FIREHOSE_NAME=genomic-cloudtrail-kinesis-opensearch-209479276142
KINESIS_FIREHOSE_STREAM_NAME=genomic-cloudtrail-kinesis-stream-209479276142
CLOUDTRAIL_BUCKET=genomic-cloudtrail-209479276142
CLOUDTRAIL_ARN=arn:aws:cloudtrail:ap-southeast-3:209479276142:trail/genomic-services-trail-209479276142
OPENSEARCH_PASSWORD_PARAMETER=/genomic/cloudtrail/opensearch/master-password

# CloudWatch Log Groups (comma-separated)
CLOUDWATCH_LOG_GROUPS_SBEACON=/aws/lambda/sbeacon-backend-admin,/aws/lambda/sbeacon-backend-dataPortal
CLOUDWATCH_LOG_GROUPS_SVEP=/aws/lambda/svep-backend-concat,/aws/lambda/svep-backend-initQuery
```

#### `cloudtrails.txt` Format (Terraform Outputs)
```bash
cloudtrail_arn = "arn:aws:cloudtrail:ap-southeast-3:209479276142:trail/genomic-services-trail-209479276142"
cloudtrail_bucket = "genomic-cloudtrail-209479276142"
opensearch_domain_name = "opensearch-209479276142"
lambda_function_name = "genomic-cloudtrail-processor-209479276142"
cloudwatch_log_groups_sbeacon = [
  "/aws/lambda/sbeacon-backend-admin",
  "/aws/lambda/sbeacon-backend-dataPortal",
]
cloudwatch_log_groups_svep = [
  "/aws/lambda/svep-backend-concat",
  "/aws/lambda/svep-backend-initQuery",
]
```

## 🔧 Configuration Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `aws_region` | AWS region | `ap-southeast-3` |
| `aws_account_id` | AWS account ID | `209479276142` |
| `opensearch_domain_name` | OpenSearch domain name | `opensearch-209479276142` |
| `lambda_function_name` | CloudTrail processor Lambda | `genomic-cloudtrail-processor-209479276142` |
| `kinesis_firehose_name` | Kinesis Firehose delivery stream | `genomic-cloudtrail-kinesis-opensearch-209479276142` |
| `kinesis_firehose_stream_name` | Kinesis Data Stream | `genomic-cloudtrail-kinesis-stream-209479276142` |
| `cloudtrail_arn` | CloudTrail ARN | `arn:aws:cloudtrail:...` |
| `cloudtrail_bucket` | S3 bucket for CloudTrail logs | `genomic-cloudtrail-209479276142` |
| `opensearch_password_parameter` | SSM parameter for OpenSearch password | `/genomic/cloudtrail/opensearch/master-password` |
| `cloudwatch_log_groups_sbeacon` | List of sBeacon log groups | `["/aws/lambda/sbeacon-..."]` |
| `cloudwatch_log_groups_svep` | List of sVEP log groups | `["/aws/lambda/svep-..."]` |

## 🚦 What Gets Deleted vs. Preserved

### ✅ Resources That Get Deleted
- **CloudTrail**: Trail and logging configuration
- **Kinesis**: Data Streams and Firehose delivery streams
- **Lambda**: CloudTrail processor functions
- **OpenSearch**: Search domain and indices
- **S3**: Objects in CloudTrail bucket (bucket deleted by Terraform)
- **SSM**: OpenSearch password parameters
- **CloudWatch**: Only `cloudtrail-to-kinesis` subscription filters
- **IAM**: Roles and policies (via Terraform destroy)
- **KMS**: Keys (via Terraform destroy)

### 🛡️ Resources That Are Preserved
- **CloudWatch Log Groups**: All sBeacon and sVEP application logs
- **Lambda Functions**: sBeacon and sVEP application functions
- **Application Infrastructure**: EKS, RDS, other genomic platform resources

## 📊 Execution Flow

1. **Configuration Loading**: Load from .env, cloudtrails.txt, and environment
2. **AWS Client Initialization**: Verify credentials and connectivity
3. **CloudWatch Filter Cleanup**: Remove only CloudTrail subscription filters
4. **Lambda Deletion**: Remove CloudTrail processor function
5. **Kinesis Cleanup**: Delete streams and firehose
6. **CloudTrail Deletion**: Stop logging and delete trail
7. **S3 Cleanup**: Empty CloudTrail bucket
8. **SSM Cleanup**: Delete OpenSearch password parameter
9. **OpenSearch Deletion**: Delete search domain (10-15 minutes)
10. **Terraform Destroy**: Clean up remaining infrastructure

## 🎯 Use Cases

### Genomic Data Exchange Environments

This script is specifically designed for:
- **sBeacon Data Portal** cleanup while preserving genomic query logs
- **sVEP (Variant Effect Predictor)** cleanup while preserving analysis logs
- **Multi-account Landing Zone** CloudTrail infrastructure removal
- **Compliance auditing** infrastructure cleanup after project completion

### DevOps Scenarios

- **Environment teardown** (staging, development)
- **Cost optimization** (removing unused logging infrastructure)
- **Migration preparation** (before moving to new logging solution)
- **Security incident response** (controlled infrastructure removal)

## 🔍 Troubleshooting

### Common Issues

#### 1. AWS Credentials Not Found
```bash
❌ AWS credentials not found. Please configure your credentials.
```
**Solution**: Configure AWS credentials
```bash
aws configure
# OR
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_SESSION_TOKEN=your_token  # if using temporary credentials
```

#### 2. Configuration File Not Found
```bash
⚠️  cloudtrails.txt file not found: cloudtrails.txt
```
**Solution**: Generate or create configuration
```bash
# Generate from Terraform
terraform output > cloudtrails.txt

# OR create .env file
echo "AWS_REGION=ap-southeast-3" > .env
echo "AWS_ACCOUNT_ID=209479276142" >> .env
```

#### 3. Resource Not Found Errors
```bash
⚠️  OpenSearch domain opensearch-123456 not found, skipping...
```
**Solution**: This is normal - the script gracefully handles missing resources.

#### 4. Permission Denied
```bash
❌ Error deleting OpenSearch domain: AccessDenied
```
**Solution**: Ensure your AWS credentials have the required permissions.

#### 5. Terraform Not Found
```bash
❌ Terraform not found. Please install Terraform
```
**Solution**: Install Terraform or run without Terraform destroy
```bash
# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

### Debug Mode

For detailed debugging, you can modify the script to enable verbose logging:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Manual Resource Verification

After running the script, verify resources are deleted:

```bash
# Check CloudWatch subscription filters
aws logs describe-subscription-filters --log-group-name "/aws/lambda/sbeacon-backend-admin"

# Check OpenSearch domain
aws opensearch describe-domain --domain-name opensearch-209479276142

# Check Kinesis streams
aws kinesis list-streams

# Check Lambda functions
aws lambda list-functions --query 'Functions[?contains(FunctionName, `cloudtrail`)]'
```

## 🔐 Security Considerations

### Credentials Management
- Use **IAM roles** instead of access keys when possible
- Implement **least privilege** access
- Use **temporary credentials** for automation
- Store sensitive data in **AWS Systems Manager Parameter Store**

### Safe Practices
- Always run **`--dry-run`** first
- Review configuration with **`--show-config`**
- Keep **backups** of important data before cleanup
- Test in **non-production** environments first

## 📈 Performance Notes

### Expected Execution Times
- **CloudWatch filters**: 1-2 minutes (depends on number of log groups)
- **Lambda deletion**: 30 seconds
- **Kinesis cleanup**: 2-3 minutes
- **CloudTrail deletion**: 30 seconds
- **S3 object deletion**: 1-5 minutes (depends on object count)
- **OpenSearch deletion**: 10-15 minutes (longest operation)
- **Terraform destroy**: 5-10 minutes

### Optimization Tips
- Run during **off-peak hours** for production environments
- Use **parallel execution** for multiple environments (run script separately for each)
- Monitor **AWS service limits** if cleaning up many resources

## 🔄 Integration with CI/CD

### GitHub Actions Example
```yaml
name: Cleanup CloudTrail Infrastructure
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to cleanup'
        required: true
        type: choice
        options: ['staging', 'dev']
      dry_run:
        description: 'Dry run mode'
        type: boolean
        default: true

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-southeast-3

      - name: Run cleanup
        run: |
          python cloudtrail_cleanup.py \
            --env-file .env.${{ github.event.inputs.environment }} \
            ${{ github.event.inputs.dry_run == 'true' && '--dry-run' || '' }}
```

### Jenkins Pipeline Example
```groovy
pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['staging', 'dev'], description: 'Environment to cleanup')
        booleanParam(name: 'DRY_RUN', defaultValue: true, description: 'Run in dry-run mode')
    }

    stages {
        stage('Setup') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Cleanup') {
            steps {
                withAWS(credentials: 'aws-credentials', region: 'ap-southeast-3') {
                    script {
                        def dryRunFlag = params.DRY_RUN ? '--dry-run' : ''
                        sh "python cloudtrail_cleanup.py --env-file .env.${params.ENVIRONMENT} ${dryRunFlag}"
                    }
                }
            }
        }
    }
}
```

## 📞 Support

### Getting Help
1. **Check configuration**: `python cloudtrail_cleanup.py --show-config`
2. **Run dry-run**: `python cloudtrail_cleanup.py --dry-run`
3. **Check AWS permissions**: Ensure your credentials have required permissions
4. **Review logs**: Check the detailed output for specific error messages

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📜 License

This script is provided under the Apache-v2 License. Use at your own risk and always test in non-production environments first.

---

**⚠️ Important**: This script performs destructive operations. Always backup important data and test thoroughly before using in production environments.
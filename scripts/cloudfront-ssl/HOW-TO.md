# HOW-TO: CloudFront SSL Setup for xapiens.id

This guide walks you through setting up CloudFront with custom SSL certificate for your domain using the automated script.

## Prerequisites

### 1. Install Required Tools

**On Ubuntu/Debian:**
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install jq
sudo apt update
sudo apt install jq -y
```

**On macOS:**
```bash
# Install AWS CLI
brew install awscli

# Install jq
brew install jq
```

**On CentOS/RHEL:**
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install jq
sudo yum install epel-release -y
sudo yum install jq -y
```

### 2. Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure

# Or use environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 3. Required AWS Permissions

Your AWS user/role needs these permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "acm:RequestCertificate",
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "cloudfront:CreateDistribution",
                "cloudfront:GetDistribution",
                "cloudfront:UpdateDistribution",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DescribeSecurityGroups",
                "route53:ChangeResourceRecordSets",
                "route53:GetChange",
                "route53:ListHostedZones"
            ],
            "Resource": "*"
        }
    ]
}
```

## Pre-Setup Information Gathering

### 1. Get Your ALB Information

```bash
# List your load balancers
aws elbv2 describe-load-balancers --region ap-southeast-1 --output table

# Note down:
# - DNSName (e.g., alb-123456789.ap-southeast-1.elb.amazonaws.com)
# - LoadBalancerArn
```

### 2. Get Security Group ID

```bash
# Find security groups associated with your ALB
aws elbv2 describe-load-balancers \
    --load-balancer-arns "your-alb-arn" \
    --query 'LoadBalancers[0].SecurityGroups' \
    --region ap-southeast-1

# Or list all security groups
aws ec2 describe-security-groups \
    --region ap-southeast-1 \
    --query 'SecurityGroups[*].[GroupId,GroupName,Description]' \
    --output table
```

### 3. Verify Route 53 Hosted Zone

```bash
# Check if xapiens.id hosted zone exists
aws route53 list-hosted-zones \
    --query 'HostedZones[?Name==`xapiens.id.`]' \
    --output table

# If not exists, create it:
aws route53 create-hosted-zone \
    --name xapiens.id \
    --caller-reference "xapiens-$(date +%s)"
```

## Running the Script

### 1. Download and Prepare Script

```bash
# Download the script
curl -O https://your-repo/cloudfront-ssl-setup.sh

# Make executable
chmod +x cloudfront-ssl-setup.sh

# Review the script (recommended)
less cloudfront-ssl-setup.sh
```

### 2. Run the Script

```bash
# Execute the script
./cloudfront-ssl-setup.sh
```

### 3. Follow Interactive Prompts

The script will ask for:

1. **ALB DNS Name**:
   ```
   Enter your ALB DNS name: alb-123456789.ap-southeast-1.elb.amazonaws.com
   ```

2. **Security Group ID**:
   ```
   Enter your Security Group ID: sg-0123456789abcdef0
   ```

3. **ALB Region** (default: ap-southeast-1):
   ```
   Enter your ALB region [ap-southeast-1]:
   ```

### 4. DNS Validation Step

When prompted, the script will display DNS records like:
```
_abc123.rscm-dev.xapiens.id CNAME _xyz789.acm-validations.aws.
```

**Add this record to your DNS:**

**Option A: Route 53 Console**
1. Go to Route 53 console
2. Select xapiens.id hosted zone
3. Create record with exact name, type, and value shown

**Option B: AWS CLI**
```bash
aws route53 change-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "_abc123.rscm-dev.xapiens.id",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [{"Value": "_xyz789.acm-validations.aws."}]
            }
        }]
    }'
```

## Post-Setup Configuration

### 1. Configure Your Application

The script generates a custom header secret. Add this to your application:

**Nginx Example:**
```nginx
server {
    listen 80;
    server_name rscm-dev.xapiens.id;

    # Security: Only allow CloudFront
    if ($http_x_cloudfront_secret != "your-generated-secret") {
        return 403;
    }

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Apache Example:**
```apache
<VirtualHost *:80>
    ServerName rscm-dev.xapiens.id

    # Security: Only allow CloudFront
    RewriteEngine On
    RewriteCond %{HTTP:X-CloudFront-Secret} !^your-generated-secret$
    RewriteRule .* - [F,L]

    # Your existing configuration
    ProxyPass / http://backend/
    ProxyPassReverse / http://backend/
</VirtualHost>
```

**Express.js Example:**
```javascript
app.use((req, res, next) => {
    const cloudFrontSecret = 'your-generated-secret';
    if (req.headers['x-cloudfront-secret'] !== cloudFrontSecret) {
        return res.status(403).send('Access denied');
    }
    next();
});
```

### 2. Remove Insecure Security Group Rules

```bash
# List current rules
aws ec2 describe-security-groups \
    --group-ids sg-0123456789abcdef0 \
    --region ap-southeast-1

# Remove rules allowing 0.0.0.0/0 (if any)
aws ec2 revoke-security-group-ingress \
    --group-id sg-0123456789abcdef0 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --region ap-southeast-1

aws ec2 revoke-security-group-ingress \
    --group-id sg-0123456789abcdef0 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 \
    --region ap-southeast-1
```

## Testing Your Setup

### 1. Test SSL Certificate

```bash
# Check certificate
openssl s_client -connect rscm-dev.xapiens.id:443 -servername rscm-dev.xapiens.id

# Check HTTP to HTTPS redirect
curl -I http://rscm-dev.xapiens.id
```

### 2. Test CloudFront Distribution

```bash
# Test through CloudFront
curl -I https://rscm-dev.xapiens.id

# Test direct ALB access (should fail if configured correctly)
curl -I https://alb-123456789.ap-southeast-1.elb.amazonaws.com \
    -H "Host: rscm-dev.xapiens.id"
```

### 3. Monitor CloudFront Logs

```bash
# Enable real-time logs (optional)
aws logs create-log-group \
    --log-group-name /aws/cloudfront/realtime-logs

# Check distribution metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/CloudFront \
    --metric-name Requests \
    --dimensions Name=DistributionId,Value=E1234567890ABC \
    --start-time 2025-01-01T00:00:00Z \
    --end-time 2025-01-01T23:59:59Z \
    --period 3600 \
    --statistics Sum
```

## Troubleshooting

### Common Issues

**1. Certificate validation fails:**
```bash
# Check DNS record exists
dig _abc123.rscm-dev.xapiens.id CNAME

# Wait longer (can take up to 30 minutes)
aws acm describe-certificate --certificate-arn your-cert-arn
```

**2. 403 Forbidden errors:**
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids sg-0123456789abcdef0

# Verify custom header configuration
curl -H "X-CloudFront-Secret: your-secret" https://rscm-dev.xapiens.id
```

**3. DNS not resolving:**
```bash
# Check CNAME record
dig rscm-dev.xapiens.id CNAME

# Force DNS refresh
sudo systemctl restart systemd-resolved  # Ubuntu
sudo dscacheutil -flushcache            # macOS
```

### Cleanup (if needed)

```bash
# Delete CloudFront distribution
aws cloudfront delete-distribution \
    --id E1234567890ABC \
    --if-match ETAG-VALUE

# Delete certificate
aws acm delete-certificate \
    --certificate-arn your-cert-arn

# Remove security group rules
aws ec2 revoke-security-group-ingress \
    --group-id sg-0123456789abcdef0 \
    --source-prefix-list-id com.amazonaws.global.cloudfront.origin-facing \
    --protocol tcp \
    --port 80
```

## Security Best Practices

1. **Custom Headers**: Always use the generated custom header
2. **WAF Integration**: Consider adding AWS WAF for additional protection
3. **Monitoring**: Enable CloudWatch alarms for unusual traffic patterns
4. **Regular Updates**: Monitor AWS IP range updates
5. **Access Logs**: Enable and monitor CloudFront access logs

## Support

For issues with this setup:
1. Check AWS CloudFormation events
2. Review CloudFront distribution settings
3. Verify security group configurations
4. Contact your AWS support team

## Files Generated

After successful execution, you'll have:
- `certificate_arn.txt` - SSL certificate ARN
- `distribution_id.txt` - CloudFront distribution ID
- `distribution_domain.txt` - CloudFront domain name
- `alb-security-config.txt` - Application configuration guide
- `dns_validation.txt` - DNS validation records

## Copyright

- Author: **DevOps Engineer (devops@xapiens.id)**
- Vendor: **Xapiens Teknologi Indonesia (xapiens.id)**
- License: **Apache v2**
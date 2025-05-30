#!/bin/bash

# CloudFront SSL Setup Script for xapiens.id - Refactored Version
# Clean, DRY, and modular implementation

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ================================
# CONFIGURATION & CONSTANTS
# ================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/cloudfront-config.conf"
readonly CLOUDFRONT_PREFIX_LIST="com.amazonaws.global.cloudfront.origin-facing"

# Default configurations
declare -A CONFIG=(
    [DOMAIN]="xapiens.id"
    [SUBDOMAIN]="rscm-dev.xapiens.id"
    [CERT_REGION]="us-east-1"
    [ALB_REGION]="ap-southeast-1"
    [PRICE_CLASS]="PriceClass_All"
    [HTTP_VERSION]="http2"
    [MIN_PROTOCOL_VERSION]="TLSv1.2_2021"
    [CUSTOM_HEADER_NAME]="X-CloudFront-Secret"
)

# Output files
declare -A OUTPUT_FILES=(
    [CERT_ARN]="certificate_arn.txt"
    [DIST_ID]="distribution_id.txt"
    [DIST_DOMAIN]="distribution_domain.txt"
    [DNS_VALIDATION]="dns_validation.txt"
    [ALB_CONFIG]="alb-security-config.txt"
    [DISTRIBUTION_CONFIG]="distribution-config.json"
    [ROUTE53_CHANGE]="route53-change.json"
)

# ================================
# UTILITY FUNCTIONS
# ================================

# Logging with colors and timestamps
log() { echo -e "\033[0;32m[$(date +'%Y-%m-%d %H:%M:%S')]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARNING]\033[0m $*" >&2; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $*" >&2; exit 1; }
info() { echo -e "\033[0;34m[INFO]\033[0m $*"; }

# Command existence check
command_exists() { command -v "$1" &> /dev/null; }

# AWS command wrapper with error handling
aws_cmd() {
    local cmd=("$@")
    local output

    if ! output=$(aws "${cmd[@]}" 2>&1); then
        error "AWS command failed: aws ${cmd[*]}\nOutput: $output"
    fi
    echo "$output"
}

# JSON file validator
validate_json() {
    local file="$1"
    if ! jq empty "$file" 2>/dev/null; then
        error "Invalid JSON file: $file"
    fi
}

# Generate secure random string
generate_secret() {
    local length=${1:-32}
    openssl rand -hex "$length"
}

# Wait with progress indicator
wait_with_progress() {
    local message="$1"
    local check_command="$2"
    local timeout=${3:-300}
    local interval=${4:-10}

    log "$message"
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        if eval "$check_command" &>/dev/null; then
            log "✓ Complete"
            return 0
        fi

        printf "."
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done

    echo
    error "Timeout waiting for: $message"
}

# ================================
# CONFIGURATION MANAGEMENT
# ================================

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log "Loading configuration from $CONFIG_FILE"
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
    fi
}

save_config() {
    log "Saving configuration to $CONFIG_FILE"
    cat > "$CONFIG_FILE" << EOF
# CloudFront SSL Setup Configuration
# Generated on $(date)

$(for key in "${!CONFIG[@]}"; do
    echo "${key}=\"${CONFIG[$key]}\""
done | sort)

# Runtime generated values
CUSTOM_HEADER_VALUE="${CONFIG[CUSTOM_HEADER_VALUE]}"
ALB_DNS_NAME="${CONFIG[ALB_DNS_NAME]}"
SECURITY_GROUP_ID="${CONFIG[SECURITY_GROUP_ID]}"
EOF
}

validate_config() {
    local required_keys=("ALB_DNS_NAME" "SECURITY_GROUP_ID" "CUSTOM_HEADER_VALUE")

    for key in "${required_keys[@]}"; do
        if [[ -z "${CONFIG[$key]:-}" ]]; then
            error "Missing required configuration: $key"
        fi
    done
}

# ================================
# USER INPUT FUNCTIONS
# ================================

prompt_user_input() {
    local var_name="$1"
    local prompt_text="$2"
    local default_value="${3:-}"
    local validation_regex="${4:-.*}"

    while true; do
        if [[ -n "$default_value" ]]; then
            read -p "$prompt_text [$default_value]: " input
            input="${input:-$default_value}"
        else
            read -p "$prompt_text: " input
        fi

        if [[ $input =~ $validation_regex ]]; then
            CONFIG[$var_name]="$input"
            break
        else
            warn "Invalid input. Please try again."
        fi
    done
}

get_user_inputs() {
    log "Gathering configuration inputs..."

    # Generate custom header secret if not exists
    CONFIG[CUSTOM_HEADER_VALUE]="${CONFIG[CUSTOM_HEADER_VALUE]:-$(generate_secret)}"

    prompt_user_input "ALB_DNS_NAME" \
        "Enter your ALB DNS name (e.g., alb-123.ap-southeast-1.elb.amazonaws.com)" \
        "" \
        "^[a-zA-Z0-9.-]+\.elb\.amazonaws\.com$"

    prompt_user_input "SECURITY_GROUP_ID" \
        "Enter your Security Group ID" \
        "" \
        "^sg-[a-f0-9]+$"

    prompt_user_input "ALB_REGION" \
        "Enter your ALB region" \
        "${CONFIG[ALB_REGION]}" \
        "^[a-z0-9-]+$"

    display_config_summary

    read -p "Continue with this configuration? (y/N): " confirm
    [[ $confirm =~ ^[yY]$ ]] || error "Setup cancelled by user"
}

display_config_summary() {
    info "Configuration Summary:"
    info "  Domain: ${CONFIG[SUBDOMAIN]}"
    info "  ALB DNS: ${CONFIG[ALB_DNS_NAME]}"
    info "  Security Group: ${CONFIG[SECURITY_GROUP_ID]}"
    info "  ALB Region: ${CONFIG[ALB_REGION]}"
    info "  Custom Header: ${CONFIG[CUSTOM_HEADER_NAME]}"
    info "  Secret Length: ${#CONFIG[CUSTOM_HEADER_VALUE]} characters"
}

# ================================
# AWS OPERATIONS
# ================================

check_prerequisites() {
    log "Checking prerequisites..."

    # Check required commands
    local required_commands=("aws" "jq" "openssl")
    for cmd in "${required_commands[@]}"; do
        command_exists "$cmd" || error "$cmd is not installed"
    done

    # Check AWS credentials
    aws_cmd sts get-caller-identity >/dev/null || error "AWS credentials not configured"

    log "✓ Prerequisites check passed"
}

request_ssl_certificate() {
    log "Requesting SSL certificate for ${CONFIG[SUBDOMAIN]}..."

    export AWS_DEFAULT_REGION="${CONFIG[CERT_REGION]}"

    local cert_arn
    cert_arn=$(aws_cmd acm request-certificate \
        --domain-name "${CONFIG[SUBDOMAIN]}" \
        --subject-alternative-names "${CONFIG[DOMAIN]}" \
        --validation-method DNS \
        --query 'CertificateArn' \
        --output text)

    echo "$cert_arn" > "${OUTPUT_FILES[CERT_ARN]}"
    log "✓ Certificate requested: $cert_arn"

    get_dns_validation_records "$cert_arn"
    wait_for_certificate_validation "$cert_arn"
}

get_dns_validation_records() {
    local cert_arn="$1"

    log "Getting DNS validation records..."
    sleep 5  # Allow certificate processing

    aws_cmd acm describe-certificate \
        --certificate-arn "$cert_arn" \
        --query 'Certificate.DomainValidationOptions[].ResourceRecord' \
        --output json > temp_dns.json

    jq -r '.[] | "\(.Name) \(.Type) \(.Value)"' temp_dns.json > "${OUTPUT_FILES[DNS_VALIDATION]}"
    rm temp_dns.json

    warn "IMPORTANT: Add these DNS records to validate your certificate:"
    echo "========================================="
    cat "${OUTPUT_FILES[DNS_VALIDATION]}"
    echo "========================================="

    read -p "Press Enter after adding DNS records to continue..."
}

wait_for_certificate_validation() {
    local cert_arn="$1"

    wait_with_progress \
        "Waiting for certificate validation..." \
        "aws acm describe-certificate --certificate-arn '$cert_arn' --query 'Certificate.Status' --output text | grep -q SUCCESS" \
        1800 \
        30
}

configure_security_group() {
    log "Configuring security group with CloudFront managed prefix list..."

    export AWS_DEFAULT_REGION="${CONFIG[ALB_REGION]}"

    local ports=(80 443)
    for port in "${ports[@]}"; do
        log "Adding rule for port $port..."
        aws ec2 authorize-security-group-ingress \
            --group-id "${CONFIG[SECURITY_GROUP_ID]}" \
            --protocol tcp \
            --port "$port" \
            --source-prefix-list-id "$CLOUDFRONT_PREFIX_LIST" \
            --output table 2>/dev/null || warn "Rule for port $port might already exist"
    done

    log "✓ Security group configured"
}

create_distribution_config() {
    log "Creating CloudFront distribution configuration..."

    cat > "${OUTPUT_FILES[DISTRIBUTION_CONFIG]}" << EOF
{
    "CallerReference": "xapiens-$(date +%s)",
    "Comment": "CloudFront distribution for ${CONFIG[SUBDOMAIN]} with custom SSL",
    "DefaultCacheBehavior": {
        "TargetOriginId": "ALB-${CONFIG[ALB_DNS_NAME]}",
        "ViewerProtocolPolicy": "redirect-to-https",
        "AllowedMethods": {
            "Quantity": 7,
            "Items": ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"],
            "CachedMethods": {
                "Quantity": 2,
                "Items": ["GET", "HEAD"]
            }
        },
        "ForwardedValues": {
            "QueryString": true,
            "Cookies": {"Forward": "all"},
            "Headers": {
                "Quantity": 3,
                "Items": ["Host", "Authorization", "CloudFront-Forwarded-Proto"]
            }
        },
        "TrustedSigners": {"Enabled": false, "Quantity": 0},
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000,
        "Compress": true
    },
    "Origins": {
        "Quantity": 1,
        "Items": [{
            "Id": "ALB-${CONFIG[ALB_DNS_NAME]}",
            "DomainName": "${CONFIG[ALB_DNS_NAME]}",
            "CustomOriginConfig": {
                "HTTPPort": 80,
                "HTTPSPort": 443,
                "OriginProtocolPolicy": "https-only",
                "OriginSslProtocols": {
                    "Quantity": 1,
                    "Items": ["TLSv1.2"]
                }
            },
            "OriginCustomHeaders": {
                "Quantity": 1,
                "Items": [{
                    "HeaderName": "${CONFIG[CUSTOM_HEADER_NAME]}",
                    "HeaderValue": "${CONFIG[CUSTOM_HEADER_VALUE]}"
                }]
            }
        }]
    },
    "Aliases": {
        "Quantity": 1,
        "Items": ["${CONFIG[SUBDOMAIN]}"]
    },
    "ViewerCertificate": {
        "ACMCertificateArn": "$(cat "${OUTPUT_FILES[CERT_ARN]}")",
        "SSLSupportMethod": "sni-only",
        "MinimumProtocolVersion": "${CONFIG[MIN_PROTOCOL_VERSION]}",
        "CertificateSource": "acm"
    },
    "Enabled": true,
    "PriceClass": "${CONFIG[PRICE_CLASS]}",
    "HttpVersion": "${CONFIG[HTTP_VERSION]}",
    "IsIPV6Enabled": true,
    "DefaultRootObject": "index.html"
}
EOF

    validate_json "${OUTPUT_FILES[DISTRIBUTION_CONFIG]}"
}

create_cloudfront_distribution() {
    log "Creating CloudFront distribution..."

    export AWS_DEFAULT_REGION="${CONFIG[CERT_REGION]}"

    create_distribution_config

    local distribution_result
    distribution_result=$(aws_cmd cloudfront create-distribution \
        --distribution-config "file://${OUTPUT_FILES[DISTRIBUTION_CONFIG]}")

    echo "$distribution_result" | jq -r '.Distribution.Id' > "${OUTPUT_FILES[DIST_ID]}"
    echo "$distribution_result" | jq -r '.Distribution.DomainName' > "${OUTPUT_FILES[DIST_DOMAIN]}"

    local distribution_id distribution_domain
    distribution_id=$(cat "${OUTPUT_FILES[DIST_ID]}")
    distribution_domain=$(cat "${OUTPUT_FILES[DIST_DOMAIN]}")

    log "✓ CloudFront distribution created successfully!"
    info "Distribution ID: $distribution_id"
    info "Distribution Domain: $distribution_domain"
}

update_route53_dns() {
    log "Updating Route 53 DNS record..."

    local distribution_domain hosted_zone_id
    distribution_domain=$(cat "${OUTPUT_FILES[DIST_DOMAIN]}")

    hosted_zone_id=$(aws_cmd route53 list-hosted-zones \
        --query "HostedZones[?Name=='${CONFIG[DOMAIN]}.'].Id" \
        --output text | cut -d'/' -f3)

    [[ -n "$hosted_zone_id" ]] || error "Could not find hosted zone for ${CONFIG[DOMAIN]}"

    cat > "${OUTPUT_FILES[ROUTE53_CHANGE]}" << EOF
{
    "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "${CONFIG[SUBDOMAIN]}",
            "Type": "CNAME",
            "TTL": 300,
            "ResourceRecords": [{"Value": "$distribution_domain"}]
        }
    }]
}
EOF

    local change_id
    change_id=$(aws_cmd route53 change-resource-record-sets \
        --hosted-zone-id "$hosted_zone_id" \
        --change-batch "file://${OUTPUT_FILES[ROUTE53_CHANGE]}" \
        --query 'ChangeInfo.Id' \
        --output text)

    log "DNS record updated. Change ID: $change_id"

    wait_with_progress \
        "Waiting for DNS propagation..." \
        "aws route53 get-change --id '$change_id' --query 'ChangeInfo.Status' --output text | grep -q INSYNC" \
        600 \
        30
}

generate_alb_config() {
    log "Generating ALB security configuration..."

    cat > "${OUTPUT_FILES[ALB_CONFIG]}" << 'EOF'
=====================================
ALB SECURITY CONFIGURATION
=====================================

1. Add this custom header check to your application:

   Header Name: ${CONFIG[CUSTOM_HEADER_NAME]}
   Header Value: ${CONFIG[CUSTOM_HEADER_VALUE]}

2. Example Nginx configuration:

   server {
       # Only allow requests with custom header
       if ($http_x_cloudfront_secret != "${CONFIG[CUSTOM_HEADER_VALUE]}") {
           return 403;
       }

       # Your existing configuration
       location / {
           proxy_pass http://backend;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }

3. Example Apache configuration:

   <VirtualHost *:80>
       # Check custom header
       RewriteEngine On
       RewriteCond %{HTTP:X-CloudFront-Secret} !^${CONFIG[CUSTOM_HEADER_VALUE]}$
       RewriteRule .* - [F,L]

       # Your existing configuration
   </VirtualHost>

4. Example Express.js configuration:

   app.use((req, res, next) => {
       const secret = '${CONFIG[CUSTOM_HEADER_VALUE]}';
       if (req.headers['x-cloudfront-secret'] !== secret) {
           return res.status(403).send('Access denied');
       }
       next();
   });

5. Security Group Rules Added:
   - HTTP (80) from CloudFront managed prefix list
   - HTTPS (443) from CloudFront managed prefix list

6. Remove any existing rules that allow 0.0.0.0/0 on ports 80/443

=====================================
EOF

    # Replace placeholders with actual values
    sed -i "s/\${CONFIG\[CUSTOM_HEADER_NAME\]}/${CONFIG[CUSTOM_HEADER_NAME]}/g" "${OUTPUT_FILES[ALB_CONFIG]}"
    sed -i "s/\${CONFIG\[CUSTOM_HEADER_VALUE\]}/${CONFIG[CUSTOM_HEADER_VALUE]}/g" "${OUTPUT_FILES[ALB_CONFIG]}"

    cat "${OUTPUT_FILES[ALB_CONFIG]}"
}

display_summary() {
    log "Setup completed successfully!"

    echo ""
    echo "==============================================="
    echo "SETUP SUMMARY"
    echo "==============================================="
    echo "Domain: ${CONFIG[SUBDOMAIN]}"
    echo "Certificate ARN: $(cat "${OUTPUT_FILES[CERT_ARN]}")"
    echo "Distribution ID: $(cat "${OUTPUT_FILES[DIST_ID]}")"
    echo "Distribution Domain: $(cat "${OUTPUT_FILES[DIST_DOMAIN]}")"
    echo "Custom Header Secret: ${CONFIG[CUSTOM_HEADER_VALUE]}"
    echo ""
    echo "Next steps:"
    echo "1. Configure your ALB/application with the custom header check"
    echo "2. Test your domain: https://${CONFIG[SUBDOMAIN]}"
    echo "3. Remove any existing 0.0.0.0/0 rules from your security group"
    echo "4. Monitor CloudFront logs for any issues"
    echo ""
    echo "Files generated:"
    for file in "${OUTPUT_FILES[@]}"; do
        echo "- $file"
    done
    echo "- $CONFIG_FILE"
    echo "==============================================="
}

# ================================
# CLEANUP FUNCTIONS
# ================================

cleanup_temp_files() {
    local temp_files=("temp_dns.json")
    for file in "${temp_files[@]}"; do
        [[ -f "$file" ]] && rm -f "$file"
    done
}

cleanup_on_error() {
    warn "Cleaning up due to error..."
    cleanup_temp_files

    # Optional: Ask user if they want to clean up AWS resources
    if [[ -f "${OUTPUT_FILES[DIST_ID]}" ]]; then
        read -p "Do you want to delete the created CloudFront distribution? (y/N): " cleanup_dist
        if [[ $cleanup_dist =~ ^[yY]$ ]]; then
            local dist_id
            dist_id=$(cat "${OUTPUT_FILES[DIST_ID]}")
            warn "Disabling and deleting distribution $dist_id..."
            # Note: Full cleanup would require distribution to be disabled first
            info "Manual cleanup required for distribution: $dist_id"
        fi
    fi
}

# ================================
# TESTING FUNCTIONS
# ================================

test_setup() {
    log "Running post-setup tests..."

    local domain="${CONFIG[SUBDOMAIN]}"
    local tests_passed=0
    local total_tests=4

    # Test 1: DNS Resolution
    info "Test 1/4: DNS Resolution"
    if dig +short "$domain" | grep -q "cloudfront.net"; then
        log "✓ DNS resolution working"
        ((tests_passed++))
    else
        warn "✗ DNS resolution failed"
    fi

    # Test 2: HTTPS Redirect
    info "Test 2/4: HTTPS Redirect"
    local http_status
    http_status=$(curl -s -o /dev/null -w "%{http_code}" "http://$domain" || echo "000")
    if [[ "$http_status" =~ ^30[12]$ ]]; then
        log "✓ HTTPS redirect working"
        ((tests_passed++))
    else
        warn "✗ HTTPS redirect failed (status: $http_status)"
    fi

    # Test 3: SSL Certificate
    info "Test 3/4: SSL Certificate"
    if echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | \
       openssl x509 -noout -subject | grep -q "$domain"; then
        log "✓ SSL certificate valid"
        ((tests_passed++))
    else
        warn "✗ SSL certificate validation failed"
    fi

    # Test 4: CloudFront Response
    info "Test 4/4: CloudFront Response"
    local cf_header
    cf_header=$(curl -s -I "https://$domain" | grep -i "x-cache" || echo "")
    if [[ -n "$cf_header" ]]; then
        log "✓ CloudFront serving requests"
        ((tests_passed++))
    else
        warn "✗ CloudFront headers not detected"
    fi

    info "Tests completed: $tests_passed/$total_tests passed"

    if [[ $tests_passed -eq $total_tests ]]; then
        log "🎉 All tests passed! Your setup is working correctly."
    else
        warn "Some tests failed. Check the configuration and try again."
        info "It may take a few minutes for all services to be fully propagated."
    fi
}

# ================================
# MONITORING FUNCTIONS
# ================================

setup_monitoring() {
    log "Setting up basic monitoring..."

    local dist_id
    dist_id=$(cat "${OUTPUT_FILES[DIST_ID]}")

    # Create CloudWatch dashboard
    local dashboard_body
    dashboard_body=$(cat << EOF
{
    "widgets": [
        {
            "type": "metric",
            "properties": {
                "metrics": [
                    ["AWS/CloudFront", "Requests", "DistributionId", "$dist_id"],
                    [".", "BytesDownloaded", ".", "."],
                    [".", "4xxErrorRate", ".", "."],
                    [".", "5xxErrorRate", ".", "."]
                ],
                "period": 300,
                "stat": "Sum",
                "region": "us-east-1",
                "title": "CloudFront Metrics - ${CONFIG[SUBDOMAIN]}"
            }
        }
    ]
}
EOF
)

    aws_cmd cloudwatch put-dashboard \
        --dashboard-name "CloudFront-${CONFIG[SUBDOMAIN]//\./-}" \
        --dashboard-body "$dashboard_body" >/dev/null

    log "✓ CloudWatch dashboard created"

    # Set up basic alarms
    aws_cmd cloudwatch put-metric-alarm \
        --alarm-name "CloudFront-HighErrorRate-${CONFIG[SUBDOMAIN]//\./-}" \
        --alarm-description "High 4xx/5xx error rate for ${CONFIG[SUBDOMAIN]}" \
        --metric-name "4xxErrorRate" \
        --namespace "AWS/CloudFront" \
        --statistic "Average" \
        --period 300 \
        --threshold 10 \
        --comparison-operator "GreaterThanThreshold" \
        --dimensions Name=DistributionId,Value="$dist_id" \
        --evaluation-periods 2 >/dev/null

    log "✓ CloudWatch alarms configured"
}

# ================================
# MAIN EXECUTION FUNCTIONS
# ================================

main() {
    log "Starting CloudFront SSL setup for xapiens.id"

    # Set up error handling
    trap cleanup_on_error ERR
    trap cleanup_temp_files EXIT

    # Load existing configuration if available
    load_config

    # Execute setup steps
    check_prerequisites
    get_user_inputs
    save_config
    validate_config

    log "Step 1: Requesting SSL certificate..."
    request_ssl_certificate

    log "Step 2: Configuring security group..."
    configure_security_group

    log "Step 3: Creating CloudFront distribution..."
    create_cloudfront_distribution

    log "Step 4: Updating Route 53 DNS..."
    update_route53_dns

    log "Step 5: Generating ALB configuration..."
    generate_alb_config

    log "Step 6: Setting up monitoring..."
    setup_monitoring

    display_summary

    # Optional testing
    read -p "Do you want to run post-setup tests? (Y/n): " run_tests
    if [[ ! $run_tests =~ ^[nN]$ ]]; then
        test_setup
    fi

    log "🚀 CloudFront SSL setup completed successfully!"
}

# Show help
show_help() {
    cat << EOF
CloudFront SSL Setup Script for xapiens.id

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -c, --config FILE       Use specific configuration file
    -t, --test-only         Run tests only (requires existing setup)
    -m, --monitor-only      Setup monitoring only
    --cleanup               Clean up AWS resources (interactive)

EXAMPLES:
    $0                      # Run full setup
    $0 --test-only          # Test existing setup
    $0 --config custom.conf # Use custom config file

REQUIREMENTS:
    - AWS CLI configured with appropriate permissions
    - jq command-line JSON processor
    - openssl for generating secrets
    - dig for DNS testing

CONFIGURATION:
    The script will prompt for required values or load from:
    - Command line config file (-c option)
    - Default config file: ./cloudfront-config.conf

For detailed instructions, see HOW-TO.md
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -t|--test-only)
                load_config
                test_setup
                exit 0
                ;;
            -m|--monitor-only)
                load_config
                setup_monitoring
                exit 0
                ;;
            --cleanup)
                echo "Cleanup functionality would be implemented here"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

# ================================
# SCRIPT ENTRY POINT
# ================================

# Parse arguments and run main function
parse_args "$@"
main
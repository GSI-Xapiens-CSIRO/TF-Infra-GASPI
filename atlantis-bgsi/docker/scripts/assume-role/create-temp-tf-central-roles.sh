#!/bin/bash

################################################################################
# AWS Temporary TF Central Role Creator
# Version: 1.0.0
# Purpose: Create Temp-TF-Central-Role with Administrator access across accounts
# Author: DevOps Team - GSI Xapiens CSIRO
# Date: 2025-01-20
################################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create log directory
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/create-temp-roles-$(date +%Y%m%d_%H%M%S).log"

# Redirect all output to log file as well
exec > >(tee -a "$LOG_FILE")
exec 2>&1

################################################################################
# Account Configuration
################################################################################

# Production Accounts
declare -A PROD_ACCOUNTS=(
    ["RSCM"]="442799077487"
    ["RSPON"]="829990487185"
    ["SARDJITO"]="938674806253"
    ["RSNGOERAH"]="136839993415"
    ["RSJPD"]="602006056899"
)

# UAT Accounts
declare -A UAT_ACCOUNTS=(
    ["RSCM-UAT"]="695094375681"
    ["RSPON-UAT"]="741464515101"
    ["SARDJITO-UAT"]="819520291687"
    ["RSNGOERAH-UAT"]="899630542732"
    ["RSJPD-UAT"]="148450585096"
)

# AWS Region
AWS_REGION="ap-southeast-3"

################################################################################
# IAM Policy Documents
################################################################################

create_trust_policy() {
    local account_id=$1
    cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

################################################################################
# Role Creation Function
################################################################################

create_temp_role() {
    local profile=$1
    local account_name=$2
    local account_id=$3
    local environment=$4

    log_info "=================================================="
    log_info "Processing: $account_name ($account_id) - $environment"
    log_info "=================================================="

    # Role name following the pattern
    local role_name="Temp-TF-Central-Role_${account_id}"

    # Verify AWS credentials work
    log_info "Verifying AWS credentials for profile: $profile"
    if ! aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
        log_error "Failed to authenticate with profile: $profile"
        log_error "Please check your credentials in ~/.aws/credentials"
        return 1
    fi

    local caller_identity=$(aws sts get-caller-identity --profile "$profile" --output json)
    local current_account=$(echo "$caller_identity" | jq -r '.Account')
    log_success "Authenticated as: $(echo "$caller_identity" | jq -r '.Arn')"
    log_info "Current Account: $current_account"

    # Create trust policy file
    local trust_policy_file="$LOG_DIR/trust-policy-${account_id}.json"
    create_trust_policy "$account_id" > "$trust_policy_file"
    log_info "Created trust policy: $trust_policy_file"

    # Check if role already exists
    log_info "Checking if role '$role_name' already exists..."
    if aws iam get-role --role-name "$role_name" --profile "$profile" >/dev/null 2>&1; then
        log_warning "Role '$role_name' already exists in account $account_id"

        # Ask user if they want to update
        read -p "Do you want to update the existing role? (yes/no): " response
        if [[ "$response" != "yes" ]]; then
            log_info "Skipping role update for $account_name"
            return 0
        fi

        log_info "Updating existing role..."

        # Update trust policy
        if aws iam update-assume-role-policy \
            --role-name "$role_name" \
            --policy-document "file://$trust_policy_file" \
            --profile "$profile" 2>&1; then
            log_success "Updated trust policy for role '$role_name'"
        else
            log_error "Failed to update trust policy"
            return 1
        fi

    else
        # Create new role
        log_info "Creating IAM role: $role_name"
        if aws iam create-role \
            --role-name "$role_name" \
            --assume-role-policy-document "file://$trust_policy_file" \
            --description "Temporary Terraform Central Role for account ${account_id} - ${account_name}" \
            --max-session-duration 43200 \
            --profile "$profile" 2>&1; then
            log_success "Created role: $role_name"
        else
            log_error "Failed to create role"
            return 1
        fi

        # Wait for role to be available
        log_info "Waiting for role to be available..."
        sleep 5
    fi

    # Attach AdministratorAccess policy
    log_info "Attaching AdministratorAccess managed policy..."
    if aws iam attach-role-policy \
        --role-name "$role_name" \
        --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess" \
        --profile "$profile" 2>&1; then
        log_success "Attached AdministratorAccess policy to $role_name"
    else
        log_warning "Policy may already be attached or failed to attach"
    fi

    # Add tags
    log_info "Adding tags to role..."
    aws iam tag-role \
        --role-name "$role_name" \
        --tags \
            Key=Environment,Value="$environment" \
            Key=Purpose,Value="Terraform-Automation" \
            Key=ManagedBy,Value="DevOps-Team" \
            Key=Hospital,Value="$account_name" \
            Key=CreatedDate,Value="$(date +%Y-%m-%d)" \
        --profile "$profile" 2>&1 || log_warning "Failed to add tags (non-critical)"

    # Verify role creation
    log_info "Verifying role creation..."
    if aws iam get-role --role-name "$role_name" --profile "$profile" >/dev/null 2>&1; then
        local role_arn=$(aws iam get-role --role-name "$role_name" --profile "$profile" --query 'Role.Arn' --output text)
        log_success "✓ Role verified: $role_arn"

        # Test assume role
        log_info "Testing role assumption..."
        if aws sts assume-role \
            --role-arn "$role_arn" \
            --role-session-name "test-session" \
            --profile "$profile" \
            --duration-seconds 900 >/dev/null 2>&1; then
            log_success "✓ Role assumption test successful"
        else
            log_warning "Role assumption test failed (may need time to propagate)"
        fi
    else
        log_error "Failed to verify role creation"
        return 1
    fi

    log_success "=================================================="
    log_success "Completed: $account_name"
    log_success "Role ARN: arn:aws:iam::${account_id}:role/${role_name}"
    log_success "=================================================="
    echo ""

    return 0
}

################################################################################
# Main Execution
################################################################################

main() {
    log_info "╔══════════════════════════════════════════════════════════════╗"
    log_info "║   AWS Temporary TF Central Role Creator                     ║"
    log_info "║   Version 1.0.0                                              ║"
    log_info "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    log_info "Region: $AWS_REGION"
    log_info "Log file: $LOG_FILE"
    echo ""

    # Summary
    local total_accounts=$((${#PROD_ACCOUNTS[@]} + ${#UAT_ACCOUNTS[@]}))
    log_info "Total accounts to process: $total_accounts"
    log_info "  - Production: ${#PROD_ACCOUNTS[@]}"
    log_info "  - UAT: ${#UAT_ACCOUNTS[@]}"
    echo ""

    # Confirmation
    read -p "Do you want to proceed with role creation? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        log_warning "Operation cancelled by user"
        exit 0
    fi

    echo ""
    local success_count=0
    local failure_count=0
    declare -a failed_accounts

    # Process Production Accounts
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "PROCESSING PRODUCTION ACCOUNTS"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    for account_name in "${!PROD_ACCOUNTS[@]}"; do
        account_id="${PROD_ACCOUNTS[$account_name]}"
        profile="BGSI-TF-User-Executor-${account_name}"

        if create_temp_role "$profile" "$account_name" "$account_id" "Production"; then
            ((success_count++))
        else
            ((failure_count++))
            failed_accounts+=("$account_name (PROD)")
        fi

        sleep 2  # Brief pause between accounts
    done

    # Process UAT Accounts
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "PROCESSING UAT ACCOUNTS"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    for account_name in "${!UAT_ACCOUNTS[@]}"; do
        account_id="${UAT_ACCOUNTS[$account_name]}"
        profile="BGSI-TF-User-Executor-${account_name}"

        if create_temp_role "$profile" "$account_name" "$account_id" "UAT"; then
            ((success_count++))
        else
            ((failure_count++))
            failed_accounts+=("$account_name (UAT)")
        fi

        sleep 2  # Brief pause between accounts
    done

    # Final Summary
    echo ""
    log_info "╔══════════════════════════════════════════════════════════════╗"
    log_info "║                    EXECUTION SUMMARY                         ║"
    log_info "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    log_info "Total accounts processed: $total_accounts"
    log_success "Successful: $success_count"

    if [[ $failure_count -gt 0 ]]; then
        log_error "Failed: $failure_count"
        echo ""
        log_error "Failed accounts:"
        for failed in "${failed_accounts[@]}"; do
            log_error "  - $failed"
        done
    else
        log_success "All accounts processed successfully! ✓"
    fi

    echo ""
    log_info "Detailed logs saved to: $LOG_FILE"
    echo ""

    # Generate summary table
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "CREATED ROLES SUMMARY"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    printf "%-20s %-15s %-60s\n" "Account Name" "Account ID" "Role ARN"
    printf "%-20s %-15s %-60s\n" "────────────" "──────────" "────────"

    for account_name in "${!PROD_ACCOUNTS[@]}"; do
        account_id="${PROD_ACCOUNTS[$account_name]}"
        printf "%-20s %-15s %-60s\n" "$account_name" "$account_id" "arn:aws:iam::${account_id}:role/Temp-TF-Central-Role_${account_id}"
    done

    for account_name in "${!UAT_ACCOUNTS[@]}"; do
        account_id="${UAT_ACCOUNTS[$account_name]}"
        printf "%-20s %-15s %-60s\n" "$account_name" "$account_id" "arn:aws:iam::${account_id}:role/Temp-TF-Central-Role_${account_id}"
    done

    echo ""
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Run main function
main "$@"
#!/bin/bash

################################################################################
# AWS Temporary TF Central Role Verification Script
# Version: 1.0.0
# Purpose: Verify Temp-TF-Central-Role exists and has correct permissions
# Author: DevOps Team - GSI Xapiens CSIRO
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create log directory
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/verify-temp-roles-$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

# Account Configuration
declare -A PROD_ACCOUNTS=(
    ["RSCM"]="442799077487"
    ["RSPON"]="829990487185"
    ["SARDJITO"]="938674806253"
    ["RSNGOERAH"]="136839993415"
    ["RSJPD"]="602006056899"
)

declare -A UAT_ACCOUNTS=(
    ["RSCM-UAT"]="695094375681"
    ["RSPON-UAT"]="741464515101"
    ["SARDJITO-UAT"]="819520291687"
    ["RSNGOERAH-UAT"]="899630542732"
    ["RSJPD-UAT"]="148450585096"
)

AWS_REGION="ap-southeast-3"

################################################################################
# Verification Function
################################################################################

verify_role() {
    local profile=$1
    local account_name=$2
    local account_id=$3
    local environment=$4

    local role_name="Temp-TF-Central-Role_${account_id}"

    echo ""
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Verifying: $account_name ($account_id) - $environment"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check credentials
    if ! aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
        log_error "✗ Cannot authenticate with profile: $profile"
        return 1
    fi

    # Check if role exists
    log_info "Checking role existence..."
    if ! aws iam get-role --role-name "$role_name" --profile "$profile" >/dev/null 2>&1; then
        log_error "✗ Role '$role_name' does NOT exist"
        return 1
    fi
    log_success "✓ Role exists"

    # Get role details
    local role_info=$(aws iam get-role --role-name "$role_name" --profile "$profile" --output json)
    local role_arn=$(echo "$role_info" | jq -r '.Role.Arn')
    local create_date=$(echo "$role_info" | jq -r '.Role.CreateDate')
    local max_session=$(echo "$role_info" | jq -r '.Role.MaxSessionDuration')

    log_info "Role ARN: $role_arn"
    log_info "Created: $create_date"
    log_info "Max Session Duration: ${max_session}s ($(($max_session / 3600))h)"

    # Check AdministratorAccess policy
    log_info "Checking attached policies..."
    local attached_policies=$(aws iam list-attached-role-policies \
        --role-name "$role_name" \
        --profile "$profile" \
        --output json)

    if echo "$attached_policies" | jq -e '.AttachedPolicies[] | select(.PolicyName == "AdministratorAccess")' >/dev/null; then
        log_success "✓ AdministratorAccess policy is attached"
    else
        log_error "✗ AdministratorAccess policy is NOT attached"
        log_info "Attached policies:"
        echo "$attached_policies" | jq -r '.AttachedPolicies[].PolicyName' | while read policy; do
            log_info "  - $policy"
        done
        return 1
    fi

    # Check trust policy
    log_info "Checking trust policy..."
    local trust_policy=$(echo "$role_info" | jq -r '.Role.AssumeRolePolicyDocument')
    if echo "$trust_policy" | jq -e ".Statement[] | select(.Principal.AWS == \"arn:aws:iam::${account_id}:root\")" >/dev/null; then
        log_success "✓ Trust policy correctly configured"
    else
        log_warning "⚠ Trust policy may need review"
    fi

    # Test role assumption
    log_info "Testing role assumption..."
    if aws sts assume-role \
        --role-arn "$role_arn" \
        --role-session-name "verification-test" \
        --profile "$profile" \
        --duration-seconds 900 >/dev/null 2>&1; then
        log_success "✓ Role assumption test PASSED"
    else
        log_warning "⚠ Role assumption test failed (may need propagation time)"
    fi

    # Check tags
    log_info "Checking tags..."
    local tags=$(aws iam list-role-tags --role-name "$role_name" --profile "$profile" --output json 2>/dev/null || echo '{"Tags":[]}')
    local tag_count=$(echo "$tags" | jq '.Tags | length')
    if [[ $tag_count -gt 0 ]]; then
        log_success "✓ Tags present ($tag_count tags)"
        echo "$tags" | jq -r '.Tags[] | "  - \(.Key): \(.Value)"'
    else
        log_info "No tags found"
    fi

    log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "Verification PASSED for $account_name"
    log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    return 0
}

################################################################################
# Main Execution
################################################################################

main() {
    log_info "╔══════════════════════════════════════════════════════════════╗"
    log_info "║   AWS Temp TF Central Role Verification                     ║"
    log_info "║   Version 1.0.0                                              ║"
    log_info "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    local total_accounts=$((${#PROD_ACCOUNTS[@]} + ${#UAT_ACCOUNTS[@]}))
    local success_count=0
    local failure_count=0
    declare -a failed_accounts

    log_info "Total accounts to verify: $total_accounts"
    echo ""

    # Verify Production Accounts
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "VERIFYING PRODUCTION ACCOUNTS"
    log_info "═══════════════════════════════════════════════════════════════"

    for account_name in "${!PROD_ACCOUNTS[@]}"; do
        account_id="${PROD_ACCOUNTS[$account_name]}"
        profile="BGSI-TF-User-Executor-${account_name}"

        if verify_role "$profile" "$account_name" "$account_id" "Production"; then
            ((success_count++))
        else
            ((failure_count++))
            failed_accounts+=("$account_name (PROD)")
        fi
        sleep 1
    done

    # Verify UAT Accounts
    echo ""
    log_info "═══════════════════════════════════════════════════════════════"
    log_info "VERIFYING UAT ACCOUNTS"
    log_info "═══════════════════════════════════════════════════════════════"

    for account_name in "${!UAT_ACCOUNTS[@]}"; do
        account_id="${UAT_ACCOUNTS[$account_name]}"
        profile="BGSI-TF-User-Executor-${account_name}"

        if verify_role "$profile" "$account_name" "$account_id" "UAT"; then
            ((success_count++))
        else
            ((failure_count++))
            failed_accounts+=("$account_name (UAT)")
        fi
        sleep 1
    done

    # Final Summary
    echo ""
    log_info "╔══════════════════════════════════════════════════════════════╗"
    log_info "║                  VERIFICATION SUMMARY                        ║"
    log_info "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    log_info "Total accounts: $total_accounts"
    log_success "Passed: $success_count"

    if [[ $failure_count -gt 0 ]]; then
        log_error "Failed: $failure_count"
        echo ""
        log_error "Failed accounts:"
        for failed in "${failed_accounts[@]}"; do
            log_error "  - $failed"
        done
        echo ""
        exit 1
    else
        log_success "═══════════════════════════════════════════════════════════════"
        log_success "ALL VERIFICATIONS PASSED! ✓"
        log_success "═══════════════════════════════════════════════════════════════"
    fi

    echo ""
    log_info "Detailed logs saved to: $LOG_FILE"
    echo ""
}

main "$@"
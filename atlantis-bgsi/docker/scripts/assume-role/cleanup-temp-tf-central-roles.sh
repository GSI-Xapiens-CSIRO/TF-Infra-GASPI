#!/bin/bash

################################################################################
# AWS Temporary TF Central Role Cleanup Script
# Version: 1.0.0
# Purpose: Remove Temp-TF-Central-Role from all accounts
# Author: DevOps Team - GSI Xapiens CSIRO
#
# WARNING: This script will DELETE the Temp-TF-Central-Role roles!
#          Use with caution!
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
LOG_FILE="$LOG_DIR/cleanup-temp-roles-$(date +%Y%m%d_%H%M%S).log"
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
# Cleanup Function
################################################################################

cleanup_role() {
    local profile=$1
    local account_name=$2
    local account_id=$3
    local environment=$4

    local role_name="Temp-TF-Central-Role_${account_id}"

    log_info "=================================================="
    log_info "Cleaning: $account_name ($account_id) - $environment"
    log_info "=================================================="

    # Check credentials
    if ! aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
        log_error "Cannot authenticate with profile: $profile"
        return 1
    fi

    # Check if role exists
    log_info "Checking if role exists..."
    if ! aws iam get-role --role-name "$role_name" --profile "$profile" >/dev/null 2>&1; then
        log_warning "Role '$role_name' does not exist (already deleted?)"
        return 0
    fi

    log_info "Role exists, proceeding with cleanup..."

    # Detach all managed policies
    log_info "Detaching managed policies..."
    local attached_policies=$(aws iam list-attached-role-policies \
        --role-name "$role_name" \
        --profile "$profile" \
        --output json)

    local policy_count=$(echo "$attached_policies" | jq '.AttachedPolicies | length')
    log_info "Found $policy_count attached policies"

    echo "$attached_policies" | jq -r '.AttachedPolicies[].PolicyArn' | while read policy_arn; do
        log_info "  Detaching: $policy_arn"
        if aws iam detach-role-policy \
            --role-name "$role_name" \
            --policy-arn "$policy_arn" \
            --profile "$profile" 2>&1; then
            log_success "  ✓ Detached: $policy_arn"
        else
            log_error "  ✗ Failed to detach: $policy_arn"
        fi
    done

    # Delete all inline policies
    log_info "Checking for inline policies..."
    local inline_policies=$(aws iam list-role-policies \
        --role-name "$role_name" \
        --profile "$profile" \
        --output json)

    local inline_count=$(echo "$inline_policies" | jq '.PolicyNames | length')
    if [[ $inline_count -gt 0 ]]; then
        log_info "Found $inline_count inline policies"
        echo "$inline_policies" | jq -r '.PolicyNames[]' | while read policy_name; do
            log_info "  Deleting inline policy: $policy_name"
            if aws iam delete-role-policy \
                --role-name "$role_name" \
                --policy-name "$policy_name" \
                --profile "$profile" 2>&1; then
                log_success "  ✓ Deleted inline policy: $policy_name"
            else
                log_error "  ✗ Failed to delete inline policy: $policy_name"
            fi
        done
    else
        log_info "No inline policies found"
    fi

    # Wait a bit for detachment to complete
    log_info "Waiting for policy detachment to complete..."
    sleep 3

    # Delete the role
    log_info "Deleting role: $role_name"
    if aws iam delete-role \
        --role-name "$role_name" \
        --profile "$profile" 2>&1; then
        log_success "✓ Successfully deleted role: $role_name"
    else
        log_error "✗ Failed to delete role"
        return 1
    fi

    # Verify deletion
    log_info "Verifying role deletion..."
    sleep 2
    if aws iam get-role --role-name "$role_name" --profile "$profile" >/dev/null 2>&1; then
        log_error "✗ Role still exists after deletion attempt"
        return 1
    else
        log_success "✓ Role successfully removed from account"
    fi

    log_success "=================================================="
    log_success "Completed cleanup: $account_name"
    log_success "=================================================="
    echo ""

    return 0
}

################################################################################
# Main Execution
################################################################################

main() {
    log_error "╔══════════════════════════════════════════════════════════════╗"
    log_error "║          ⚠️  TEMPORARY ROLE CLEANUP SCRIPT  ⚠️               ║"
    log_error "║                      Version 1.0.0                           ║"
    log_error "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    log_warning "═══════════════════════════════════════════════════════════════"
    log_warning "                    ⚠️  WARNING ⚠️"
    log_warning "═══════════════════════════════════════════════════════════════"
    log_warning "This script will DELETE Temp-TF-Central-Role from ALL accounts!"
    log_warning ""
    log_warning "Accounts to be affected:"
    log_warning "  - PRODUCTION: ${#PROD_ACCOUNTS[@]} accounts"
    log_warning "  - UAT: ${#UAT_ACCOUNTS[@]} accounts"
    log_warning ""
    log_warning "Total: $((${#PROD_ACCOUNTS[@]} + ${#UAT_ACCOUNTS[@]})) accounts"
    log_warning "═══════════════════════════════════════════════════════════════"
    echo ""

    # First confirmation
    read -p "Are you ABSOLUTELY SURE you want to proceed? (type 'DELETE' to confirm): " confirm1
    if [[ "$confirm1" != "DELETE" ]]; then
        log_info "Cleanup cancelled by user"
        exit 0
    fi

    # Second confirmation
    echo ""
    log_warning "This action CANNOT be undone!"
    read -p "Type the number of accounts to confirm ($((${#PROD_ACCOUNTS[@]} + ${#UAT_ACCOUNTS[@]}))): " confirm2
    if [[ "$confirm2" != "$((${#PROD_ACCOUNTS[@]} + ${#UAT_ACCOUNTS[@]}))" ]]; then
        log_info "Cleanup cancelled by user"
        exit 0
    fi

    echo ""
    log_warning "Starting cleanup in 5 seconds... (Press Ctrl+C to cancel)"
    for i in {5..1}; do
        echo -n "$i... "
        sleep 1
    done
    echo ""
    echo ""

    local success_count=0
    local failure_count=0
    declare -a failed_accounts

    # Cleanup Production Accounts
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "CLEANING PRODUCTION ACCOUNTS"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    for account_name in "${!PROD_ACCOUNTS[@]}"; do
        account_id="${PROD_ACCOUNTS[$account_name]}"
        profile="BGSI-TF-User-Executor-${account_name}"

        if cleanup_role "$profile" "$account_name" "$account_id" "Production"; then
            ((success_count++))
        else
            ((failure_count++))
            failed_accounts+=("$account_name (PROD)")
        fi
        sleep 2
    done

    # Cleanup UAT Accounts
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "CLEANING UAT ACCOUNTS"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    for account_name in "${!UAT_ACCOUNTS[@]}"; do
        account_id="${UAT_ACCOUNTS[$account_name]}"
        profile="BGSI-TF-User-Executor-${account_name}"

        if cleanup_role "$profile" "$account_name" "$account_id" "UAT"; then
            ((success_count++))
        else
            ((failure_count++))
            failed_accounts+=("$account_name (UAT)")
        fi
        sleep 2
    done

    # Final Summary
    echo ""
    log_info "╔══════════════════════════════════════════════════════════════╗"
    log_info "║                    CLEANUP SUMMARY                           ║"
    log_info "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    log_info "Total accounts processed: $((${#PROD_ACCOUNTS[@]} + ${#UAT_ACCOUNTS[@]}))"
    log_success "Successfully cleaned: $success_count"

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
        log_success "ALL ROLES SUCCESSFULLY CLEANED! ✓"
        log_success "═══════════════════════════════════════════════════════════════"
    fi

    echo ""
    log_info "Detailed logs saved to: $LOG_FILE"
    echo ""
}

main "$@"
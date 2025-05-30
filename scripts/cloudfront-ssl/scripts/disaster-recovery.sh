#!/bin/bash

# Disaster Recovery Script for CloudFront SSL Setup
# Handles backup, restore, and emergency recovery operations

set -euo pipefail

# ================================
# CONFIGURATION & CONSTANTS
# ================================

readonly SCRIPT_NAME="disaster-recovery.sh"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Backup configuration
declare -A BACKUP_CONFIG=(
    [BACKUP_DIR]="$PROJECT_ROOT/backups"
    [RETENTION_DAYS]="30"
    [COMPRESSION]="true"
    [ENCRYPTION]="false"
    [REMOTE_BACKUP]="false"
    [S3_BUCKET]=""
    [MAX_PARALLEL_JOBS]="5"
)

# AWS resource types to backup/restore
declare -A AWS_RESOURCES=(
    [cloudfront]="CloudFront distributions"
    [acm]="SSL certificates"
    [route53]="DNS records"
    [security-groups]="Security group configurations"
    [iam]="IAM policies and roles"
)

# Colors for output
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [PURPLE]='\033[0;35m'
    [CYAN]='\033[0;36m'
    [NC]='\033[0m'
)

# ================================
# UTILITY FUNCTIONS
# ================================

log() { echo -e "${COLORS[GREEN]}[INFO]${COLORS[NC]} $*"; }
warn() { echo -e "${COLORS[YELLOW]}[WARN]${COLORS[NC]} $*"; }
error() { echo -e "${COLORS[RED]}[ERROR]${COLORS[NC]} $*" >&2; }
success() { echo -e "${COLORS[GREEN]}[SUCCESS]${COLORS[NC]} $*"; }
debug() { [[ "${DEBUG:-}" == "true" ]] && echo -e "${COLORS[CYAN]}[DEBUG]${COLORS[NC]} $*"; }

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Generate timestamp
timestamp() {
    date +"%Y%m%d_%H%M%S"
}

# Get ISO timestamp
iso_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Validate AWS credentials
validate_aws_credentials() {
    if ! aws sts get-caller-identity &>/dev/null; then
        error "AWS credentials not configured or invalid"
        log "Configure credentials with: aws configure"
        exit 1
    fi

    local account_id
    account_id=$(aws sts get-caller-identity --query Account --output text)
    log "Using AWS Account: $account_id"
}

# Create backup directory structure
create_backup_structure() {
    local backup_dir="$1"

    mkdir -p "$backup_dir"/{cloudfront,acm,route53,security-groups,iam,configs,logs}

    # Create backup metadata
    cat > "$backup_dir/backup-metadata.json" << EOF
{
    "backup_timestamp": "$(iso_timestamp)",
    "script_version": "$SCRIPT_VERSION",
    "aws_account": "$(aws sts get-caller-identity --query Account --output text)",
    "aws_region": "${AWS_DEFAULT_REGION:-us-east-1}",
    "backup_type": "full",
    "resources": $(printf '%s\n' "${!AWS_RESOURCES[@]}" | jq -R . | jq -s .)
}
EOF

    debug "Backup structure created: $backup_dir"
}

# ================================
# BACKUP FUNCTIONS
# ================================

# Backup CloudFront distributions
backup_cloudfront_distributions() {
    local backup_dir="$1"
    local cloudfront_dir="$backup_dir/cloudfront"

    log "Backing up CloudFront distributions..."

    # Get all distributions
    local distributions
    distributions=$(aws cloudfront list-distributions --query 'DistributionList.Items[].Id' --output text)

    if [[ -z "$distributions" ]]; then
        warn "No CloudFront distributions found"
        return 0
    fi

    local count=0
    for dist_id in $distributions; do
        log "Backing up distribution: $dist_id"

        # Get distribution configuration
        aws cloudfront get-distribution-config \
            --id "$dist_id" \
            --output json > "$cloudfront_dir/${dist_id}-config.json"

        # Get distribution info
        aws cloudfront get-distribution \
            --id "$dist_id" \
            --output json > "$cloudfront_dir/${dist_id}-info.json"

        # Get invalidations
        aws cloudfront list-invalidations \
            --distribution-id "$dist_id" \
            --output json > "$cloudfront_dir/${dist_id}-invalidations.json" || true

        # Get tags
        local dist_arn
        dist_arn=$(jq -r '.Distribution.ARN' "$cloudfront_dir/${dist_id}-info.json")
        aws cloudfront list-tags-for-resource \
            --resource "$dist_arn" \
            --output json > "$cloudfront_dir/${dist_id}-tags.json" || true

        ((count++))
    done

    # Create summary
    cat > "$cloudfront_dir/summary.json" << EOF
{
    "backup_timestamp": "$(iso_timestamp)",
    "total_distributions": $count,
    "distribution_ids": $(echo "$distributions" | tr ' ' '\n' | jq -R . | jq -s .)
}
EOF

    success "Backed up $count CloudFront distributions"
}

# Backup ACM certificates
backup_acm_certificates() {
    local backup_dir="$1"
    local acm_dir="$backup_dir/acm"

    log "Backing up ACM certificates..."

    # List certificates in us-east-1 (CloudFront requirement)
    local certificates
    certificates=$(aws acm list-certificates \
        --region us-east-1 \
        --query 'CertificateSummaryList[].CertificateArn' \
        --output text)

    if [[ -z "$certificates" ]]; then
        warn "No ACM certificates found in us-east-1"
        return 0
    fi

    local count=0
    for cert_arn in $certificates; do
        local cert_id
        cert_id=$(basename "$cert_arn")

        log "Backing up certificate: $cert_id"

        # Get certificate details
        aws acm describe-certificate \
            --certificate-arn "$cert_arn" \
            --region us-east-1 \
            --output json > "$acm_dir/${cert_id}-details.json"

        # Get certificate tags
        aws acm list-tags-for-certificate \
            --certificate-arn "$cert_arn" \
            --region us-east-1 \
            --output json > "$acm_dir/${cert_id}-tags.json" || true

        ((count++))
    done

    # Create summary
    cat > "$acm_dir/summary.json" << EOF
{
    "backup_timestamp": "$(iso_timestamp)",
    "total_certificates": $count,
    "certificate_arns": $(echo "$certificates" | tr ' ' '\n' | jq -R . | jq -s .)
}
EOF

    success "Backed up $count ACM certificates"
}

# Backup Route 53 records
backup_route53_records() {
    local backup_dir="$1"
    local route53_dir="$backup_dir/route53"

    log "Backing up Route 53 DNS records..."

    # Get hosted zones
    local hosted_zones
    hosted_zones=$(aws route53 list-hosted-zones \
        --query 'HostedZones[].[Id,Name]' \
        --output text)

    if [[ -z "$hosted_zones" ]]; then
        warn "No Route 53 hosted zones found"
        return 0
    fi

    local count=0
    while IFS=$'\t' read -r zone_id zone_name; do
        # Clean zone ID (remove /hostedzone/ prefix)
        zone_id=$(basename "$zone_id")
        # Clean zone name (remove trailing dot)
        zone_name="${zone_name%.}"

        log "Backing up hosted zone: $zone_name ($zone_id)"

        # Get hosted zone details
        aws route53 get-hosted-zone \
            --id "$zone_id" \
            --output json > "$route53_dir/${zone_name}-zone.json"

        # Get all records
        aws route53 list-resource-record-sets \
            --hosted-zone-id "$zone_id" \
            --output json > "$route53_dir/${zone_name}-records.json"

        # Get zone tags
        aws route53 list-tags-for-resource \
            --resource-type hostedzone \
            --resource-id "$zone_id" \
            --output json > "$route53_dir/${zone_name}-tags.json" || true

        ((count++))
    done <<< "$hosted_zones"

    # Create summary
    cat > "$route53_dir/summary.json" << EOF
{
    "backup_timestamp": "$(iso_timestamp)",
    "total_zones": $count,
    "zones": $(echo "$hosted_zones" | awk '{print $2}' | sed 's/\.$//' | jq -R . | jq -s .)
}
EOF

    success "Backed up $count Route 53 hosted zones"
}

# Backup security groups
backup_security_groups() {
    local backup_dir="$1"
    local sg_dir="$backup_dir/security-groups"
    local region="${AWS_DEFAULT_REGION:-us-east-1}"

    log "Backing up security groups in region: $region"

    # Get all security groups
    aws ec2 describe-security-groups \
        --region "$region" \
        --output json > "$sg_dir/all-security-groups.json"

    # Get CloudFront-related security groups
    aws ec2 describe-security-groups \
        --region "$region" \
        --filters "Name=ip-permission.prefix-list-id,Values=com.amazonaws.global.cloudfront.origin-facing" \
        --output json > "$sg_dir/cloudfront-security-groups.json" || true

    local count
    count=$(jq '.SecurityGroups | length' "$sg_dir/all-security-groups.json")

    # Create summary
    cat > "$sg_dir/summary.json" << EOF
{
    "backup_timestamp": "$(iso_timestamp)",
    "region": "$region",
    "total_security_groups": $count
}
EOF

    success "Backed up $count security groups from $region"
}

# Backup IAM resources
backup_iam_resources() {
    local backup_dir="$1"
    local iam_dir="$backup_dir/iam"

    log "Backing up IAM resources..."

    # Backup IAM policies (customer managed)
    aws iam list-policies \
        --scope Local \
        --output json > "$iam_dir/customer-managed-policies.json"

    # Backup IAM roles
    aws iam list-roles \
        --output json > "$iam_dir/roles.json"

    # Backup IAM users
    aws iam list-users \
        --output json > "$iam_dir/users.json"

    # Backup IAM groups
    aws iam list-groups \
        --output json > "$iam_dir/groups.json"

    # Get detailed policy documents for customer managed policies
    local policy_arns
    policy_arns=$(jq -r '.Policies[].Arn' "$iam_dir/customer-managed-policies.json")

    mkdir -p "$iam_dir/policy-documents"
    local policy_count=0

    while IFS= read -r policy_arn; do
        if [[ -n "$policy_arn" && "$policy_arn" != "null" ]]; then
            local policy_name
            policy_name=$(basename "$policy_arn")

            aws iam get-policy \
                --policy-arn "$policy_arn" \
                --output json > "$iam_dir/policy-documents/${policy_name}.json"

            aws iam get-policy-version \
                --policy-arn "$policy_arn" \
                --version-id v1 \
                --output json > "$iam_dir/policy-documents/${policy_name}-version.json"

            ((policy_count++))
        fi
    done <<< "$policy_arns"

    # Create summary
    local role_count user_count group_count
    role_count=$(jq '.Roles | length' "$iam_dir/roles.json")
    user_count=$(jq '.Users | length' "$iam_dir/users.json")
    group_count=$(jq '.Groups | length' "$iam_dir/groups.json")

    cat > "$iam_dir/summary.json" << EOF
{
    "backup_timestamp": "$(iso_timestamp)",
    "total_policies": $policy_count,
    "total_roles": $role_count,
    "total_users": $user_count,
    "total_groups": $group_count
}
EOF

    success "Backed up IAM resources: $policy_count policies, $role_count roles, $user_count users, $group_count groups"
}

# Backup configuration files
backup_configuration_files() {
    local backup_dir="$1"
    local config_dir="$backup_dir/configs"

    log "Backing up configuration files..."

    # Copy all configuration files
    find "$PROJECT_ROOT" -name "*.conf" -type f -exec cp {} "$config_dir/" \;
    find "$PROJECT_ROOT" -name "*.template" -type f -exec cp {} "$config_dir/" \;

    # Copy examples
    if [[ -d "$PROJECT_ROOT/examples" ]]; then
        cp -r "$PROJECT_ROOT/examples" "$config_dir/"
    fi

    # Copy generated files (if they exist)
    local generated_files=(
        "certificate_arn.txt"
        "distribution_id.txt"
        "distribution_domain.txt"
        "dns_validation.txt"
        "alb-security-config.txt"
    )

    for file in "${generated_files[@]}"; do
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            cp "$PROJECT_ROOT/$file" "$config_dir/"
        fi
    done

    # Create inventory
    find "$config_dir" -type f > "$config_dir/file-inventory.txt"
    local file_count
    file_count=$(wc -l < "$config_dir/file-inventory.txt")

    success "Backed up $file_count configuration files"
}

# Create full backup
create_full_backup() {
    local backup_name="${1:-backup_$(timestamp)}"
    local backup_dir="${BACKUP_CONFIG[BACKUP_DIR]}/$backup_name"

    log "Creating full backup: $backup_name"

    # Validate AWS credentials
    validate_aws_credentials

    # Create backup directory structure
    create_backup_structure "$backup_dir"

    # Backup all resources
    backup_cloudfront_distributions "$backup_dir"
    backup_acm_certificates "$backup_dir"
    backup_route53_records "$backup_dir"
    backup_security_groups "$backup_dir"
    backup_iam_resources "$backup_dir"
    backup_configuration_files "$backup_dir"

    # Create backup log
    cat > "$backup_dir/logs/backup.log" << EOF
Backup completed: $(iso_timestamp)
Script version: $SCRIPT_VERSION
AWS Account: $(aws sts get-caller-identity --query Account --output text)
AWS Region: ${AWS_DEFAULT_REGION:-us-east-1}
Backup directory: $backup_dir

Resources backed up:
$(for resource in "${!AWS_RESOURCES[@]}"; do echo "- $resource: ${AWS_RESOURCES[$resource]}"; done)
EOF

    # Compress backup if enabled
    if [[ "${BACKUP_CONFIG[COMPRESSION]}" == "true" ]]; then
        log "Compressing backup..."
        tar -czf "${backup_dir}.tar.gz" -C "${BACKUP_CONFIG[BACKUP_DIR]}" "$backup_name"
        rm -rf "$backup_dir"
        backup_dir="${backup_dir}.tar.gz"
    fi

    # Upload to S3 if configured
    if [[ "${BACKUP_CONFIG[REMOTE_BACKUP]}" == "true" && -n "${BACKUP_CONFIG[S3_BUCKET]}" ]]; then
        upload_backup_to_s3 "$backup_dir" "$backup_name"
    fi

    success "Backup completed: $backup_dir"

    # Cleanup old backups
    cleanup_old_backups
}

# Upload backup to S3
upload_backup_to_s3() {
    local backup_path="$1"
    local backup_name="$2"

    log "Uploading backup to S3: ${BACKUP_CONFIG[S3_BUCKET]}"

    local s3_key="cloudfront-ssl-setup-backups/$backup_name"

    if [[ -f "$backup_path" ]]; then
        # Single file (compressed)
        aws s3 cp "$backup_path" "s3://${BACKUP_CONFIG[S3_BUCKET]}/$s3_key"
    else
        # Directory
        aws s3 sync "$backup_path" "s3://${BACKUP_CONFIG[S3_BUCKET]}/$s3_key"
    fi

    success "Backup uploaded to S3: s3://${BACKUP_CONFIG[S3_BUCKET]}/$s3_key"
}

# ================================
# RESTORE FUNCTIONS
# ================================

# List available backups
list_backups() {
    local backup_base_dir="${BACKUP_CONFIG[BACKUP_DIR]}"

    if [[ ! -d "$backup_base_dir" ]]; then
        warn "No backup directory found: $backup_base_dir"
        return 0
    fi

    log "Available backups:"

    # List local backups
    local backups=()
    while IFS= read -r -d '' backup; do
        backups+=("$(basename "$backup")")
    done < <(find "$backup_base_dir" -maxdepth 1 -type d -name "backup_*" -print0 2>/dev/null)

    # Add compressed backups
    while IFS= read -r -d '' backup; do
        local backup_name
        backup_name=$(basename "$backup" .tar.gz)
        backups+=("$backup_name")
    done < <(find "$backup_base_dir" -maxdepth 1 -type f -name "backup_*.tar.gz" -print0 2>/dev/null)

    if [[ ${#backups[@]} -eq 0 ]]; then
        warn "No backups found"
        return 0
    fi

    # Sort and display backups
    printf '%s\n' "${backups[@]}" | sort -r | nl -w2 -s'. '
}

# Extract compressed backup
extract_backup() {
    local backup_name="$1"
    local backup_base_dir="${BACKUP_CONFIG[BACKUP_DIR]}"
    local compressed_backup="$backup_base_dir/${backup_name}.tar.gz"
    local extracted_dir="$backup_base_dir/$backup_name"

    if [[ -f "$compressed_backup" ]]; then
        log "Extracting compressed backup: $backup_name"
        tar -xzf "$compressed_backup" -C "$backup_base_dir"
        echo "$extracted_dir"
    elif [[ -d "$extracted_dir" ]]; then
        echo "$extracted_dir"
    else
        error "Backup not found: $backup_name"
        return 1
    fi
}

# Restore CloudFront distribution
restore_cloudfront_distribution() {
    local backup_dir="$1"
    local dist_id="$2"
    local cloudfront_dir="$backup_dir/cloudfront"

    if [[ ! -f "$cloudfront_dir/${dist_id}-config.json" ]]; then
        error "Distribution backup not found: $dist_id"
        return 1
    fi

    log "Restoring CloudFront distribution: $dist_id"

    # Check if distribution already exists
    if aws cloudfront get-distribution --id "$dist_id" &>/dev/null; then
        warn "Distribution $dist_id already exists. Use update operation instead."
        return 0
    fi

    # Extract distribution config
    local config_file="$cloudfront_dir/${dist_id}-config.json"
    local etag
    etag=$(jq -r '.ETag' "$config_file")

    # Create new distribution with backed up configuration
    local new_dist_config
    new_dist_config=$(jq '.DistributionConfig' "$config_file")

    # Remove read-only fields and update caller reference
    new_dist_config=$(echo "$new_dist_config" | jq '
        .CallerReference = "restore-" + (now | tostring) |
        del(.Aliases.Quantity) |
        del(.Origins.Quantity) |
        del(.DefaultCacheBehavior.TrustedSigners.Quantity) |
        del(.Comment) |
        .Comment = "Restored from backup on " + (now | strftime("%Y-%m-%d %H:%M:%S"))
    ')

    # Create the distribution
    local new_dist_result
    new_dist_result=$(aws cloudfront create-distribution \
        --distribution-config "$new_dist_config" \
        --output json)

    local new_dist_id
    new_dist_id=$(echo "$new_dist_result" | jq -r '.Distribution.Id')

    success "Distribution restored with new ID: $new_dist_id"

    # Restore tags if available
    if [[ -f "$cloudfront_dir/${dist_id}-tags.json" ]]; then
        local tags
        tags=$(jq '.Tags' "$cloudfront_dir/${dist_id}-tags.json")
        local new_dist_arn
        new_dist_arn=$(echo "$new_dist_result" | jq -r '.Distribution.ARN')

        if [[ "$tags" != "null" && "$tags" != "[]" ]]; then
            aws cloudfront tag-resource \
                --resource "$new_dist_arn" \
                --tags "$tags" || warn "Failed to restore tags for distribution $new_dist_id"
        fi
    fi
}

# Restore Route 53 records
restore_route53_records() {
    local backup_dir="$1"
    local zone_name="$2"
    local route53_dir="$backup_dir/route53"

    if [[ ! -f "$route53_dir/${zone_name}-records.json" ]]; then
        error "DNS records backup not found for zone: $zone_name"
        return 1
    fi

    log "Restoring Route 53 records for zone: $zone_name"

    # Get current hosted zone ID
    local zone_id
    zone_id=$(aws route53 list-hosted-zones \
        --query "HostedZones[?Name=='${zone_name}.'].Id" \
        --output text | head -1)

    if [[ -z "$zone_id" ]]; then
        error "Hosted zone not found: $zone_name"
        log "Create the hosted zone first, then retry restore"
        return 1
    fi

    zone_id=$(basename "$zone_id")

    # Get backed up records
    local backup_records="$route53_dir/${zone_name}-records.json"
    local records
    records=$(jq '.ResourceRecordSets[] | select(.Type != "NS" and .Type != "SOA")' "$backup_records")

    if [[ -z "$records" ]]; then
        warn "No restorable records found for zone: $zone_name"
        return 0
    fi

    # Create change batch for restoration
    local change_batch
    change_batch=$(echo "$records" | jq -s '
        {
            "Changes": [
                .[] | {
                    "Action": "UPSERT",
                    "ResourceRecordSet": .
                }
            ]
        }
    ')

    # Apply changes
    local change_id
    change_id=$(aws route53 change-resource-record-sets \
        --hosted-zone-id "$zone_id" \
        --change-batch "$change_batch" \
        --query 'ChangeInfo.Id' \
        --output text)

    success "DNS records restoration initiated. Change ID: $change_id"

    # Wait for propagation
    log "Waiting for DNS propagation..."
    aws route53 wait resource-record-sets-changed --id "$change_id"
    success "DNS records restored for zone: $zone_name"
}

# Restore from backup
restore_from_backup() {
    local backup_name="$1"
    local resource_type="${2:-all}"
    local resource_id="${3:-}"

    log "Restoring from backup: $backup_name"

    # Extract backup if compressed
    local backup_dir
    backup_dir=$(extract_backup "$backup_name")

    if [[ ! -d "$backup_dir" ]]; then
        error "Failed to access backup: $backup_name"
        return 1
    fi

    # Validate AWS credentials
    validate_aws_credentials

    # Restore based on resource type
    case "$resource_type" in
        cloudfront)
            if [[ -n "$resource_id" ]]; then
                restore_cloudfront_distribution "$backup_dir" "$resource_id"
            else
                error "Distribution ID required for CloudFront restore"
                return 1
            fi
            ;;
        route53)
            if [[ -n "$resource_id" ]]; then
                restore_route53_records "$backup_dir" "$resource_id"
            else
                error "Zone name required for Route 53 restore"
                return 1
            fi
            ;;
        all)
            warn "Full restore not implemented. Use specific resource types."
            log "Available resource types: cloudfront, route53"
            return 1
            ;;
        *)
            error "Unknown resource type: $resource_type"
            log "Available resource types: cloudfront, route53, all"
            return 1
            ;;
    esac
}

# ================================
# EMERGENCY RECOVERY FUNCTIONS
# ================================

# Emergency CloudFront rollback
emergency_cloudfront_rollback() {
    local dist_id="$1"
    local backup_name="${2:-latest}"

    error "EMERGENCY ROLLBACK: CloudFront distribution $dist_id"
    log "This will disable the distribution and attempt restoration"

    read -p "Are you sure you want to proceed? (type 'ROLLBACK' to confirm): " confirm
    if [[ "$confirm" != "ROLLBACK" ]]; then
        log "Emergency rollback cancelled"
        return 0
    fi

    # Disable current distribution
    log "Disabling current distribution..."
    local current_config
    current_config=$(aws cloudfront get-distribution-config --id "$dist_id")
    local etag
    etag=$(echo "$current_config" | jq -r '.ETag')

    local disabled_config
    disabled_config=$(echo "$current_config" | jq '.DistributionConfig.Enabled = false')

    aws cloudfront update-distribution \
        --id "$dist_id" \
        --distribution-config "$disabled_config" \
        --if-match "$etag" >/dev/null

    success "Distribution disabled"

    # Wait for deployment
    log "Waiting for distribution to be deployed..."
    aws cloudfront wait distribution-deployed --id "$dist_id"

    # Find latest backup if not specified
    if [[ "$backup_name" == "latest" ]]; then
        backup_name=$(find "${BACKUP_CONFIG[BACKUP_DIR]}" -maxdepth 1 -name "backup_*" -type d | sort -r | head -1 | xargs basename)
        if [[ -z "$backup_name" ]]; then
            error "No backup found for emergency rollback"
            return 1
        fi
        log "Using latest backup: $backup_name"
    fi

    # Restore from backup (creates new distribution)
    restore_cloudfront_distribution "$(extract_backup "$backup_name")" "$dist_id"

    warn "Emergency rollback completed. Update DNS records to point to new distribution."
}

# Emergency DNS rollback
emergency_dns_rollback() {
    local zone_name="$1"
    local backup_name="${2:-latest}"

    error "EMERGENCY ROLLBACK: DNS zone $zone_name"

    read -p "Are you sure you want to proceed? (type 'ROLLBACK' to confirm): " confirm
    if [[ "$confirm" != "ROLLBACK" ]]; then
        log "Emergency DNS rollback cancelled"
        return 0
    fi

    # Find latest backup if not specified
    if [[ "$backup_name" == "latest" ]]; then
        backup_name=$(find "${BACKUP_CONFIG[BACKUP_DIR]}" -maxdepth 1 -name "backup_*" -type d | sort -r | head -1 | xargs basename)
        if [[ -z "$backup_name" ]]; then
            error "No backup found for emergency rollback"
            return 1
        fi
        log "Using latest backup: $backup_name"
    fi

    # Restore DNS records
    restore_route53_records "$(extract_backup "$backup_name")" "$zone_name"

    success "Emergency DNS rollback completed"
}

# ================================
# MAINTENANCE FUNCTIONS
# ================================

# Cleanup old backups
cleanup_old_backups() {
    local backup_base_dir="${BACKUP_CONFIG[BACKUP_DIR]}"
    local retention_days="${BACKUP_CONFIG[RETENTION_DAYS]}"

    log "Cleaning up backups older than $retention_days days..."

    local deleted_count=0

    # Clean up directories
    while IFS= read -r -d '' backup_dir; do
        if [[ -d "$backup_dir" ]]; then
            rm -rf "$backup_dir"
            ((deleted_count++))
            debug "Deleted old backup: $(basename "$backup_dir")"
        fi
    done < <(find "$backup_base_dir" -maxdepth 1 -type d -name "backup_*" -mtime +$retention_days -print0 2>/dev/null)

    # Clean up compressed files
    while IFS= read -r -d '' backup_file; do
        if [[ -f "$backup_file" ]]; then
            rm -f "$backup_file"
            ((deleted_count++))
            debug "Deleted old backup: $(basename "$backup_file")"
        fi
    done < <(find "$backup_base_dir" -maxdepth 1 -type f -name "backup_*.tar.gz" -mtime +$retention_days -print0 2>/dev/null)

    if [[ $deleted_count -gt 0 ]]; then
        success "Cleaned up $deleted_count old backups"
    else
        log "No old backups to clean up"
    fi
}

# Verify backup integrity
verify_backup_integrity() {
    local backup_name="$1"

    log "Verifying backup integrity: $backup_name"

    local backup_dir
    backup_dir=$(extract_backup "$backup_name")

    if [[ ! -d "$backup_dir" ]]; then
        error "Backup directory not found: $backup_name"
        return 1
    fi

    local errors=0

    # Check metadata file
    if [[ ! -f "$backup_dir/backup-metadata.json" ]]; then
        error "Missing backup metadata file"
        ((errors++))
    else
        if ! jq empty "$backup_dir/backup-metadata.json" 2>/dev/null; then
            error "Invalid backup metadata JSON"
            ((errors++))
        fi
    fi

    # Check resource directories
    for resource in "${!AWS_RESOURCES[@]}"; do
        local resource_dir="$backup_dir/$resource"
        if [[ ! -d "$resource_dir" ]]; then
            warn "Missing resource directory: $resource"
            continue
        fi

        # Check for summary file
        if [[ ! -f "$resource_dir/summary.json" ]]; then
            warn "Missing summary file for: $resource"
            continue
        fi

        # Validate JSON files
        while IFS= read -r -d '' json_file; do
            if ! jq empty "$json_file" 2>/dev/null; then
                error "Invalid JSON file: $json_file"
                ((errors++))
            fi
        done < <(find "$resource_dir" -name "*.json" -type f -print0)
    done

    if [[ $errors -eq 0 ]]; then
        success "Backup integrity verification passed"
        return 0
    else
        error "Backup integrity verification failed with $errors errors"
        return 1
    fi
}

# ================================
# MAIN EXECUTION
# ================================

show_help() {
    cat << EOF
$SCRIPT_NAME - Disaster Recovery for CloudFront SSL Setup

USAGE:
    $SCRIPT_NAME [COMMAND] [OPTIONS]

COMMANDS:
    backup                  Create full backup of all resources
    list                    List available backups
    restore                 Restore from backup
    emergency-rollback      Emergency rollback operations
    verify                  Verify backup integrity
    cleanup                 Clean up old backups

BACKUP OPTIONS:
    --name NAME             Backup name (default: backup_TIMESTAMP)
    --compress              Compress backup (default: enabled)
    --upload                Upload to S3 (requires S3_BUCKET configuration)
    --retention-days N      Set retention period (default: 30)

RESTORE OPTIONS:
    --backup NAME           Backup name to restore from
    --resource TYPE         Resource type (cloudfront, route53, all)
    --id ID                 Resource ID (distribution ID, zone name)

EMERGENCY OPTIONS:
    cloudfront DIST_ID      Emergency CloudFront rollback
    dns ZONE_NAME           Emergency DNS rollback

EXAMPLES:
    $SCRIPT_NAME backup                              # Create full backup
    $SCRIPT_NAME backup --name prod-backup-2025     # Named backup
    $SCRIPT_NAME list                                # List backups
    $SCRIPT_NAME restore --backup backup_20250130 --resource cloudfront --id E123456789
    $SCRIPT_NAME restore --backup backup_20250130 --resource route53 --id example.com
    $SCRIPT_NAME emergency-rollback cloudfront E123456789
    $SCRIPT_NAME emergency-rollback dns example.com
    $SCRIPT_NAME verify backup_20250130             # Verify backup
    $SCRIPT_NAME cleanup                             # Clean old backups

CONFIGURATION:
    Set backup configuration in environment variables:
    BACKUP_S3_BUCKET=my-backup-bucket
    BACKUP_RETENTION_DAYS=30
    BACKUP_COMPRESSION=true

For more information, see: https://github.com/xapiens/cloudfront-ssl-setup
EOF
}

main() {
    local command=""
    local backup_name=""
    local resource_type=""
    local resource_id=""
    local custom_name=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            backup)
                command="backup"
                shift
                ;;
            list)
                command="list"
                shift
                ;;
            restore)
                command="restore"
                shift
                ;;
            emergency-rollback)
                command="emergency-rollback"
                shift
                ;;
            verify)
                command="verify"
                backup_name="$2"
                shift 2
                ;;
            cleanup)
                command="cleanup"
                shift
                ;;
            cloudfront|dns)
                if [[ "$command" == "emergency-rollback" ]]; then
                    resource_type="$1"
                    resource_id="$2"
                    shift 2
                else
                    error "Invalid command context for: $1"
                    exit 1
                fi
                ;;
            --name)
                custom_name="$2"
                shift 2
                ;;
            --backup)
                backup_name="$2"
                shift 2
                ;;
            --resource)
                resource_type="$2"
                shift 2
                ;;
            --id)
                resource_id="$2"
                shift 2
                ;;
            --compress)
                BACKUP_CONFIG[COMPRESSION]="true"
                shift
                ;;
            --upload)
                BACKUP_CONFIG[REMOTE_BACKUP]="true"
                shift
                ;;
            --retention-days)
                BACKUP_CONFIG[RETENTION_DAYS]="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Override backup config from environment
    [[ -n "${BACKUP_S3_BUCKET:-}" ]] && BACKUP_CONFIG[S3_BUCKET]="$BACKUP_S3_BUCKET"
    [[ -n "${BACKUP_RETENTION_DAYS:-}" ]] && BACKUP_CONFIG[RETENTION_DAYS]="$BACKUP_RETENTION_DAYS"
    [[ -n "${BACKUP_COMPRESSION:-}" ]] && BACKUP_CONFIG[COMPRESSION]="$BACKUP_COMPRESSION"

    log "$SCRIPT_NAME v$SCRIPT_VERSION"

    # Execute command
    case "$command" in
        backup)
            local final_name="${custom_name:-backup_$(timestamp)}"
            create_full_backup "$final_name"
            ;;
        list)
            list_backups
            ;;
        restore)
            if [[ -z "$backup_name" ]]; then
                error "Backup name required for restore operation"
                exit 1
            fi
            restore_from_backup "$backup_name" "$resource_type" "$resource_id"
            ;;
        emergency-rollback)
            case "$resource_type" in
                cloudfront)
                    if [[ -z "$resource_id" ]]; then
                        error "Distribution ID required for CloudFront emergency rollback"
                        exit 1
                    fi
                    emergency_cloudfront_rollback "$resource_id"
                    ;;
                dns)
                    if [[ -z "$resource_id" ]]; then
                        error "Zone name required for DNS emergency rollback"
                        exit 1
                    fi
                    emergency_dns_rollback "$resource_id"
                    ;;
                *)
                    error "Resource type required for emergency rollback (cloudfront|dns)"
                    exit 1
                    ;;
            esac
            ;;
        verify)
            if [[ -z "$backup_name" ]]; then
                error "Backup name required for verification"
                exit 1
            fi
            verify_backup_integrity "$backup_name"
            ;;
        cleanup)
            cleanup_old_backups
            ;;
        "")
            error "No command specified"
            show_help
            exit 1
            ;;
        *)
            error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
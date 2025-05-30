#!/bin/bash

# Install Dependencies Script for CloudFront SSL Setup
# This script installs all required dependencies for the CloudFront SSL setup
# Supports multiple operating systems and package managers

set -euo pipefail

# ================================
# CONFIGURATION & CONSTANTS
# ================================

readonly SCRIPT_NAME="install-deps.sh"
readonly SCRIPT_VERSION="1.0.0"
readonly MIN_BASH_VERSION="4.0"
readonly MIN_AWS_CLI_VERSION="2.0"

# Package requirements
declare -A REQUIRED_PACKAGES=(
    [aws-cli]="AWS CLI v2+ for AWS operations"
    [jq]="JSON processor for parsing AWS responses"
    [openssl]="SSL/TLS toolkit for generating secrets"
    [curl]="HTTP client for downloading and testing"
    [dig]="DNS lookup utility for validation"
)

declare -A OPTIONAL_PACKAGES=(
    [shellcheck]="Bash script static analysis tool"
    [bats]="Bash testing framework"
    [git]="Version control system"
    [docker]="Container platform for CI/CD"
)

# ================================
# UTILITY FUNCTIONS
# ================================

# Logging functions
log() { echo -e "\033[0;32m[INFO]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $*" >&2; exit 1; }
success() { echo -e "\033[0;32m[SUCCESS]\033[0m $*"; }

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Get OS information
get_os_info() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$ID"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Check package manager availability
detect_package_manager() {
    if command_exists apt-get; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists zypper; then
        echo "zypper"
    elif command_exists brew; then
        echo "brew"
    elif command_exists pacman; then
        echo "pacman"
    else
        echo "none"
    fi
}

# Version comparison function
version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# ================================
# SYSTEM CHECKS
# ================================

check_system_requirements() {
    log "Checking system requirements..."

    # Check Bash version
    local bash_version
    bash_version=$(bash --version | head -n1 | sed 's/.*version \([0-9.]*\).*/\1/')
    if ! version_gt "$bash_version" "$MIN_BASH_VERSION"; then
        if [[ "$bash_version" == "$MIN_BASH_VERSION" ]]; then
            log "✓ Bash version $bash_version (minimum required)"
        else
            error "Bash version $bash_version is too old. Minimum required: $MIN_BASH_VERSION"
        fi
    else
        log "✓ Bash version $bash_version"
    fi

    # Check OS
    local os_info
    os_info=$(get_os_info)
    log "✓ Operating System: $os_info"

    # Check package manager
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    if [[ "$pkg_manager" == "none" ]]; then
        error "No supported package manager found. Please install dependencies manually."
    fi
    log "✓ Package Manager: $pkg_manager"

    # Check architecture
    local arch
    arch=$(uname -m)
    log "✓ Architecture: $arch"

    # Check if we can install packages
    if [[ "$pkg_manager" != "brew" ]] && ! is_root && ! command_exists sudo; then
        error "Root privileges or sudo access required for package installation"
    fi
}

# ================================
# PACKAGE INSTALLATION FUNCTIONS
# ================================

# Update package lists
update_package_lists() {
    local pkg_manager="$1"

    log "Updating package lists..."

    case "$pkg_manager" in
        apt)
            sudo apt-get update -qq || warn "Failed to update apt package lists"
            ;;
        yum)
            sudo yum makecache fast || warn "Failed to update yum cache"
            ;;
        dnf)
            sudo dnf makecache || warn "Failed to update dnf cache"
            ;;
        zypper)
            sudo zypper refresh || warn "Failed to refresh zypper repositories"
            ;;
        brew)
            brew update || warn "Failed to update brew"
            ;;
        pacman)
            sudo pacman -Sy || warn "Failed to update pacman database"
            ;;
    esac
}

# Install AWS CLI v2
install_aws_cli() {
    if command_exists aws; then
        local aws_version
        aws_version=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
        if version_gt "$aws_version" "$MIN_AWS_CLI_VERSION" || [[ "$aws_version" == "$MIN_AWS_CLI_VERSION" ]]; then
            log "✓ AWS CLI v$aws_version already installed"
            return 0
        else
            warn "AWS CLI v$aws_version is outdated. Installing v2..."
        fi
    fi

    log "Installing AWS CLI v2..."

    local os_info
    os_info=$(get_os_info)
    local arch
    arch=$(uname -m)

    case "$os_info" in
        ubuntu|debian)
            local temp_dir
            temp_dir=$(mktemp -d)
            cd "$temp_dir"

            if [[ "$arch" == "x86_64" ]]; then
                curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            elif [[ "$arch" == "aarch64" ]]; then
                curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
            else
                error "Unsupported architecture: $arch"
            fi

            unzip -q awscliv2.zip
            sudo ./aws/install --update
            cd - > /dev/null
            rm -rf "$temp_dir"
            ;;
        rhel|centos|fedora)
            local temp_dir
            temp_dir=$(mktemp -d)
            cd "$temp_dir"

            curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip -q awscliv2.zip
            sudo ./aws/install --update
            cd - > /dev/null
            rm -rf "$temp_dir"
            ;;
        macos)
            if [[ "$arch" == "x86_64" ]]; then
                curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
                sudo installer -pkg AWSCLIV2.pkg -target /
                rm AWSCLIV2.pkg
            elif [[ "$arch" == "arm64" ]]; then
                curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2-arm64.pkg" -o "AWSCLIV2.pkg"
                sudo installer -pkg AWSCLIV2.pkg -target /
                rm AWSCLIV2.pkg
            fi
            ;;
        *)
            error "Unsupported OS for AWS CLI installation: $os_info"
            ;;
    esac

    # Verify installation
    if command_exists aws; then
        local new_version
        new_version=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
        success "AWS CLI v$new_version installed successfully"
    else
        error "AWS CLI installation failed"
    fi
}

# Install packages using system package manager
install_system_packages() {
    local pkg_manager="$1"
    shift
    local packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi

    log "Installing packages: ${packages[*]}"

    case "$pkg_manager" in
        apt)
            sudo apt-get install -y "${packages[@]}"
            ;;
        yum)
            sudo yum install -y "${packages[@]}"
            ;;
        dnf)
            sudo dnf install -y "${packages[@]}"
            ;;
        zypper)
            sudo zypper install -y "${packages[@]}"
            ;;
        brew)
            for package in "${packages[@]}"; do
                brew install "$package" || warn "Failed to install $package via brew"
            done
            ;;
        pacman)
            sudo pacman -S --noconfirm "${packages[@]}"
            ;;
    esac
}

# Install required packages based on OS and package manager
install_required_packages() {
    local pkg_manager="$1"
    local os_info="$2"

    log "Installing required packages..."

    # Define packages for different systems
    local packages_to_install=()

    case "$pkg_manager" in
        apt)
            packages_to_install+=(jq curl dnsutils openssl unzip)
            ;;
        yum|dnf)
            packages_to_install+=(jq curl bind-utils openssl unzip)
            ;;
        zypper)
            packages_to_install+=(jq curl bind-utils openssl unzip)
            ;;
        brew)
            packages_to_install+=(jq curl openssl)
            ;;
        pacman)
            packages_to_install+=(jq curl bind-tools openssl unzip)
            ;;
    esac

    # Install packages
    install_system_packages "$pkg_manager" "${packages_to_install[@]}"

    # Install AWS CLI separately (requires special handling)
    install_aws_cli
}

# Install optional development packages
install_optional_packages() {
    local pkg_manager="$1"
    local install_dev="$2"

    if [[ "$install_dev" != "true" ]]; then
        return 0
    fi

    log "Installing optional development packages..."

    local dev_packages=()

    case "$pkg_manager" in
        apt)
            dev_packages+=(shellcheck git docker.io)
            # Install bats-core from GitHub (not available in standard repos)
            install_bats_core
            ;;
        yum|dnf)
            dev_packages+=(ShellCheck git docker)
            install_bats_core
            ;;
        zypper)
            dev_packages+=(ShellCheck git docker)
            install_bats_core
            ;;
        brew)
            dev_packages+=(shellcheck git docker bats-core)
            ;;
        pacman)
            dev_packages+=(shellcheck git docker)
            install_bats_core
            ;;
    esac

    install_system_packages "$pkg_manager" "${dev_packages[@]}"
}

# Install bats-core testing framework
install_bats_core() {
    if command_exists bats; then
        log "✓ bats already installed"
        return 0
    fi

    log "Installing bats-core testing framework..."

    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    git clone https://github.com/bats-core/bats-core.git
    cd bats-core
    sudo ./install.sh /usr/local

    cd - > /dev/null
    rm -rf "$temp_dir"

    if command_exists bats; then
        success "bats-core installed successfully"
    else
        warn "bats-core installation may have failed"
    fi
}

# ================================
# VERIFICATION FUNCTIONS
# ================================

verify_installation() {
    log "Verifying installation..."

    local all_good=true

    # Check required packages
    for package in "${!REQUIRED_PACKAGES[@]}"; do
        case "$package" in
            aws-cli)
                if command_exists aws; then
                    local version
                    version=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
                    success "✓ AWS CLI v$version"
                else
                    error "✗ AWS CLI not found"
                    all_good=false
                fi
                ;;
            dig)
                if command_exists dig || command_exists nslookup; then
                    success "✓ DNS tools available"
                else
                    warn "✗ DNS tools not found (dig/nslookup)"
                fi
                ;;
            *)
                if command_exists "$package"; then
                    success "✓ $package"
                else
                    error "✗ $package not found"
                    all_good=false
                fi
                ;;
        esac
    done

    # Check optional packages
    for package in "${!OPTIONAL_PACKAGES[@]}"; do
        if command_exists "$package"; then
            success "✓ $package (optional)"
        else
            log "  $package (optional) - not installed"
        fi
    done

    if [[ "$all_good" == "true" ]]; then
        success "All required dependencies are installed!"
        return 0
    else
        error "Some required dependencies are missing"
        return 1
    fi
}

# Test AWS CLI configuration
test_aws_configuration() {
    log "Testing AWS CLI configuration..."

    if ! command_exists aws; then
        warn "AWS CLI not installed, skipping configuration test"
        return 0
    fi

    if aws sts get-caller-identity &>/dev/null; then
        local account_id
        account_id=$(aws sts get-caller-identity --query Account --output text)
        success "✓ AWS CLI configured (Account: $account_id)"
    else
        warn "AWS CLI is not configured. Run 'aws configure' to set up credentials."
        log "You can also use environment variables:"
        log "  export AWS_ACCESS_KEY_ID=your-access-key"
        log "  export AWS_SECRET_ACCESS_KEY=your-secret-key"
        log "  export AWS_DEFAULT_REGION=us-east-1"
    fi
}

# ================================
# MAIN FUNCTIONS
# ================================

show_help() {
    cat << EOF
$SCRIPT_NAME - Install dependencies for CloudFront SSL Setup

USAGE:
    $SCRIPT_NAME [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -d, --dev           Install development dependencies (shellcheck, bats, etc.)
    -s, --skip-update   Skip package list update
    -v, --verify-only   Only verify existing installations
    --aws-only          Install only AWS CLI
    --version           Show script version

EXAMPLES:
    $SCRIPT_NAME                    # Install required dependencies
    $SCRIPT_NAME --dev              # Install with development tools
    $SCRIPT_NAME --verify-only      # Check current installation
    $SCRIPT_NAME --aws-only         # Install only AWS CLI

REQUIREMENTS:
    - Supported OS: Ubuntu, Debian, CentOS, RHEL, Fedora, macOS, Arch Linux
    - Package manager: apt, yum, dnf, zypper, brew, pacman
    - Root/sudo access (except for macOS with brew)

For more information, see: https://github.com/xapiens/cloudfront-ssl-setup
EOF
}

main() {
    local install_dev=false
    local skip_update=false
    local verify_only=false
    local aws_only=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dev)
                install_dev=true
                shift
                ;;
            -s|--skip-update)
                skip_update=true
                shift
                ;;
            -v|--verify-only)
                verify_only=true
                shift
                ;;
            --aws-only)
                aws_only=true
                shift
                ;;
            --version)
                echo "$SCRIPT_NAME version $SCRIPT_VERSION"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    log "CloudFront SSL Setup - Dependency Installer v$SCRIPT_VERSION"

    # Verify-only mode
    if [[ "$verify_only" == "true" ]]; then
        verify_installation
        test_aws_configuration
        exit $?
    fi

    # Check system requirements
    check_system_requirements

    local pkg_manager
    pkg_manager=$(detect_package_manager)
    local os_info
    os_info=$(get_os_info)

    # Update package lists
    if [[ "$skip_update" != "true" ]]; then
        update_package_lists "$pkg_manager"
    fi

    # Install packages
    if [[ "$aws_only" == "true" ]]; then
        install_aws_cli
    else
        install_required_packages "$pkg_manager" "$os_info"
        install_optional_packages "$pkg_manager" "$install_dev"
    fi

    # Verify installation
    verify_installation
    test_aws_configuration

    success "Installation completed successfully!"

    # Show next steps
    echo ""
    log "Next steps:"
    log "1. Configure AWS CLI: aws configure"
    log "2. Copy configuration template: cp cloudfront-config.template cloudfront-config.conf"
    log "3. Edit configuration: nano cloudfront-config.conf"
    log "4. Run setup: ./cloudfront-ssl-setup.sh --config cloudfront-config.conf"
}

# Execute main function
main "$@"
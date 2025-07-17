#!/usr/bin/env -S dumb-init --single-child /bin/bash

set -euo pipefail

# Function to check if we have docker socket access
check_docker_socket() {
    if [ -S /var/run/docker.sock ]; then
        # Test docker socket access
        if docker info >/dev/null 2>&1; then
            echo " Docker socket is accessible and working."
            return 0
        else
            echo " Docker socket exists but not accessible."
            return 1
        fi
    else
        echo " WARNING: Docker socket not accessible. Some features may be limited."
        return 1
    fi
}

# Function to get tool version safely
get_tool_version() {
    local tool="$1"
    local version_flag="${2:---version}"

    case "$tool" in
        "terragrunt")
            # Check if terragrunt exists first
            if command -v terragrunt >/dev/null 2>&1; then
                terragrunt --version 2>&1 | head -n1 || echo 'Not available'
            else
                echo 'Not available (binary not found)'
            fi
            ;;
        "terraform")
            if command -v terraform >/dev/null 2>&1; then
                terraform --version 2>/dev/null | head -n1 || echo 'Not available'
            else
                echo 'Not available (binary not found)'
            fi
            ;;
        "tofu"|"opentofu")
            if command -v tofu >/dev/null 2>&1; then
                tofu --version 2>/dev/null | head -n1 || echo 'Not available'
            else
                echo 'Not available (binary not found)'
            fi
            ;;
        "node")
            if command -v node >/dev/null 2>&1; then
                node --version 2>/dev/null || echo 'Not available'
            else
                echo 'Not available (binary not found)'
            fi
            ;;
        "npm")
            if command -v npm >/dev/null 2>&1; then
                npm --version 2>/dev/null || echo 'Not available'
            else
                echo 'Not available (binary not found)'
            fi
            ;;
        "pnpm")
            if command -v pnpm >/dev/null 2>&1; then
                pnpm --version 2>/dev/null || echo 'Not available'
            else
                echo 'Not available (binary not found)'
            fi
            ;;
        "python")
            if command -v python >/dev/null 2>&1; then
                python --version 2>&1 || echo 'Not available'
            else
                echo 'Not available (binary not found)'
            fi
            ;;
        "docker")
            if command -v docker >/dev/null 2>&1; then
                docker --version 2>/dev/null || echo 'Not available'
            else
                echo 'Not available (binary not found)'
            fi
            ;;
        *)
            echo 'Unknown tool'
            ;;
    esac
}

# For root user
if [ "$(id -u)" = "0" ]; then
    export NVM_DIR="/root/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    export PNPM_HOME="/root/.local/share/pnpm"
else
    # For atlantis user
    export NVM_DIR="/home/atlantis/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    export PNPM_HOME="/home/atlantis/.local/share/pnpm"
fi
export PATH="${PNPM_HOME}:${PATH}"

# For root user
if [ "$(id -u)" = "0" ]; then
    export HOME_BASE="/root"
else
    export HOME_BASE="/home/atlantis"
fi

[ -f $HOME_BASE/.bash_profile ] && source $HOME_BASE/.bash_profile
[ -f $HOME_BASE/.bashrc ] && source $HOME_BASE/.bashrc

# If we're trying to run atlantis directly with some arguments, then
# pass them to atlantis.
if [ "${1:0:1}" = '-' ]; then
    set -- atlantis "$@"
fi

# Check if running a atlantis subcommand and prepend atlantis if needed
if [ $# -gt 0 ]; then
    case "$1" in
        server|version|testdrive)
            # These are valid atlantis subcommands, prepend atlantis
            set -- atlantis "$@"
            ;;
        atlantis)
            # Already has atlantis, leave as is
            ;;
        *)
            # Check if it's a valid atlantis subcommand
            if atlantis help "$1" 2>&1 | grep -q "atlantis $1"; then
                set -- atlantis "$@"
            fi
            ;;
    esac
fi

# Create user in /etc/passwd if running without user
if ! whoami &> /dev/null; then
    if [ -w /etc/passwd ]; then
        echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:/home/atlantis:/sbin/nologin" >> /etc/passwd
    fi
fi

# Check for scripts in /docker-entrypoint.d/
if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo "/docker-entrypoint.d/ is not empty, executing scripts"
    find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo "Executing $f"
                    "$f"
                else
                    echo "Ignoring $f, not executable"
                fi
                ;;
            *) echo "Ignoring $f";;
        esac
    done
else
    echo "No files found in /docker-entrypoint.d/, skipping"
fi

# Debug: Show current PATH and binary locations
echo "🔍 Debug Information:"
echo "   PATH: $PATH"
echo "   Current working directory: $(pwd)"
echo "   Current user: $(whoami) (UID: $(id -u), GID: $(id -g))"
echo ""

# Debug: Check for binaries in expected locations
echo "🔍 Binary Discovery:"
echo "   Checking /usr/local/bin/ for tools..."
ls -la /usr/local/bin/ | grep -E "(terraform|terragrunt|tofu|atlantis)" || echo "   No IaC tools found in /usr/local/bin/"
echo ""

# Verify environment
echo "Verifying environment..."
echo ""
echo "==============================================================================="
echo " Atlantis Server: "
echo "   $(atlantis version) "
echo "==============================================================================="
echo " Infrastructure as Code Tools:"
echo "   Terraform: $(get_tool_version terraform)"
echo "   Terragrunt: $(get_tool_version terragrunt)"
echo "   OpenTofu: $(get_tool_version tofu)"
echo "-------------------------------------------------------------------------------"
echo " Development Tools:"
echo "   Node.js: $(get_tool_version node)"
echo "   NPM: $(get_tool_version npm)"
echo "   PNPM: $(get_tool_version pnpm)"
echo "   Python: $(get_tool_version python)"
echo "-------------------------------------------------------------------------------"
echo " Container & System Tools:"
if check_docker_socket; then
    echo "   Docker: $(get_tool_version docker)"
else
    echo "   Docker: Not available (no socket access)"
fi
echo "   User: $(whoami) (UID: $(id -u), GID: $(id -g))"
echo "   Working Directory: $(pwd)"
echo "   Environment: ${ATLANTIS_ENV:-production}"
echo "==============================================================================="

# Show available tool versions if multiple versions are installed
echo ""
echo "Available tool versions:"
echo "└── Terraform versions:"
if find /usr/local/bin -name "terraform*" -type f -executable 2>/dev/null | head -1 >/dev/null; then
    find /usr/local/bin -name "terraform*" -type f -executable 2>/dev/null | sort | while read -r tf_path; do
        tf_name=$(basename "$tf_path")
        tf_version=$($tf_path --version 2>/dev/null | head -n1 | cut -d' ' -f2 || echo 'unknown')
        echo "    ├── $tf_name: $tf_version"
    done
else
    echo "    └── No terraform binaries found"
fi

echo "└── Terragrunt versions:"
if find /usr/local/bin -name "terragrunt*" -type f -executable 2>/dev/null | head -1 >/dev/null; then
    find /usr/local/bin -name "terragrunt*" -type f -executable 2>/dev/null | sort | while read -r tg_path; do
        tg_name=$(basename "$tg_path")
        tg_version=$($tg_path --version 2>&1 | head -n1 | grep -o 'v[0-9][0-9.]*' || echo 'unknown')
        echo "    ├── $tg_name: $tg_version"
    done
else
    echo "    └── No terragrunt binaries found"
fi

echo "└── OpenTofu versions:"
if find /usr/local/bin -name "tofu*" -type f -executable 2>/dev/null | head -1 >/dev/null; then
    find /usr/local/bin -name "tofu*" -type f -executable 2>/dev/null | sort | while read -r tofu_path; do
        tofu_name=$(basename "$tofu_path")
        tofu_version=$($tofu_path --version 2>/dev/null | head -n1 | cut -d' ' -f2 || echo 'unknown')
        echo "    ├── $tofu_name: $tofu_version"
    done
else
    echo "    └── No tofu binaries found"
fi

echo ""
echo "==============================================================================="

# Verify Terragrunt-Terraform compatibility
echo "🔍 Checking Terragrunt-Terraform compatibility..."
TERRAFORM_VERSION=""
TERRAGRUNT_VERSION=""

if command -v terraform >/dev/null 2>&1; then
    TERRAFORM_VERSION=$(terraform --version 2>/dev/null | head -n1 | grep -o 'v[0-9][0-9.]*' | sed 's/v//' || echo "")
fi

if command -v terragrunt >/dev/null 2>&1; then
    TERRAGRUNT_VERSION=$(terragrunt --version 2>&1 | head -n1 | grep -o 'v[0-9][0-9.]*' | sed 's/v//' || echo "")
fi

if [ -n "$TERRAFORM_VERSION" ] && [ -n "$TERRAGRUNT_VERSION" ]; then
    echo "   Terraform: v$TERRAFORM_VERSION"
    echo "   Terragrunt: v$TERRAGRUNT_VERSION"

    # Check if Terraform version is >= 1.9.8 as requested
    if printf '%s\n' "1.9.8" "$TERRAFORM_VERSION" | sort -V | head -n1 | grep -q "1.9.8"; then
        echo "   ✅ Terraform version meets minimum requirement (>= 1.9.8)"
    else
        echo "   ⚠️  Terraform version is below minimum requirement (< 1.9.8)"
    fi

    # Basic compatibility check for Terragrunt
    if printf '%s\n' "0.70.0" "$TERRAGRUNT_VERSION" | sort -V | head -n1 | grep -q "0.70.0"; then
        echo "   ✅ Terragrunt version supports Terraform 1.9.8+"
    else
        echo "   ℹ️  Using Terragrunt v$TERRAGRUNT_VERSION (compatibility varies)"
    fi
elif [ -n "$TERRAFORM_VERSION" ] && [ -z "$TERRAGRUNT_VERSION" ]; then
    echo "   Terraform: v$TERRAFORM_VERSION"
    echo "   ⚠️  Terragrunt: Not found - check if terragrunt binary was copied correctly"
elif [ -z "$TERRAFORM_VERSION" ] && [ -n "$TERRAGRUNT_VERSION" ]; then
    echo "   Terragrunt: v$TERRAGRUNT_VERSION"
    echo "   ⚠️  Terraform: Not found"
else
    echo "   ⚠️  Could not determine version compatibility"
    echo "   ⚠️  Neither Terraform nor Terragrunt found in PATH"
fi

echo "==============================================================================="

# Debug: Show what we're about to execute
echo "🔍 About to execute: $*"

# Execute the main command
exec "$@"
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

# Verify environment
echo "Verifying environment..."
echo ""
echo "==============================================================================="
echo " Atlantis Server: "
echo "   $(atlantis version) "
echo "==============================================================================="
echo " Node version: $(node --version 2>/dev/null || echo 'Not available')"
echo " NPM version: $(npm --version 2>/dev/null || echo 'Not available')"
echo " PNPM version: $(pnpm --version 2>/dev/null || echo 'Not available')"
echo " Python version: $(python --version 2>&1 || echo 'Not available')"
echo " Terraform version: $(terraform --version 2>/dev/null | head -n1 || echo 'Not available')"
if check_docker_socket; then
    echo " -> Docker version: $(docker --version 2>/dev/null || echo 'Not available')"
else
    echo " -> Docker version: Not available (no socket access)"
fi
echo "==============================================================================="

# Debug: Show what we're about to execute
echo "🔍 About to execute: $*"

# Execute the main command
exec "$@"
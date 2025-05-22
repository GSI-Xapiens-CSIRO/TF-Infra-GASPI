#!/bin/bash
# install-atlantis-deploy.sh

set -euo pipefail

echo "🚀 Installing atlantis-deploy system-wide..."

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script with sudo or as root"
    exit 1
fi

# Source and destination paths
SOURCE_SCRIPT="./scripts/atlantis-deploy.sh"
DEST_PATH="/usr/local/bin/atlantis-deploy"

# Check if source script exists
if [ ! -f "$SOURCE_SCRIPT" ]; then
    echo "❌ Source script not found: $SOURCE_SCRIPT"
    exit 1
fi

# Copy script to system location
echo "📋 Copying script to $DEST_PATH..."
cp "$SOURCE_SCRIPT" "$DEST_PATH"

# Make it executable
echo "🔧 Making script executable..."
chmod +x "$DEST_PATH"

# Verify installation
if [ -x "$DEST_PATH" ]; then
    echo "✅ atlantis-deploy installed successfully!"
    echo "📍 Location: $DEST_PATH"
    echo "📖 Usage: atlantis-deploy <environment> [plan|apply]"
    echo "💡 Example: atlantis-deploy hub01 plan"

    # Show version
    echo "🔍 Testing installation..."
    "$DEST_PATH" --version
else
    echo "❌ Installation failed!"
    exit 1
fi
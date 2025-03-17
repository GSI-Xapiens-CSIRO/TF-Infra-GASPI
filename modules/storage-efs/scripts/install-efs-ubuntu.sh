#!/bin/bash
# ========================= #
#  Ubuntu Installation     #
# ========================= #

# Update system
sudo apt-get update

# Install required packages including OpenSSL dev and pkg-config
sudo apt-get install -y \
    binutils \
    git \
    curl \
    nfs-common \
    stunnel4 \
    openssl \
    libssl-dev \
    pkg-config \
    build-essential \
    python3-pip

# Install Rust/Cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Clone and install amazon-efs-utils
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb

# Mount EFS
EFS_ID="fs-0c6d5a751646363bc"
EFS_AP="fsap-0e941d952aff6e87d"
MOUNT_POINT="/mnt/efs"
REGION="ap-southeast-3"

# Create mount point
sudo mkdir -p $MOUNT_POINT

# Add to /etc/fstab for persistent mount
echo "$EFS_ID.efs.$REGION.amazonaws.com:/ $MOUNT_POINT efs _netdev,tls,accesspoint=$EFS_AP,iam 0 0" | sudo tee -a /etc/fstab

# Mount EFS
sudo mount -a -t efs,nfs4

# Verify mount
df -h | grep efs

# ========================= #
#  Common Operations       #
# ========================= #
# These commands work on all distributions after mounting:

# Test EFS Mount
function test_efs() {
    local MOUNT_POINT="/mnt/efs"

    echo "Testing EFS mount..."

    # Create test directory
    sudo mkdir -p $MOUNT_POINT/test

    # Create test file
    echo "Test file created at $(date)" | sudo tee $MOUNT_POINT/test/test.txt

    # List contents
    ls -la $MOUNT_POINT/test/

    # Read test file
    cat $MOUNT_POINT/test/test.txt

    echo "EFS test complete!"
}

# Verify Mount Status
function check_mount() {
    echo "Checking EFS mount status..."
    df -h | grep efs
    mount | grep efs
}

# Check Permissions
function check_permissions() {
    local MOUNT_POINT="/mnt/efs"

    echo "Checking EFS permissions..."
    ls -la $MOUNT_POINT
}

# Usage Example:
# For Ubuntu:
# chmod +x install-efs-ubuntu.sh
# sudo ./install-efs-ubuntu.sh

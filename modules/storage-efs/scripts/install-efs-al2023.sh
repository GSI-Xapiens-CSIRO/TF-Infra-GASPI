#!/bin/bash
# ========================= #
#  Amazon Linux 2023       #
# ========================= #
# install-efs-al2023.sh
#!/bin/bash

# Update system
sudo dnf update -y

# Install amazon-efs-utils and NFS
sudo dnf install -y amazon-efs-utils nfs-utils

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

# Start NFS service
sudo systemctl start nfs-server
sudo systemctl enable nfs-server

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

# For Amazon Linux 2023:
# chmod +x install-efs-al2023.sh
# sudo ./install-efs-al2023.sh
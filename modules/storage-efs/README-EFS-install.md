# Amazon EFS Installation Guide

This guide provides step-by-step instructions for installing and configuring Amazon EFS (Elastic File System) on Ubuntu, Amazon Linux 2, and Amazon Linux 2023.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation by OS](#installation-by-os)
  - [Ubuntu Installation](#ubuntu-installation)
  - [Amazon Linux 2 Installation](#amazon-linux-2-installation)
  - [Amazon Linux 2023 Installation](#amazon-linux-2023-installation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Common Operations](#common-operations)

## Prerequisites

Before you begin, ensure you have:
- An AWS account with proper IAM permissions
- An EFS file system created in your AWS account
- EC2 instances in the same VPC as your EFS
- Security groups configured to allow NFS traffic (port 2049)

Current EFS Details:
```bash
EFS_ID="fs-0c6d5a751646363bc"
EFS_AP="fsap-0e941d952aff6e87d"
REGION="ap-southeast-3"
```

## Installation by OS

### Ubuntu Installation

1. Update system and install dependencies:
```bash
sudo apt-get update
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
```

2. Install Rust/Cargo:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
```

3. Build and install amazon-efs-utils:
```bash
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
```

### Amazon Linux 2 Installation

1. Update system and install utilities:
```bash
sudo yum update -y
sudo yum install -y amazon-efs-utils nfs-utils
```

2. Start NFS service:
```bash
sudo service nfs start
```

### Amazon Linux 2023 Installation

1. Update system and install utilities:
```bash
sudo dnf update -y
sudo dnf install -y amazon-efs-utils nfs-utils
```

2. Start and enable NFS service:
```bash
sudo systemctl start nfs-server
sudo systemctl enable nfs-server
```

## Configuration

1. Create mount point:
```bash
sudo mkdir -p /mnt/efs
```

2. Configure automatic mounting (add to /etc/fstab):
```bash
# Replace with your EFS details
echo "fs-0c6d5a751646363bc.efs.ap-southeast-3.amazonaws.com:/ /mnt/efs efs _netdev,tls,accesspoint=fsap-0e941d952aff6e87d,iam 0 0" | sudo tee -a /etc/fstab
```

3. Mount EFS:
```bash
sudo mount -a -t efs,nfs4
```

4. Verify mount:
```bash
df -h | grep efs
```

## Troubleshooting

1. Check mount errors:
```bash
# Ubuntu
sudo tail -f /var/log/syslog

# Amazon Linux
sudo tail -f /var/log/messages
```

2. Verify NFS service:
```bash
# Ubuntu & Amazon Linux 2023
sudo systemctl status nfs-server

# Amazon Linux 2
sudo service nfs status
```

3. Common Issues:
   - Mount timeout: Check security groups and NFS port (2049)
   - Permission denied: Verify IAM roles and access point settings
   - TLS errors: Check system time synchronization

4. Remount if needed:
```bash
sudo umount /mnt/efs
sudo mount -a -t efs,nfs4
```

## Common Operations

1. Test file operations:
```bash
# Create test file
sudo touch /mnt/efs/test.txt
echo "test content" | sudo tee /mnt/efs/test.txt

# Check permissions
ls -la /mnt/efs

# Read file
cat /mnt/efs/test.txt
```

2. Set permissions:
```bash
# Set ownership
sudo chown -R ubuntu:ubuntu /mnt/efs    # For Ubuntu
sudo chown -R ec2-user:ec2-user /mnt/efs    # For Amazon Linux

# Set directory permissions
sudo chmod 755 /mnt/efs
```

3. Monitor usage:
```bash
# Check disk usage
df -h /mnt/efs

# Monitor I/O
sudo iostat -x 1
```

4. Performance testing:
```bash
# Write test
dd if=/dev/zero of=/mnt/efs/test_file bs=1M count=1024

# Read test
dd if=/mnt/efs/test_file of=/dev/null bs=1M
```

## Security Best Practices

1. Use IAM roles for authentication
2. Enable encryption in transit
3. Use access points for application-specific access
4. Regularly audit mount point permissions
5. Monitor CloudWatch metrics for EFS

Remember to replace the EFS ID, Access Point ID, and region with your specific values when using these instructions.
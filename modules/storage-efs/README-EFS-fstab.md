# EFS /etc/fstab Configuration Guide

## EFS Details
```bash
EFS_ID="fs-0c6d5a751646363bc"
EFS_AP="fsap-0e941d952aff6e87d"
REGION="ap-southeast-3"
MOUNT_POINT="/mnt/efs"
```

## Basic fstab Configuration

1. Without Access Point:
```bash
# Add to /etc/fstab
${EFS_ID}.efs.${REGION}.amazonaws.com:/ /mnt/efs efs defaults,_netdev,tls 0 0
```

2. With Access Point:
```bash
# Add to /etc/fstab
${EFS_ID}.efs.${REGION}.amazonaws.com:/ /mnt/efs efs _netdev,tls,accesspoint=${EFS_AP},iam 0 0
```

## Advanced fstab Options

1. With IAM Authorization:
```bash
# Using IAM roles
${EFS_ID}.efs.${REGION}.amazonaws.com:/ /mnt/efs efs _netdev,tls,iam 0 0
```

2. With Performance Options:
```bash
# Optimize for multiple operations
${EFS_ID}.efs.${REGION}.amazonaws.com:/ /mnt/efs efs _netdev,tls,accesspoint=${EFS_AP},iam,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0
```

## Implementation Examples

1. Using Command Line:
```bash
# Basic mount with access point
sudo bash -c 'echo "fs-0c6d5a751646363bc.efs.ap-southeast-3.amazonaws.com:/ /mnt/efs efs _netdev,tls,accesspoint=fsap-0e941d952aff6e87d,iam 0 0" >> /etc/fstab'

# Optimized mount with access point
sudo bash -c 'echo "fs-0c6d5a751646363bc.efs.ap-southeast-3.amazonaws.com:/ /mnt/efs efs _netdev,tls,accesspoint=fsap-0e941d952aff6e87d,iam,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab'
```

2. Using Script:
```bash
#!/bin/bash

# EFS Configuration
EFS_ID="fs-0c6d5a751646363bc"
EFS_AP="fsap-0e941d952aff6e87d"
REGION="ap-southeast-3"
MOUNT_POINT="/mnt/efs"

# Create mount point if it doesn't exist
sudo mkdir -p $MOUNT_POINT

# Add to fstab with optimized settings
FSTAB_ENTRY="${EFS_ID}.efs.${REGION}.amazonaws.com:/ ${MOUNT_POINT} efs _netdev,tls,accesspoint=${EFS_AP},iam,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0"

# Check if entry already exists
if ! grep -q "${EFS_ID}" /etc/fstab; then
    echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
    echo "Added EFS mount to fstab"
else
    echo "EFS mount already exists in fstab"
fi

# Mount all EFS filesystems
sudo mount -a -t efs,nfs4

# Verify mount
if mount | grep -q "$MOUNT_POINT"; then
    echo "EFS mounted successfully"
else
    echo "EFS mount failed"
fi
```

## Mount Options Explained

- `_netdev`: System waits for network before mounting
- `tls`: Enables encryption in transit
- `iam`: Uses IAM authorization
- `accesspoint`: Specifies EFS access point
- `rsize=1048576`: Read buffer size (1MB)
- `wsize=1048576`: Write buffer size (1MB)
- `hard`: Continues to retry requests until server responds
- `timeo=600`: Timeout in deciseconds (60 seconds)
- `retrans=2`: Number of retransmissions before failure

## Verify Configuration

1. Check fstab entry:
```bash
cat /etc/fstab | grep efs
```

2. Test mount:
```bash
sudo mount -a -t efs,nfs4
```

3. Verify mount:
```bash
df -h | grep efs
mount | grep efs
```

## Troubleshooting

If mount fails:
```bash
# Check mount errors
sudo tail -f /var/log/syslog    # Ubuntu
sudo tail -f /var/log/messages  # Amazon Linux

# Manually mount to test
sudo mount -t efs -o tls,accesspoint=fsap-0e941d952aff6e87d ${EFS_ID}.efs.${REGION}.amazonaws.com:/ /mnt/efs

# Test filesystem
touch /mnt/efs/test.txt
```

Remember to:
- Backup /etc/fstab before making changes
- Test mount with mount -a before rebooting
- Verify IAM roles and security groups are properly configured
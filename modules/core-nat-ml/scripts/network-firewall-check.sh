#!/bin/bash
# ==========================================================================
#  Network Firewall Diagnostics Script
# --------------------------------------------------------------------------
#  Run this to diagnose why your Network Firewall isn't blocking traffic
# ==========================================================================

echo "🔍 NETWORK FIREWALL DIAGNOSTICS"
echo "================================="

# --------------------------------------------------------------------------
#  1. Check SageMaker Notebook Instance Configuration
# --------------------------------------------------------------------------
echo ""
echo "1️⃣  CHECKING SAGEMAKER NOTEBOOK INSTANCES..."

# Get notebook instance details
aws sagemaker list-notebook-instances --region ap-southeast-3 --query 'NotebookInstances[*].[NotebookInstanceName,NotebookInstanceStatus,InstanceType,SubnetId]' --output table

# Get specific notebook instance subnet info
NOTEBOOK_NAME="testrinf-firewall-c54-e95-42d"
echo ""
echo "📍 Checking subnet placement for: $NOTEBOOK_NAME"

SUBNET_ID=$(aws sagemaker describe-notebook-instance --notebook-instance-name $NOTEBOOK_NAME --region ap-southeast-3 --query 'SubnetId' --output text)
echo "Subnet ID: $SUBNET_ID"

if [ "$SUBNET_ID" != "None" ] && [ "$SUBNET_ID" != "null" ]; then
    # Get subnet details
    aws ec2 describe-subnets --subnet-ids $SUBNET_ID --region ap-southeast-3 --query 'Subnets[0].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0],MapPublicIpOnLaunch]' --output table

    # Get route table for this subnet
    ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --region ap-southeast-3 --filters "Name=association.subnet-id,Values=$SUBNET_ID" --query 'RouteTables[0].RouteTableId' --output text)
    echo ""
    echo "🛣️  Route table for notebook subnet:"
    aws ec2 describe-route-tables --route-table-ids $ROUTE_TABLE_ID --region ap-southeast-3 --query 'RouteTables[0].Routes[*].[DestinationCidrBlock,GatewayId,NatGatewayId,VpcEndpointId,State]' --output table
else
    echo "⚠️  Notebook instance is using DEFAULT VPC - This bypasses your custom firewall!"
fi

# --------------------------------------------------------------------------
#  2. Check Network Firewall Status
# --------------------------------------------------------------------------
echo ""
echo "2️⃣  CHECKING NETWORK FIREWALL STATUS..."

# List all firewalls
aws networkfirewall list-firewalls --region ap-southeast-3 --query 'Firewalls[*].[FirewallName,FirewallArn]' --output table

# Get firewall details
FIREWALL_NAME=$(aws networkfirewall list-firewalls --region ap-southeast-3 --query 'Firewalls[0].FirewallName' --output text)

if [ "$FIREWALL_NAME" != "None" ] && [ "$FIREWALL_NAME" != "null" ]; then
    echo ""
    echo "🔥 Firewall Status: $FIREWALL_NAME"
    aws networkfirewall describe-firewall --firewall-name $FIREWALL_NAME --region ap-southeast-3 --query 'Firewall.FirewallStatus.Status' --output text

    echo ""
    echo "🔥 Firewall Endpoint IDs:"
    aws networkfirewall describe-firewall --firewall-name $FIREWALL_NAME --region ap-southeast-3 --query 'Firewall.FirewallStatus.SyncStates[*].[AvailabilityZone,Attachment[0].EndpointId]' --output table
else
    echo "❌ No Network Firewall found!"
fi

# --------------------------------------------------------------------------
#  3. Check VPC and Subnet Configuration
# --------------------------------------------------------------------------
echo ""
echo "3️⃣  CHECKING VPC CONFIGURATION..."

# Find your VPC
VPC_ID=$(aws ec2 describe-vpcs --region ap-southeast-3 --filters "Name=tag:Name,Values=*gxc-tf-hub02*" --query 'Vpcs[0].VpcId' --output text)
echo "VPC ID: $VPC_ID"

if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "null" ]; then
    # List all subnets in VPC
    echo ""
    echo "📍 Subnets in VPC:"
    aws ec2 describe-subnets --region ap-southeast-3 --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0],MapPublicIpOnLaunch]' --output table

    # Check route tables
    echo ""
    echo "🛣️  Route Tables in VPC:"
    aws ec2 describe-route-tables --region ap-southeast-3 --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[*].[RouteTableId,Tags[?Key==`Name`].Value|[0],Associations[0].SubnetId]' --output table
fi

# --------------------------------------------------------------------------
#  4. Check Firewall Logs
# --------------------------------------------------------------------------
echo ""
echo "4️⃣  CHECKING FIREWALL LOGS..."

# Check if firewall logs exist
LOG_GROUPS=$(aws logs describe-log-groups --region ap-southeast-3 --log-group-name-prefix "/aws/networkfirewall" --query 'logGroups[*].logGroupName' --output text)

if [ -n "$LOG_GROUPS" ]; then
    echo "📋 Firewall log groups found:"
    echo "$LOG_GROUPS"

    # Check recent logs
    for LOG_GROUP in $LOG_GROUPS; do
        echo ""
        echo "📋 Recent logs from: $LOG_GROUP"
        aws logs filter-log-events --region ap-southeast-3 --log-group-name "$LOG_GROUP" --start-time $(date -d '1 hour ago' +%s)000 --query 'events[0:5].message' --output text | head -5
    done
else
    echo "❌ No firewall logs found - logging might not be configured!"
fi

# --------------------------------------------------------------------------
#  5. Network Connectivity Test from Your Location
# --------------------------------------------------------------------------
echo ""
echo "5️⃣  TESTING NETWORK CONNECTIVITY..."

echo "🧪 Testing connectivity to blocked domains:"
for domain in "google.com" "dropbox.com" "facebook.com"; do
    echo -n "  Testing $domain: "
    if timeout 5 bash -c "</dev/tcp/$domain/80" 2>/dev/null; then
        echo "✅ ACCESSIBLE (Should be blocked!)"
    else
        echo "❌ BLOCKED (Good!)"
    fi
done

# --------------------------------------------------------------------------
#  6. Generate Fix Recommendations
# --------------------------------------------------------------------------
echo ""
echo "6️⃣  RECOMMENDATIONS:"
echo "==================="

if [ "$SUBNET_ID" = "None" ] || [ "$SUBNET_ID" = "null" ]; then
    echo "❌ CRITICAL: SageMaker Notebook Instance is using DEFAULT VPC"
    echo "   → This completely bypasses your Network Firewall"
    echo "   → Solution: Place notebook in your custom VPC subnets"
fi

if [ "$FIREWALL_NAME" = "None" ] || [ "$FIREWALL_NAME" = "null" ]; then
    echo "❌ CRITICAL: No Network Firewall found"
    echo "   → Deploy Network Firewall first"
fi

echo ""
echo "✅ NEXT STEPS:"
echo "1. Run the security validation script on your SageMaker notebook"
echo "2. Check if notebook is in correct subnet"
echo "3. Verify route tables point to firewall endpoints"
echo "4. Test blocked domains from notebook terminal"

echo ""
echo "🔗 To test from SageMaker notebook, run in Jupyter terminal:"
echo "   curl -I google.com"
echo "   curl -I dropbox.com"
echo "   ping -c 3 8.8.8.8"
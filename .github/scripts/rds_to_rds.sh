#!/bin/bash

# Set the variables
# DB_INSTANCE_IDENTIFIER="bi01"
# SNAPSHOT_NAME="bac-bi01"

VPC_SECURITY_GROUP=$(aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_IDENTIFIER | jq -r '.DBInstances[0].VpcSecurityGroups[].VpcSecurityGroupId')
DB_SUBNET_GROUP_NAME=$(aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_IDENTIFIER | jq -r '.DBInstances[0].DBSubnetGroup.DBSubnetGroupName')

# Create the snapshot
echo "Creating snapshot..."
aws rds create-db-snapshot --db-instance-identifier $DB_INSTANCE_IDENTIFIER --db-snapshot-identifier $SNAPSHOT_NAME

# Wait for the snapshot to be available
echo "Waiting for snapshot to be available..."
while true; do
    SN_STATUS=$(aws rds describe-db-snapshots --db-snapshot-identifier $SNAPSHOT_NAME | jq -r '.DBSnapshots[0].Status')
    if [ "$SN_STATUS" == "available" ]; then
        break
    else
        echo "Waiting..."
        sleep 10
    fi
done

# Restore the snapshot
echo "Restoring snapshot..."
aws rds restore-db-instance-from-db-snapshot --db-instance-identifier $SNAPSHOT_NAME --db-snapshot-identifier $SNAPSHOT_NAME --vpc-security-group-ids $VPC_SECURITY_GROUP --db-subnet-group-name $DB_SUBNET_GROUP_NAME

# Wait for the snapshot to be restored
echo "Waiting for snapshot to be restored..."
while true; do
    DB_STATUS=$(aws rds describe-db-instances --db-instance-identifier $SNAPSHOT_NAME | jq -r '.DBInstances[0].DBInstanceStatus')
    if [ "$DB_STATUS" == "available" ]; then
        break
    else
        echo "Waiting..."
        sleep 10
    fi
done

echo "Done!"

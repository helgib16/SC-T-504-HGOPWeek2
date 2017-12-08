#!/usr/bin/env bash

THISDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo ""
echo "Removing current AWM instance"
echo ""

INSTANCE_ID=$(cat ./ec2_instance/instance-id.txt)
SECURITY_GROUP_ID=$(cat ./ec2_instance/security-group-id.txt)
USERNAME=$(aws iam get-user --query 'User.UserName' --output text)

. ${THISDIR}/functions.sh

echo ""
echo "Terminating the instance, hold on..."
if [ -e "./ec2_instance/instance-id.txt" ]; then
    aws ec2 terminate-instances --instance-ids ${INSTANCE_ID}

    aws ec2 wait --region eu-west-2 instance-terminated --instance-ids ${INSTANCE_ID}

    rm ./ec2_instance/instance-id.txt
    rm ./ec2_instance/instance-public-name.txt
fi
echo "Done terminating the instance"

echo ""
echo "Terminating the security group"
if [ ! -e ./ec2_instance/security-group-id.txt ]; then
    SECURITY_GROUP_ID=$(cat ./ec2_instance/security-group-id.txt)
else
    delete-security-group ${SECURITY_GROUP_ID}
fi
echo "Done terminating the security group"

# Delete the key pair used to connect to the instance
echo ""
echo "Removing the key-pair";

delete-key-pair

echo "Done removing the key-pair"

echo ""
echo "Removing the $INSTANCE_DIR folder"
#Delete the folder $INSTANCE_DIR recusive/force
rm  -rf ./ec2_instance

echo "Done removing $INSTANCE_DIR"

echo ""
echo "All Done!"
echo ""
#!/usr/bin/env bash

THISDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${THISDIR}/myVariables.sh

echo ""
echo "Welcome, lets destroy some stuff"
echo ""

#. ${THISDIR}/functions.sh

echo ""
echo "Terminating the instance, hold on..."
if [ -e "./$INSTANCE_DIR/instance-id.txt" ]; then
    aws ec2 terminate-instances --instance-ids ${INSTANCE_ID}

    aws ec2 wait --region eu-west-1 instance-terminated --instance-ids ${INSTANCE_ID}

    rm ./$INSTANCE_DIR/instance-id.txt
    rm ./$INSTANCE_DIR/instance-public-name.txt
fi
echo "Done terminating the instance"

echo ""
echo "Terminating the security group"
if [ ! -e ./$INSTANCE_DIR/security-group-id.txt ]; then
    SECURITY_GROUP_ID=$(cat ./$INSTANCE_DIR/security-group-id.txt)
else
    delete-security-group ${JENKINS_SECURITY_GROUP}
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
rm  -rf $INSTANCE_DIR

echo "Done removing $INSTANCE_DIR"

echo ""
echo "All Done!"
echo ""
#!/usr/bin/env bash

#Script creating a AWS instance and deploying jenkins

#Setting environmental variables
THISDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${THISDIR}/functions.sh

USERNAME=$(aws iam get-user --query 'User.UserName' --output text)

PEM_NAME=hgop-${USERNAME}
JENKINS_SECURITY_GROUP=jenkins-${USERNAME}

echo ""
echo "Setup will run full setup of AWS instance with jenkins"
echo ""

echo "Checking security group"
if [ ! -e ./ec2_instance/security-group-id.txt ]; then
	echo "Creating new security group"
    create-security-group ${JENKINS_SECURITY_GROUP}
else
	echo "Retrieving security group ID"
    SECURITY_GROUP_ID=$(cat ./ec2_instance/security-group-id.txt)
fi

echo "Security group configured"
echo ""
echo "Creating keypairs: "

create-key-pair

echo ""
echo "Creating EC2 instance."
if [ ! -e ./ec2_instance/instance-id.txt ]; then
    create-ec2-instance ami-1a962263 ${SECURITY_GROUP_ID} ${THISDIR}/bootstrap-jenkins.sh ${PEM_NAME}
    echo "Created instance..."
fi
echo "Applying restrictions: "
authorize-access ${JENKINS_SECURITY_GROUP}
echo "Restrictions added"

echo ""
echo "Awaiting instance confirmation"

PUBLICNAME=$( cat ./$INSTANCE_DIR/instance-public-name.txt)
sleepUntilInstanceReady

echo ""
echo "Copying files to our new instance..."

set +e
scp -o StrictHostKeyChecking=no -i "./ec2_instance/${PEM_NAME}.pem" ec2-user@$(cat ./ec2_instance/instance-public-name.txt):/var/log/cloud-init-output.log ./ec2_instance/cloud-init-output.log
scp -o StrictHostKeyChecking=no -i "./ec2_instance/${PEM_NAME}.pem" ec2-user@$(cat ./ec2_instance/instance-public-name.txt):/var/log/user-data.log ./ec2_instance/user-data.log

aws ec2 associate-iam-instance-profile --instance-id $(cat ./ec2_instance/instance-id.txt) --iam-instance-profile Name=CICDServer-Instance-Profile

echo ""
echo "Setup of $PUBLICNAME complete"
echo ""
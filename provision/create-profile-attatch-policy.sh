#!/bin/bash
# This script sets up the aws environment
# Attatches a role policy to the StudentCICDServer

ARN="arn:aws:iam::aws:policy/AmazonEC2FullAccess"
aws iam attach-role-policy --role-name StudentCICDServer --policy-arn $ARN 

aws iam create-instance-profile --instance-profile-name CICDServer-Instance-Profile

aws iam add-role-to-instance-profile --role-name StudentCICDServer --instance-profile-name CICDServer-Instance-Profile
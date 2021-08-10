#!/bin/bash
set -e
set -x

STACK_NAME=$1
ALB_LISTENER_ARN=$2

if ! aws cloudformation describe-stacks --region ap-southeast-2 --stack-name $STACK_NAME 2>&1 > /dev/null
then
    finished_check=stack-create-complete
else
    finished_check=stack-update-complete
fi

aws cloudformation deploy \
    --region us-east-1 \
    --stack-name $STACK_NAME \
    --template-file service.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
    "DockerImage=581251645584.dkr.ecr.ap-southeast-2.amazonaws.com/example-webapp:$(git rev-parse HEAD)" \
    "VPC=vpc-099947a09e5912a54" \
    "Subnet=subnet-0ce37c59923f95e14" \
    "Cluster=default" \
    "Listener=$ALB_LISTENER_ARN"

aws cloudformation wait $finished_check --region ap-southeast-2 --stack-name $STACK_NAME

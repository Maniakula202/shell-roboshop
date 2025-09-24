#!/bin/bash

IMAGE_ID="ami-09c813fb71547fc4f"
SG="sg-0d7d38fd2dd9739a0"
ZONE_ID="Z04762511YRI8TCYP5ZSP"

for instance in $@
do 
    INSTANCE_ID=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type t3.micro --security-group-ids $SG --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi

    echo "$instance :: $IP"
done 
#!/bin/bash
# GMU AIT512 Honeypot Deployment Script
# Simplified Cowrie deployment for team project

# Create EC2 instance
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --instance-type t3.micro \
  --key-name your-key-pair \
  --security-group-ids sg-honeypot \
  --user-data file://honeypot-setup.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=GMU-Honeypot-Cowrie}]'

# Get instance IP
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=GMU-Honeypot-Cowrie" --query 'Reservations[0].Instances[0].InstanceId' --output text)
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "Honeypot deployed at: $PUBLIC_IP"
echo "SSH to honeypot: ssh -p 2222 root@$PUBLIC_IP"
echo "Monitor logs: ssh -i your-key.pem ubuntu@$PUBLIC_IP 'tail -f /opt/cowrie/var/log/cowrie/cowrie.log'"
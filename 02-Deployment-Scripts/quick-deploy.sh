#!/bin/bash
# Quick deployment script for Cowrie honeypot

# Set your key pair name (replace with your actual key pair name)
KEY_PAIR_NAME="gmu-honeypot-key"

# Deploy CloudFormation stack
aws cloudformation create-stack \
  --stack-name GMU-Honeypot-Stack \
  --template-body file://gmu-honeypot-stack.yaml \
  --parameters ParameterKey=KeyPairName,ParameterValue=$KEY_PAIR_NAME \
               ParameterKey=TeamIPRange,ParameterValue=0.0.0.0/0

echo "Deployment started. Check CloudFormation console for progress."
echo "Stack will take 3-5 minutes to complete."

# Wait for stack completion (optional)
echo "Waiting for stack completion..."
aws cloudformation wait stack-create-complete --stack-name GMU-Honeypot-Stack

# Get outputs
HONEYPOT_IP=$(aws cloudformation describe-stacks \
  --stack-name GMU-Honeypot-Stack \
  --query 'Stacks[0].Outputs[?OutputKey==`HoneypotPublicIP`].OutputValue' \
  --output text)

echo "=== Deployment Complete ==="
echo "Honeypot IP: $HONEYPOT_IP"
echo "Test connection: ssh -p 2222 root@$HONEYPOT_IP"
echo "View logs: ssh -i $KEY_PAIR_NAME.pem ubuntu@$HONEYPOT_IP 'sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log'"
#!/bin/bash
# Fix critical security issue: Restrict SSH management access

echo "=== Securing SSH Management Access ==="

# Get your current public IP
MY_IP=$(curl -s ifconfig.me)
echo "Your current IP: $MY_IP"

# Security Group ID from AWS introspection
SG_ID="sg-00adecc20174b901e"

# Add restricted SSH rule for your IP only
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr ${MY_IP}/32 \
    --description "SSH management access for team"

# Remove the dangerous open SSH rule
aws ec2 revoke-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

echo "✅ SSH access now restricted to your IP: $MY_IP"
echo "⚠️  Share this IP with teammates who need access"
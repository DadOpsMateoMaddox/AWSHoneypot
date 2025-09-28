#!/bin/bash
# Create security group for honeypot

# Create security group
aws ec2 create-security-group \
  --group-name honeypot-sg \
  --description "GMU Honeypot Security Group"

# Allow SSH honeypot (port 2222)
aws ec2 authorize-security-group-ingress \
  --group-name honeypot-sg \
  --protocol tcp \
  --port 2222 \
  --cidr 0.0.0.0/0

# Allow Telnet honeypot (port 2223)
aws ec2 authorize-security-group-ingress \
  --group-name honeypot-sg \
  --protocol tcp \
  --port 2223 \
  --cidr 0.0.0.0/0

# Allow management SSH (port 22) - restrict to your IP
aws ec2 authorize-security-group-ingress \
  --group-name honeypot-sg \
  --protocol tcp \
  --port 22 \
  --cidr YOUR_IP/32

echo "Security group created: honeypot-sg"
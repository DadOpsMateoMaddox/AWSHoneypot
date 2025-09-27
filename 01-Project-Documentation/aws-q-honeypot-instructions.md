# Amazon Q Instructions for GMU Honeypot Project Setup

## Project Overview
We need to deploy Cowrie SSH/Telnet honeypots on AWS EC2 for a George Mason University AIT512 Cybersecurity graduate program group project. Team of 4 students analyzing attack patterns.

## Required AWS Resources

### 1. EC2 Instance Configuration
- **Instance Type**: t3.micro (free tier eligible)
- **AMI**: Ubuntu 22.04 LTS
- **Storage**: 8GB GP3
- **Tags**: Name=GMU-Honeypot-Team4, Project=AIT512, Environment=Lab

### 2. Security Group Rules
- **Name**: honeypot-sg
- **Inbound Rules**:
  - Port 2222 (SSH honeypot): 0.0.0.0/0
  - Port 2223 (Telnet honeypot): 0.0.0.0/0  
  - Port 22 (Management SSH): Restrict to team IPs
  - Port 80 (Web interface): Team IPs only

### 3. Cowrie Honeypot Setup
- Install Cowrie from GitHub (cowrie/cowrie)
- Configure SSH on port 2222, Telnet on 2223
- Enable JSON logging to /opt/cowrie/var/log/cowrie/
- Set hostname to "gmu-server"
- Create cowrie system user for security

### 4. Monitoring & Logging
- CloudWatch logs integration
- Log rotation setup
- Basic attack analytics dashboard

### 5. Team Access
- IAM users: Abdul, Emmanuel, Roshan (already created)
- Group: AWSHoneypot with EC2FullAccess, IAMReadOnlyAccess
- Shared key pair for EC2 access

## Deployment Request
Please create all these resources and provide:
1. Public IP of honeypot instance
2. SSH commands for team access
3. Log monitoring instructions
4. Basic usage guide for the team

Budget limit: $50/month maximum
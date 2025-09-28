# Team Access Setup Guide

## AWS Account Configuration

### IAM Users Created
- **Abdul**: Console and programmatic access
- **Emmanuel**: Console and programmatic access  
- **Roshan**: Console and programmatic access
- **Kevin** (Team Lead): Root account access

### Group Permissions
- **Group Name**: AWSHoneypot
- **Attached Policies**:
  - `AmazonEC2FullAccess`
  - `IAMReadOnlyAccess`
  - `CloudWatchReadOnlyAccess`

### Access Information
- **AWS Account ID**: 314429811210
- **Sign-in URL**: https://314429811210.signin.aws.amazon.com/console
- **Region**: us-east-1 (primary)

## Team Member Instructions

### First Login
1. Go to the sign-in URL above
2. Enter your username (Abdul/Emmanuel/Roshan)
3. Use the temporary password provided
4. Set a new secure password
5. Enable MFA (recommended)

### Key Pair Access
- **Key Pair Name**: gmu-honeypot-key
- **Usage**: SSH access to EC2 instances
- **Security**: Keep private key secure, never share

### Shared Resources
- **Security Group**: gmu-honeypot-sg
- **EC2 Instance**: GMU-Honeypot-Cowrie
- **CloudWatch Logs**: /aws/ec2/honeypot

## Security Best Practices
- Use strong passwords
- Enable MFA on all accounts
- Never share access keys
- Log out when finished
- Report any suspicious activity

## Budget Monitoring
- Monthly limit: $50
- Alerts configured at $40
- Team lead receives notifications
- Monitor usage regularly
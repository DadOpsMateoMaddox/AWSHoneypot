# AWS CLI Setup for Security Management

## What You Need
- **SSH Key**: Already have (`gmu-honeypot-key.pem`) - for server access
- **AWS Access Key**: Need to create - for AWS management commands

## Step 1: Create AWS Access Key

1. **AWS Console** → **IAM** → **Users** → **Your Username**
2. **Security credentials** tab
3. **Create access key**
4. **Use case**: Command Line Interface (CLI)
5. **Download CSV** or copy both keys

## Step 2: Install AWS CLI (if not installed)

```bash
# In WSL terminal
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## Step 3: Configure AWS CLI

```bash
aws configure
```

**Enter these values:**
- **AWS Access Key ID**: [from step 1]
- **AWS Secret Access Key**: [from step 1]  
- **Default region name**: `us-east-1`
- **Default output format**: `json`

## Step 4: Test Configuration

```bash
# Test AWS CLI works
aws sts get-caller-identity

# Test EC2 access
aws ec2 describe-instances --instance-ids i-04d996c187504b547
```

## Step 5: Run Security Fix

```bash
cd /mnt/d/AWSHoneypot
chmod +x security-fix.sh
./security-fix.sh
```

## Key Differences Summary

| Type | Purpose | File/Location |
|------|---------|---------------|
| **SSH Key** | Connect to EC2 server | `gmu-honeypot-key.pem` |
| **AWS Access Key** | Manage AWS resources | Stored in `~/.aws/credentials` |

## Security Notes
- **SSH Key**: Share with teammates for server access
- **AWS Access Key**: Keep private, only for AWS management
- **Never commit either to Git repositories**
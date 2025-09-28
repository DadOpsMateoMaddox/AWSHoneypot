# SSH Key Setup for AWS Honeypot - Laptop Configuration

## Overview
This guide helps you set up SSH access to your AWS honeypot from your laptop using the same SSH key as your desktop.

## SSH Key Storage Location
**Recommended location:** `~/.ssh/honeypot-key.pem`

### Why this location?
- Standard SSH directory (`~/.ssh/`)
- Descriptive filename (`honeypot-key.pem`)
- Consistent with Linux/WSL conventions
- Easy to reference in scripts and aliases

## Step-by-Step Setup

### 1. Create SSH Directory (if it doesn't exist)
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

### 2. Copy Your SSH Key
Place your `honeypot-key.pem` file in `~/.ssh/honeypot-key.pem`

### 3. Set Proper Permissions
```bash
chmod 600 ~/.ssh/honeypot-key.pem
```

### 4. Test SSH Connection
```bash
ssh -i ~/.ssh/honeypot-key.pem ubuntu@44.222.200.1
```

### 5. Add to SSH Config (Optional but Recommended)
Create/edit `~/.ssh/config`:
```
Host honeypot
    HostName 44.222.200.1
    User ubuntu
    IdentityFile ~/.ssh/honeypot-key.pem
    StrictHostKeyChecking no
```

Then you can connect with just: `ssh honeypot`

## Git Repository Clone
```bash
# Clone the project
git clone https://github.com/YOUR_USERNAME/AWSHoneypot.git
cd AWSHoneypot

# Set up Git config if needed
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

## Troubleshooting
- If permission denied: Check file permissions (should be 600)
- If key format errors: Ensure it's the same key content as desktop
- If connection timeout: Check AWS security groups and instance status

---

## 🤖 COPILOT PROMPT FOR LAPTOP SETUP

Copy and paste this prompt to GitHub Copilot on your laptop:

---

**Copilot Setup Request:**

I need to set up SSH access to my AWS EC2 honeypot server from this laptop. Help me:

1. Create the proper `.ssh` directory structure in my home folder
2. Set up an SSH config file for easy access to my honeypot server (IP: 44.222.200.1, user: ubuntu)
3. Create a bash script that tests the SSH connection
4. Clone my AIT670 honeypot project from GitHub and set up the development environment
5. Add useful aliases for honeypot management to my bash profile

Server details:
- IP: 44.222.200.1
- User: ubuntu
- SSH key file: `~/.ssh/honeypot-key.pem` (I'll place the key file manually)
- Project repo: AWSHoneypot (contains Discord monitoring scripts)

Create all necessary files and provide commands to run. Make it production-ready with proper permissions and error handling.

---

This prompt will help Copilot generate the complete setup for your laptop!
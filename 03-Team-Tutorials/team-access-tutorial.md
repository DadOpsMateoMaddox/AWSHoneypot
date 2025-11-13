# Team Access Tutorial: GMU Honeypot EC2 Instance

> **💡 New**: For the best development experience, we recommend using VS Code Remote-SSH!  
> See [vscode-connection-guide.md](vscode-connection-guide.md) or [VSCODE-QUICK-START.md](../VSCODE-QUICK-START.md)

## Connection Options

**Option 1: VS Code Remote-SSH (Recommended)** 
- Full IDE experience directly on the EC2 instance
- Integrated terminal, file explorer, and editing
- Pre-configured tasks for common operations
- See: [vscode-connection-guide.md](vscode-connection-guide.md)

**Option 2: WSL2 + Traditional SSH (This Guide)**
- Command-line access via Windows Subsystem for Linux
- Good for quick checks and automated scripts
- Lighter weight than VS Code

---

## WSL2 Setup Instructions

## Prerequisites
- Windows 10/11 with WSL2 installed
- Basic terminal/SSH knowledge

## Step 1: Install WSL2 (if not already installed)
```powershell
# Run in PowerShell as Administrator
wsl --install
# Restart computer when prompted
```

## Step 2: Get the SSH Key
**Team Leader will provide:**
- File: `gmu-honeypot-key.pem`
- EC2 IP: `44.218.220.47`

**Save the key file to your WSL home directory:**
```bash
# In WSL terminal
mkdir -p ~/.ssh
# Copy the key file to ~/.ssh/gmu-honeypot-key.pem
chmod 400 ~/.ssh/gmu-honeypot-key.pem
```

## Step 3: Test Connection
```bash
# Test SSH connection
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# If successful, you'll see:
# [ec2-user@ip-172-31-21-182 ~]$
```

## Step 4: Set Up Environment Variables

After connecting, run the environment setup script:

```bash
# Clone the repository (if not done already)
cd ~
git clone https://github.com/DadOpsMateoMaddox/AWSHoneypot.git
cd AWSHoneypot

# Run the setup script
bash 02-Deployment-Scripts/setup_honeypot_env.sh
```

This sets up:
- Environment variables (HONEYPOT_USER, HONEYPOT_IP, LOCAL_ARCHIVE_DIR, etc.)
- Helpful aliases (cowrie-status, cowrie-logs, etc.)
- Helper functions (honeypot-info, create-archive, etc.)

## Step 5: Create Convenient Alias (Optional)
Add to your `~/.bashrc` in WSL for quick access:
```bash
# Edit bashrc
nano ~/.bashrc

# Add this line at the end:
alias ec2='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47'

# Save and reload
source ~/.bashrc
```

## Step 6: Quick Access
Now you can connect with just:
```bash
ec2
```

## Using Environment Variables

After running the setup script (Step 4), you have access to:

```bash
# Environment variables
echo $HONEYPOT_USER        # ec2-user
echo $HONEYPOT_IP          # 44.218.220.47
echo $LOCAL_ARCHIVE_DIR    # ~/cowrie_archives
echo $COWRIE_LOG_DIR       # /opt/cowrie/var/log/cowrie

# Helper aliases
cowrie-status      # Check Cowrie status
cowrie-logs        # View live logs with jq formatting
cowrie-start       # Start Cowrie
cowrie-stop        # Stop Cowrie

# Analysis functions
honeypot-info      # Show honeypot dashboard
count-events       # Count events by type
recent-attackers   # Show recent attacker IPs
create-archive     # Pull and archive all logs

# Navigation
cd-logs            # Jump to log directory
cd-scripts         # Jump to scripts directory
cd-archives        # Jump to archive directory
```

## Common Manual Commands

```bash
# Check Cowrie status (manual)
sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py status

# View Cowrie logs (raw)
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log

# Test honeypot (from another terminal)
ssh -p 2222 root@44.218.220.47

# Pull and archive logs
cd ~/AWSHoneypot/02-Deployment-Scripts
sudo ./pull_and_archive_cowrie_logs.sh --convert-pcap
```

## Troubleshooting

**Environment Variables Not Set:**
```bash
# Manually load environment
source ~/.honeypot_env

# Or re-run setup
bash ~/AWSHoneypot/02-Deployment-Scripts/setup_honeypot_env.sh
```

**Permission Denied Error:**
```bash
# Fix key permissions
chmod 400 ~/.ssh/gmu-honeypot-key.pem
```

**Connection Refused:**
- Check if EC2 instance is running in AWS Console
- Verify security group allows SSH (port 22) from your IP

**Wrong User:**
- Use `ec2-user`, not `ubuntu` or `root`
- Amazon Linux 2 uses `ec2-user` as default

## Security Notes
- **Never share the private key publicly**
- **Only use for project purposes**
- **Don't modify system files without team coordination**
- **Always use `sudo -u cowrie` for Cowrie operations**

## Project Structure
```
/opt/cowrie/          # Main Cowrie directory
├── src/              # Source code
├── etc/              # Configuration files
├── var/log/cowrie/   # Log files
└── honeyfs/          # Fake filesystem for honeypot
```

## Team Coordination
- **Coordinate Cowrie restarts** - notify team before stopping
- **Share interesting log findings** in team chat
- **Document any configuration changes**
- **Use screen/tmux for long-running processes**

## Quick Reference
| Command | Purpose |
|---------|---------|
| `ec2` | Connect to EC2 instance |
| `sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log` | View live logs |
| `ssh -p 2222 root@44.222.200.1` | Test honeypot |
| `sudo netstat -tlnp \| grep 2222` | Check if honeypot is running |

---
**Questions?** Contact the team leader or check the project documentation.
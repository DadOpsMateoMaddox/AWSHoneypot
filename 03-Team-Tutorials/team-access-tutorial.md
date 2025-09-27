# Team Access Tutorial: GMU Honeypot EC2 Instance

## Prerequisites
- Windows 10/11 with WSL2 installed
- VS Code with Remote-WSL extension
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
- EC2 IP: `44.222.200.1`

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
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.222.200.1

# If successful, you'll see:
# [ec2-user@ip-172-31-21-182 ~]$
```

## Step 4: Create Convenient Alias
Add to your `~/.bashrc`:
```bash
# Edit bashrc
nano ~/.bashrc

# Add this line at the end:
alias ec2='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.222.200.1'

# Save and reload
source ~/.bashrc
```

## Step 5: Quick Access
Now you can connect with just:
```bash
ec2
```

## Common Commands on EC2
```bash
# Check Cowrie status
sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py status

# View Cowrie logs
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log

# Test honeypot (from another terminal)
ssh -p 2222 root@44.222.200.1

# Stop/Start Cowrie
sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py stop
sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py start
```

## Troubleshooting

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
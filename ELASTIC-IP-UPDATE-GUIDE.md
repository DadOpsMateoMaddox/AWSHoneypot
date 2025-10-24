# 🔧 CRITICAL: Elastic IP Update & Verification Guide

## 🚨 What Changed

Our GMU Honeypot EC2 instance now has a **permanent Elastic IP** that will never change.

### Old IPs (DO NOT USE):
- ❌ `44.222.200.1` (old dynamic IP)
- ❌ `18.223.22.36` (temporary dynamic IP)
- ❌ `ec2-44-222-200-1.compute-1.amazonaws.com` (old hostname)

### New Permanent IP:
- ✅ **`44.218.220.47`** (Elastic IP - will NEVER change)

### Instance Details:
- **Instance ID**: `i-04d996c187504b547`
- **Instance Type**: `t3.micro`
- **Region**: `us-east-1c`
- **AMI**: Ubuntu 22.04
- **SSH Username**: **`ubuntu`** (NOT `ec2-user`)
- **Security Group**: `gmu-honeypot-sg`
- **Key**: `gmu-honeypot-key.pem`

---

## ✅ Immediate Actions Required

### 1. Update Your SSH Connection

**New SSH command:**
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

**Key changes:**
- Username is now `ubuntu` (was `ec2-user`)
- IP is now `44.218.220.47` (was `44.222.200.1`)

### 2. Update Your Bash Aliases

**Add/update in your `~/.bashrc`:**
```bash
alias ssh-honeypot='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47'
alias ec2='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47'
```

**Then reload:**
```bash
source ~/.bashrc
```

### 3. Update SSH Config (if you use one)

**In `~/.ssh/config`:**
```
Host honeypot
    HostName 44.218.220.47
    User ubuntu
    IdentityFile ~/.ssh/gmu-honeypot-key.pem
    StrictHostKeyChecking no
```

Then you can simply type: `ssh honeypot`

### 4. Update Termius / GUI SSH Clients

**Settings:**
- Host: `44.218.220.47`
- Username: `ubuntu`
- Port: `22`
- Authentication: Key-based
- Key file: `gmu-honeypot-key.pem`

---

## 🧪 Verification Checklist

Run these commands to verify everything works:

### ✅ 1. SSH Connection Test
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'echo "✅ SSH connection successful!"'
```
**Expected output:** `✅ SSH connection successful!`

### ✅ 2. Cowrie Honeypot Test
```bash
# Test that Cowrie is running
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo systemctl status cowrie --no-pager'
```
**Expected:** Status should show `active (running)`

### ✅ 3. Honeypot Port Test (from external)
```bash
# This should connect to the FAKE SSH honeypot
ssh -p 2222 root@44.218.220.47
```
**Expected:** You'll see a fake SSH prompt. Try logging in with `root:password` to test.

### ✅ 4. Discord Monitor Test
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo systemctl status cowrie-discord-monitor --no-pager'
```
**Expected:** Status should show `active (running)`

### ✅ 5. View Recent Honeypot Activity
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo tail -n 20 /opt/cowrie/var/log/cowrie/cowrie.json'
```
**Expected:** JSON log entries showing honeypot activity

---

## 🔍 What Needs Updating on EC2

**If you're the admin**, these may need updates on the EC2 instance itself:

### 1. Cowrie Configuration
```bash
# Check if Cowrie config references any IPs
sudo grep -r "44.222.200" /opt/cowrie/etc/
sudo grep -r "18.223.22" /opt/cowrie/etc/

# Edit if needed
sudo nano /opt/cowrie/etc/cowrie.cfg
```

Look for sections like:
- `[ssh]` → `listen_endpoints` (should be `tcp:2222:interface=0.0.0.0`)
- `[telnet]` → `listen_endpoints` (if enabled)

### 2. Discord Monitor Config
```bash
# Check Discord monitor config
sudo cat /opt/cowrie/discord-monitor/discord_config.json

# Verify webhook URL is set correctly
# Restart if config was changed
sudo systemctl restart cowrie-discord-monitor
```

### 3. Security Group Rules
**Verify in AWS Console:**
- Inbound rule for SSH (port 22) from your IPs
- Inbound rule for honeypot (port 2222) from `0.0.0.0/0`
- Outbound rules allow HTTPS (for Discord webhooks)

### 4. Test Discord Alerts
```bash
# SSH to EC2 and run test
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# Once connected, test webhook
cd /opt/cowrie/discord-monitor
sudo -u cowrie python3 test_webhook.py
```
**Expected:** Test message appears in Discord channel.

---

## 🚀 Quick Commands Reference

### Connection Commands
```bash
# SSH to EC2 (admin)
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# Test honeypot (external attacker simulation)
ssh -p 2222 root@44.218.220.47

# Copy files TO EC2
scp -i ~/.ssh/gmu-honeypot-key.pem /local/file ec2-user@44.218.220.47:~/

# Copy files FROM EC2
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47:/remote/file ./

# View Cowrie logs remotely
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json'
```

### Service Management (on EC2)
```bash
# Check Cowrie status
sudo systemctl status cowrie

# Restart Cowrie
sudo systemctl restart cowrie

# Check Discord monitor
sudo systemctl status cowrie-discord-monitor

# View Discord monitor logs
sudo journalctl -u cowrie-discord-monitor -f

# Restart Discord monitor
sudo systemctl restart cowrie-discord-monitor
```

### Log Analysis (on EC2)
```bash
# View recent connections
sudo jq -r 'select(.eventid=="cowrie.session.connect") | .src_ip' /opt/cowrie/var/log/cowrie/cowrie.json | tail -20

# View recent commands
sudo jq -r 'select(.eventid=="cowrie.command.input") | .input' /opt/cowrie/var/log/cowrie/cowrie.json | tail -20

# Count unique attacker IPs
sudo jq -r 'select(.eventid=="cowrie.session.connect") | .src_ip' /opt/cowrie/var/log/cowrie/cowrie.json | sort -u | wc -l
```

---

## ❓ Troubleshooting

### Problem: "Permission denied (publickey)"
**Solution:**
- Verify you're using the correct key file
- Check permissions: `chmod 600 ~/.ssh/gmu-honeypot-key.pem`
- Verify username is `ubuntu` (not `ec2-user`)

### Problem: "Connection timed out"
**Solution:**
- Verify IP is correct: `44.218.220.47`
- Check security group allows your IP on port 22
- Verify instance is running in AWS Console

### Problem: Discord alerts not working
**Solution:**
```bash
# Check service status
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo systemctl status cowrie-discord-monitor'

# View logs for errors
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo journalctl -u cowrie-discord-monitor -n 100'

# Test webhook manually
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
cd /opt/cowrie/discord-monitor
sudo -u cowrie python3 test_webhook.py
```

### Problem: Honeypot (port 2222) not responding
**Solution:**
```bash
# Check if Cowrie is running
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo systemctl status cowrie'

# Check if port is listening
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo netstat -tuln | grep 2222'

# Restart Cowrie
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo systemctl restart cowrie'
```

---

## 📊 What Was Updated in the Repo

Files updated with new IP `44.218.220.47` and username `ubuntu`:

**Configuration Files:**
- `.bashrc_ubuntu`
- `.bashrc_honeypot_additions`

**Documentation:**
- `README.md`
- `03-Team-Tutorials/beginner-team-tutorial.md`
- `03-Team-Tutorials/team-access-tutorial.md`
- `Team-Log-Analysis-Guide.md`
- `Discord-Progress-Update.md`

**Deployment Scripts:**
- `02-Deployment-Scripts/fix-bashrc.sh`
- `02-Deployment-Scripts/README.md`
- `02-Deployment-Scripts/laptop_setup.sh`
- `02-Deployment-Scripts/quick_setup_discord.sh`
- `03-Team-Tutorials/Discord-Webhook-Setup.md`

**Static IP Documentation:**
- `02-Deployment-Scripts/To_Be-Static-or_Not-To_BeStatic_That-is-the-question_and-Answer.md`
- `02-Deployment-Scripts/WTF-Happened-And-Why.md`

---

## 🎯 Key Takeaways

1. ✅ **IP is now permanent** — `44.218.220.47` will never change
2. ✅ **Username changed** — use `ubuntu`, not `ec2-user`
3. ✅ **Update all your configs** — SSH config, aliases, Termius, etc.
4. ✅ **Elastic IP is free** — as long as it's attached to a running instance
5. ✅ **Test your connection** — verify everything works before the next class

---

## 📞 Need Help?

- **Check Discord** — #honeypot-help channel
- **Contact Team Lead** — Post in team channel
- **Review Docs** — See `03-Team-Tutorials/` folder

---

**Last Updated:** October 12, 2025  
**Elastic IP Assigned:** October 11, 2025  
**Instance:** i-04d996c187504b547  
**IP:** 44.218.220.47 (permanent)

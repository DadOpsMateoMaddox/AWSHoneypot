# ✅ IP Update Implementation Summary

## What Was Completed

### 1. ✅ Repository-Wide IP Updates

**Old IPs Replaced:**
- `44.222.200.1` → `44.218.220.47`
- `18.223.22.36` → `44.218.220.47`
- `ec2-44-222-200-1.compute-1.amazonaws.com` → `44.218.220.47`

**Username Updates:**
- `ec2-user` → `ubuntu` (throughout the repository)

### 2. ✅ Files Updated

**Bash Configuration:**
- `.bashrc_ubuntu` - Updated SSH aliases
- `.bashrc_honeypot_additions` - Updated connection aliases and info function

**Main Documentation:**
- `README.md` - Updated EC2 infrastructure details
- `Team-Log-Analysis-Guide.md` - Updated all SSH/SCP commands
- `Discord-Progress-Update.md` - Updated connection instructions

**Team Tutorials:**
- `03-Team-Tutorials/beginner-team-tutorial.md` - Updated SSH examples
- `03-Team-Tutorials/team-access-tutorial.md` - Updated connection info
- `03-Team-Tutorials/Discord-Webhook-Setup.md` - Updated deployment commands

**Deployment Scripts:**
- `02-Deployment-Scripts/fix-bashrc.sh` - Updated aliases
- `02-Deployment-Scripts/quick_setup_discord.sh` - Updated IP reference
- `02-Deployment-Scripts/laptop_setup.sh` - Updated SSH config template

**Documentation:**
- `02-Deployment-Scripts/To_Be-Static-or_Not-To_BeStatic_That-is-the-question_and-Answer.md` - Elastic IP explanation
- `ELASTIC-IP-UPDATE-GUIDE.md` - **NEW** comprehensive verification guide

### 3. ✅ Instance Details Updated

**New Configuration:**
```
Instance ID: i-04d996c187504b547
Instance Type: t3.micro
Region: us-east-1c
AMI: Ubuntu 22.04
Elastic IP: 44.218.220.47 (permanent)
Username: ubuntu
Key: gmu-honeypot-key.pem
Security Group: gmu-honeypot-sg
```

---

## 🚨 Actions Still Required

### On EC2 Instance (SSH and verify):

```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

#### 1. Check Cowrie Configuration
```bash
# Search for any hardcoded old IPs in Cowrie config
sudo grep -r "44.222.200" /opt/cowrie/etc/
sudo grep -r "18.223.22" /opt/cowrie/etc/

# Review main config
sudo cat /opt/cowrie/etc/cowrie.cfg | grep -A 5 "\[ssh\]"
```

**Expected:** Should show `listen_endpoints = tcp:2222:interface=0.0.0.0` (binds to all interfaces)

#### 2. Verify Discord Monitor Configuration
```bash
# Check webhook config
sudo cat /opt/cowrie/discord-monitor/discord_config.json

# Verify service is running
sudo systemctl status cowrie-discord-monitor --no-pager

# View recent logs
sudo journalctl -u cowrie-discord-monitor -n 50 --no-pager
```

**Action if needed:**
- If webhook URL is invalid/placeholder, update it
- Restart service: `sudo systemctl restart cowrie-discord-monitor`

#### 3. Test Discord Webhook
```bash
cd /opt/cowrie/discord-monitor
sudo -u cowrie python3 test_webhook.py
```

**Expected:** "✅ Test successful! Check Discord."

#### 4. Verify Cowrie is Running
```bash
# Check service status
sudo systemctl status cowrie --no-pager

# Verify port 2222 is listening
sudo netstat -tuln | grep 2222

# View recent activity
sudo tail -20 /opt/cowrie/var/log/cowrie/cowrie.json
```

#### 5. Test from External Connection
From your LOCAL machine (not on EC2):
```bash
# Test honeypot is accessible
ssh -p 2222 root@44.218.220.47
```

Try logging in with `root` / `password` to generate test activity.

---

## 📋 Team Member Actions

### Each team member should:

1. **Pull latest repo changes:**
```bash
cd ~/AWSHoneypot  # or your repo location
git pull origin main
```

2. **Update bash aliases:**
```bash
# Reload updated aliases
source ~/.bashrc

# Or manually add if not using repo bashrc files:
echo "alias ssh-honeypot='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47'" >> ~/.bashrc
source ~/.bashrc
```

3. **Test connection:**
```bash
ssh-honeypot
# or
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

4. **Update Termius/GUI clients** (if used):
   - Host: `44.218.220.47`
   - User: `ubuntu`
   - Port: `22`
   - Key: `gmu-honeypot-key.pem`

5. **Read the verification guide:**
   - Review: `ELASTIC-IP-UPDATE-GUIDE.md`
   - Follow verification checklist

---

## 🧪 Verification Commands

Run these to confirm everything works:

```bash
# 1. SSH connection test
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'echo "✅ Connection successful"'

# 2. Check Cowrie status
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo systemctl status cowrie --no-pager | head -15'

# 3. Check Discord monitor
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo systemctl status cowrie-discord-monitor --no-pager | head -15'

# 4. View recent honeypot activity
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'sudo tail -10 /opt/cowrie/var/log/cowrie/cowrie.json'

# 5. Test honeypot from external (generates test alert)
ssh -p 2222 root@44.218.220.47
```

---

## 📊 What Changed on the Honeypot

### Why Alerts May Have Stopped

The original issue: **Discord alerts stopped working**

**Possible causes:**
1. **Webhook URL expired/revoked** - Discord webhooks can be regenerated/deleted
2. **Service crashed** - `cowrie-discord-monitor` may have stopped
3. **Config file missing** - `/opt/cowrie/discord-monitor/discord_config.json` not configured
4. **Network issues** - Outbound HTTPS blocked or DNS resolution failing
5. **Rate limiting** - Discord API rate limits hit

### Diagnostic Steps (run on EC2):

```bash
# 1. Check if service is running
sudo systemctl status cowrie-discord-monitor --no-pager

# 2. View service logs for errors
sudo journalctl -u cowrie-discord-monitor --no-pager -n 200

# 3. Check config file
sudo cat /opt/cowrie/discord-monitor/discord_config.json

# 4. Test webhook manually
cd /opt/cowrie/discord-monitor
sudo -u cowrie python3 test_webhook.py

# 5. Check network connectivity
curl -I https://discord.com/api/webhooks/
```

### Fix Discord Alerts (if broken):

```bash
# 1. SSH to EC2
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# 2. Update webhook URL in config (if needed)
sudo nano /opt/cowrie/discord-monitor/discord_config.json
# Update "discord_webhook_url" with valid webhook

# 3. Restart service
sudo systemctl restart cowrie-discord-monitor

# 4. Follow logs to verify
sudo journalctl -u cowrie-discord-monitor -f

# 5. Test from external (generate activity)
# From another terminal:
ssh -p 2222 root@44.218.220.47
# Try: username "admin", password "password"
```

---

## 🎯 Success Criteria

**Repository Updates:** ✅
- [x] All IP references updated to `44.218.220.47`
- [x] All usernames updated to `ubuntu`
- [x] Bash aliases updated
- [x] Documentation updated
- [x] Deployment scripts updated
- [x] Verification guide created

**EC2 Instance Verification:** ⏳ (needs testing)
- [ ] Cowrie is running and accessible on port 2222
- [ ] Discord monitor service is running
- [ ] Webhook test succeeds
- [ ] Team members can SSH with new IP
- [ ] Alerts appear in Discord channel

**Team Coordination:** ⏳ (in progress)
- [ ] All team members notified
- [ ] Everyone has pulled latest repo changes
- [ ] Everyone has tested SSH connection
- [ ] Discord channel receiving alerts

---

## 📞 Next Steps

1. **Test on EC2** - SSH in and run verification commands above
2. **Fix Discord alerts** - If webhook test fails, get new webhook URL
3. **Notify team** - Share `ELASTIC-IP-UPDATE-GUIDE.md` in Discord
4. **Monitor for 24h** - Verify alerts are working consistently
5. **Document learnings** - Update project docs with troubleshooting tips

---

## 📁 New Files Created

1. **`ELASTIC-IP-UPDATE-GUIDE.md`** - Comprehensive team guide with:
   - What changed and why
   - Step-by-step update instructions
   - Verification checklist
   - Troubleshooting section
   - Quick command reference

2. **`IP-UPDATE-SUMMARY.md`** (this file) - Implementation tracking

---

**Implementation Date:** October 12, 2025  
**Elastic IP:** 44.218.220.47 (assigned October 11, 2025)  
**Repository:** AWSHoneypot  
**Branch:** Updated in current branch  
**Status:** Repository updates complete, EC2 verification pending

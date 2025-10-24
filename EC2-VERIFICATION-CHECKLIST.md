# 🔧 EC2 Instance Checklist - Post IP Change

## Overview

The repository has been updated with the new Elastic IP (`44.218.220.47`). This checklist covers actions needed **on the EC2 instance itself** to verify everything is working and fix any issues.

---

## ✅ Step-by-Step EC2 Verification

### Step 1: Connect to EC2

```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

---

### Step 2: Check Cowrie Service

```bash
# Check if Cowrie is running
sudo systemctl status cowrie --no-pager

# Should show: "Active: active (running)"
```

**If not running:**
```bash
sudo systemctl start cowrie
sudo systemctl enable cowrie
```

---

### Step 3: Verify Cowrie is Listening on Port 2222

```bash
# Check if port 2222 is open
sudo netstat -tuln | grep 2222

# Should show: tcp 0 0 0.0.0.0:2222 LISTEN
```

**If not listening:**
```bash
# Check Cowrie config
sudo cat /opt/cowrie/etc/cowrie.cfg | grep -A 5 "\[ssh\]"

# Should have: listen_endpoints = tcp:2222:interface=0.0.0.0
# Restart if needed
sudo systemctl restart cowrie
```

---

### Step 4: Check Discord Monitor Service

```bash
# Check service status
sudo systemctl status cowrie-discord-monitor --no-pager

# View recent logs
sudo journalctl -u cowrie-discord-monitor -n 50 --no-pager
```

**Look for:**
- ✅ "Active: active (running)"
- ✅ No error messages in logs
- ❌ Any HTTP errors (401, 404, 429)
- ❌ Any Python exceptions

---

### Step 5: Verify Discord Webhook Configuration

```bash
# Check config file exists and is readable
sudo cat /opt/cowrie/discord-monitor/discord_config.json
```

**Verify:**
- `discord_webhook_url` is NOT "REPLACE_WITH_YOUR_WEBHOOK_URL"
- `discord_webhook_url` looks like: `https://discord.com/api/webhooks/...`
- `cowrie_log_path` points to: `/opt/cowrie/var/log/cowrie/cowrie.json`

**If webhook URL is invalid/missing:**
```bash
# Get new webhook from Discord:
# Server Settings → Integrations → Webhooks → New Webhook

# Update config
sudo nano /opt/cowrie/discord-monitor/discord_config.json

# Update the "discord_webhook_url" value
# Save: Ctrl+O, Enter, Ctrl+X

# Ensure correct permissions
sudo chown cowrie:cowrie /opt/cowrie/discord-monitor/discord_config.json
sudo chmod 600 /opt/cowrie/discord-monitor/discord_config.json

# Restart service
sudo systemctl restart cowrie-discord-monitor
```

---

### Step 6: Test Discord Webhook

```bash
# Navigate to monitor directory
cd /opt/cowrie/discord-monitor

# Run test script as cowrie user
sudo -u cowrie python3 test_webhook.py
```

**Expected output:**
```
✅ Test successful! Check Discord.
```

**If it fails:**
- Status `401/403/404` → Webhook URL is invalid, get new one
- Status `429` → Rate limited, wait a few minutes
- Connection error → Check outbound HTTPS is allowed in security group
- Other error → Check logs: `sudo journalctl -u cowrie-discord-monitor -n 100`

---

### Step 7: Verify Network Connectivity

```bash
# Test DNS resolution
getent hosts discord.com

# Test HTTPS connectivity
curl -I https://discord.com/api/webhooks/

# Should return: HTTP/2 401 (unauthorized, but connection works)
```

**If DNS fails:**
```bash
# Check /etc/resolv.conf
cat /etc/resolv.conf

# Should have nameserver entries
```

**If HTTPS fails:**
- Check security group allows outbound HTTPS (port 443)
- Check instance has internet gateway/NAT configured

---

### Step 8: Check for Hardcoded IPs in Cowrie Config

```bash
# Search for old IPs
sudo grep -r "44.222.200" /opt/cowrie/etc/
sudo grep -r "18.223.22" /opt/cowrie/etc/
sudo grep -r "44-222-200" /opt/cowrie/etc/
```

**Expected:** No results (no hardcoded IPs)

**If found:**
```bash
# Edit the config file(s)
sudo nano /opt/cowrie/etc/cowrie.cfg

# Update or remove hardcoded IPs
# For listen addresses, use: 0.0.0.0 (all interfaces)

# Restart Cowrie
sudo systemctl restart cowrie
```

---

### Step 9: Check Cowrie Logs for Recent Activity

```bash
# View last 20 lines of JSON logs
sudo tail -20 /opt/cowrie/var/log/cowrie/cowrie.json

# OR view in pretty JSON format
sudo tail -20 /opt/cowrie/var/log/cowrie/cowrie.json | jq .
```

**Look for:**
- Recent connection attempts (`cowrie.session.connect`)
- Commands executed (`cowrie.command.input`)
- Login attempts (`cowrie.login.success` or `cowrie.login.failed`)

**If no activity:**
- Honeypot may not be accessible from internet
- Check security group allows inbound on port 2222 from `0.0.0.0/0`

---

### Step 10: Test External Access (from your local machine)

**Exit EC2 SSH**, then from your local terminal:

```bash
# Test honeypot is accessible
ssh -p 2222 root@44.218.220.47

# Try logging in with:
# Username: admin
# Password: password

# OR try:
# Username: root  
# Password: 123456
```

**Expected:**
- Connection succeeds
- You see a fake SSH prompt
- After login attempt, you can type commands
- Commands are logged in Cowrie
- Discord alert appears (if monitor is working)

**If connection fails:**
- Check security group allows inbound TCP 2222 from `0.0.0.0/0`
- Check Cowrie is running: `sudo systemctl status cowrie`
- Check port is listening: `sudo netstat -tuln | grep 2222`

---

### Step 11: Monitor Discord for Test Alert

After the honeypot test above, check your Discord channel:

**Expected:**
- New connection alert appears
- Shows your IP address
- Shows login attempts
- Shows commands you typed

**If no alert:**
- Check Discord monitor logs: `sudo journalctl -u cowrie-discord-monitor -f`
- Run webhook test again: `sudo -u cowrie python3 /opt/cowrie/discord-monitor/test_webhook.py`
- Verify webhook URL in config is correct

---

### Step 12: Check System Resources

```bash
# Check disk space
df -h

# Check memory
free -h

# Check CPU/processes
top -bn1 | head -20
```

**Verify:**
- Disk usage < 80%
- Memory available
- Cowrie and python processes running

---

### Step 13: Verify Security Group Rules (in AWS Console)

**Inbound Rules should include:**
- SSH (22) from your IP(s) - for admin access
- Custom TCP (2222) from `0.0.0.0/0` - for honeypot

**Outbound Rules should include:**
- HTTPS (443) to `0.0.0.0/0` - for Discord webhooks
- All traffic (or HTTP/HTTPS at minimum)

---

### Step 14: Set up Monitoring/Alerting (Optional)

```bash
# Create a simple health check script
sudo tee /usr/local/bin/honeypot-health-check.sh > /dev/null <<'EOF'
#!/bin/bash
systemctl is-active cowrie || echo "❌ Cowrie is down!"
systemctl is-active cowrie-discord-monitor || echo "❌ Discord monitor is down!"
netstat -tuln | grep -q ":2222" || echo "❌ Port 2222 not listening!"
EOF

sudo chmod +x /usr/local/bin/honeypot-health-check.sh

# Test it
sudo /usr/local/bin/honeypot-health-check.sh

# Add to cron for hourly checks (optional)
echo "0 * * * * /usr/local/bin/honeypot-health-check.sh" | sudo crontab -
```

---

## 🎯 Success Criteria

All checks should pass:

- [x] SSH connection works with `ec2-user@44.218.220.47`
- [x] Cowrie service is active and running
- [x] Port 2222 is listening
- [x] Discord monitor service is active and running
- [x] Discord webhook test succeeds (✅ message in channel)
- [x] No hardcoded old IPs in Cowrie config
- [x] External honeypot connection works (port 2222)
- [x] Test attack generates Discord alert
- [x] Security group rules are correct
- [x] System resources are healthy

---

## 🚨 Common Issues & Fixes

### Issue: Cowrie won't start

```bash
# Check logs for errors
sudo journalctl -u cowrie -n 100 --no-pager

# Common fixes:
# 1. Check Python virtualenv
sudo su - cowrie
source /opt/cowrie/cowrie-env/bin/activate
python --version  # Should be Python 3.x

# 2. Check file permissions
sudo chown -R cowrie:cowrie /opt/cowrie/
```

### Issue: Discord webhook returns 404

**Solution:** Webhook URL was deleted or regenerated in Discord
1. Go to Discord → Server Settings → Integrations → Webhooks
2. Create new webhook or copy existing one
3. Update `/opt/cowrie/discord-monitor/discord_config.json`
4. Restart service: `sudo systemctl restart cowrie-discord-monitor`

### Issue: No attackers connecting

**Solutions:**
1. Verify port 2222 open in security group
2. Honeypot takes time to be discovered (up to 24-48 hours)
3. Manually test from external network
4. Check if IP is in blocklists (rare for new IPs)

### Issue: Too many alerts / Discord rate limiting

**Solution:** Adjust alert levels in config:
```bash
sudo nano /opt/cowrie/discord-monitor/discord_config.json

# Set some alerts to false:
"alert_levels": {
  "login_failed": false,  # Turn off failed login alerts
  "session_start": false,
  "session_end": false
}

# Restart
sudo systemctl restart cowrie-discord-monitor
```

---

## 📊 Ongoing Monitoring Commands

```bash
# Watch live honeypot activity
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json

# Watch Discord monitor logs
sudo journalctl -u cowrie-discord-monitor -f

# Check attack statistics
sudo jq -r 'select(.eventid=="cowrie.session.connect") | .src_ip' \
  /opt/cowrie/var/log/cowrie/cowrie.json | sort | uniq -c | sort -rn | head -20
```

---

## 📝 Notes

- This Elastic IP (`44.218.220.47`) will remain permanent
- Regular monitoring recommended (daily for first week)
- Discord webhook URLs can expire if regenerated
- Cowrie logs rotate automatically (check `/opt/cowrie/etc/cowrie.cfg`)
- Consider setting up CloudWatch metrics for alerting

---

**Completed by:** ________________  
**Date:** ________________  
**All checks passed:** [ ] Yes [ ] No  
**Issues found:** ______________________________

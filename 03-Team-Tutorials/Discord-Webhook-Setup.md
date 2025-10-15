# Discord Webhook Integration for Cowrie Honeypot

## Overview

This system provides real-time Discord notifications for activities detected by our Cowrie SSH honeypot. When attackers connect to our honeypot, their actions are immediately reported to our Discord channel, allowing the team to monitor threats in real-time.

## Team Setup Guide

### Step 1: Create Discord Webhook

1. **Go to your Discord server**
2. **Right-click on the channel** where you want notifications
3. **Select "Edit Channel"**
4. **Go to "Integrations" tab**
5. **Click "Create Webhook"**
6. **Copy the Webhook URL** - this is what you'll need!

⚠️ **SECURITY NOTE**: Never commit webhook URLs to git repositories!

### Step 2: Deploy to AWS EC2 Instance

1. **Upload files to your honeypot server:**
   ```bash
   scp -i your-key.pem discord_* ubuntu@3.140.96.146:~/
   scp -i your-key.pem requirements.txt ubuntu@3.140.96.146:~/
   scp -i your-key.pem deploy_discord_monitor.sh ubuntu@3.140.96.146:~/
   ```

2. **SSH into your server:**
   ```bash
   ssh -i your-key.pem ubuntu@3.140.96.146
   ```

3. **Run the deployment script:**
   ```bash
   chmod +x deploy_discord_monitor.sh
   sudo ./deploy_discord_monitor.sh
   ```

### Step 3: Configure Webhook

1. **Edit the configuration file:**
   ```bash
   sudo nano /opt/cowrie/discord-monitor/discord_config.json
   ```

2. **Replace the webhook URL:**
   ```json
   {
     "discord_webhook_url": "https://discord.com/api/webhooks/YOUR_ACTUAL_WEBHOOK_URL_HERE",
     ...
   }
   ```

3. **Test the webhook:**
   ```bash
   sudo -u cowrie python3 /opt/cowrie/discord-monitor/test_webhook.py
   ```

### Step 4: Start Monitoring

1. **Enable and start the service:**
   ```bash
   sudo systemctl enable cowrie-discord-monitor
   sudo systemctl start cowrie-discord-monitor
   ```

2. **Check status:**
   ```bash
   sudo systemctl status cowrie-discord-monitor
   ```

3. **View live logs:**
   ```bash
   sudo journalctl -u cowrie-discord-monitor -f
   ```

## Alert Types

### 🚨 Critical Alerts (Red)
- **Successful logins** - Someone broke into the honeypot!
- **File uploads** - Attacker is trying to install malware

### ⚠️ Warning Alerts (Orange)
- **Suspicious commands** - Interesting commands being executed
- **File downloads** - Attacker trying to steal files

### 💻 Information Alerts (Blue)
- **Failed login attempts** - Normal brute force attempts
- **Regular commands** - Basic system exploration

## Configuration Options

### Alert Levels
You can customize which events trigger notifications:

```json
"alert_levels": {
  "login_success": true,     // 🚨 ALWAYS keep this true!
  "login_failed": false,     // Set to true if you want all failed attempts
  "command_executed": true,  // Commands executed by attackers
  "file_upload": true,       // 🚨 ALWAYS keep this true!
  "file_download": true,     // File download attempts
  "session_start": false,    // New connections (can be spammy)
  "session_end": false       // Session disconnections
}
```

### Interesting Commands
Commands that trigger high-priority alerts:
- System reconnaissance: `whoami`, `id`, `uname`, `ps`
- Network tools: `wget`, `curl`, `nc`, `nmap`
- Privilege escalation: `sudo`, `su`, `passwd`
- File manipulation: `cat /etc/passwd`, `cat /etc/shadow`
- And many more...

## Team Monitoring Strategy

### Discord Channel Organization
- **#honeypot-alerts** - Main alert channel
- **#honeypot-critical** - Only successful logins and file uploads
- **#honeypot-analysis** - Team discussion about threats

### Response Procedures
1. **When you see an alert**, acknowledge it with a 👀 reaction
2. **For critical alerts**, investigate immediately:
   - Check what commands were run
   - Look for file uploads/downloads
   - Document interesting techniques
3. **Share findings** in the analysis channel
4. **Update our attack database** with new TTPs

### Shift Coverage
- **Morning Shift** (8 AM - 4 PM): [Team Member Name]
- **Evening Shift** (4 PM - 12 AM): [Team Member Name]  
- **Night Shift** (12 AM - 8 AM): Automated monitoring only

## Troubleshooting

### Common Issues

**Service won't start:**
```bash
# Check logs
sudo journalctl -u cowrie-discord-monitor --no-pager

# Check configuration
sudo -u cowrie python3 /opt/cowrie/discord-monitor/test_webhook.py
```

**No alerts appearing:**
```bash
# Verify Cowrie is logging
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json

# Check monitor status
sudo systemctl status cowrie-discord-monitor
```

**Too many alerts:**
- Adjust `alert_levels` in configuration
- Add noisy IPs to `ignored_ips` list
- Increase `rate_limit_delay`

### Manual Testing

Generate test events to verify the system:
```bash
# Connect to honeypot (from different IP)
ssh -p 2222 admin@3.140.96.146

# Try common credentials
# Username: admin, Password: admin
# Username: root, Password: 123456
```

## Security Best Practices

### Webhook URL Security
- ✅ Store webhook URLs in config files only
- ✅ Restrict config file permissions (600)
- ✅ Never commit webhook URLs to git
- ✅ Rotate webhook URLs periodically
- ❌ Never share webhook URLs in chat/email

### Monitoring Security
- Monitor runs as unprivileged `cowrie` user
- Read-only access to Cowrie logs
- Network access only for Discord webhooks
- Automatic log rotation configured

## Advanced Features

### Multiple Webhook Channels
Configure different webhooks for different severity levels:
```json
"notification_channels": {
  "general": "https://discord.com/api/webhooks/...",
  "critical": "https://discord.com/api/webhooks/..."
}
```

### IP-based Filtering
```json
"high_priority_ips": ["1.2.3.4", "5.6.7.8"],
"ignored_ips": ["10.0.0.0/8", "192.168.0.0/16"]
```

### Custom Alert Formatting
Modify the script to add:
- Geographic IP location
- Threat intelligence integration  
- Attack pattern recognition
- Automated response triggers

## Team Communication

### Daily Stand-up Questions
1. What interesting attacks did we see yesterday?
2. Any new attack patterns or techniques?
3. Are our alerts working properly?
4. Any changes needed to our monitoring?

### Weekly Review
- Analyze attack statistics
- Update interesting commands list
- Review and improve alert rules
- Share lessons learned

## Files in This Integration

- `discord_honeypot_monitor.py` - Main monitoring script
- `discord_config_template.json` - Configuration template
- `cowrie-discord-monitor.service` - Systemd service file
- `deploy_discord_monitor.sh` - Automated deployment script
- `requirements.txt` - Python dependencies
- `test_webhook.py` - Webhook testing tool

## Support

For questions or issues:
1. Check the troubleshooting section above
2. Review system logs: `sudo journalctl -u cowrie-discord-monitor`
3. Ask in the team Discord channel
4. Create an issue in our GitHub repository

---

**Created by**: AIT670 Team Honeypot Project  
**Last Updated**: September 2025  
**Version**: 1.0
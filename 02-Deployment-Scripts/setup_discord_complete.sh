#!/bin/bash
# Discord Honeypot Monitor - All-in-One Setup Script
# Run this directly on your honeypot server
# Provide your Discord webhook URL when prompted or set DISCORD_WEBHOOK_URL beforehand.

echo "=========================================="
echo "Discord Honeypot Monitor - Complete Setup"  
echo "AIT670 Team Project"
echo "=========================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run as root: sudo bash setup_discord_complete.sh"
   exit 1
fi

# Configuration
MONITOR_DIR="/opt/cowrie/discord-monitor"

if [[ -n "${DISCORD_WEBHOOK_URL:-}" ]]; then
    WEBHOOK_URL="$DISCORD_WEBHOOK_URL"
else
    read -rp "Enter your Discord webhook URL: " WEBHOOK_URL
fi

if [[ -z "$WEBHOOK_URL" ]]; then
    echo "A Discord webhook URL is required."
    exit 1
fi

if [[ "$WEBHOOK_URL" == "YOUR_WEBHOOK_URL_HERE" ]]; then
    echo "Please provide an actual Discord webhook URL instead of the placeholder."
    exit 1
fi

echo "[1/6] Creating directories and installing dependencies..."
mkdir -p "$MONITOR_DIR"
apt update && apt install -y python3-pip
pip3 install requests python-dateutil psutil

echo "[2/6] Creating Discord monitor script..."
cat > "$MONITOR_DIR/discord_honeypot_monitor.py" << 'EOF'
#!/usr/bin/env python3
"""
Cowrie Honeypot Discord Webhook Monitor
"""
import json
import time
import os
import sys
import logging
import requests
from datetime import datetime
from pathlib import Path
import signal

class DiscordHoneypotMonitor:
    def __init__(self, config_file="discord_config.json"):
        self.config_file = config_file
        self.config = self.load_config()
        self.last_position = 0
        self.running = True
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('discord_monitor.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
    
    def signal_handler(self, signum, frame):
        self.logger.info(f"Received signal {signum}, shutting down...")
        self.running = False
    
    def load_config(self):
        config_path = Path(self.config_file)
        if not config_path.exists():
            self.create_default_config()
        
        with open(config_path, 'r') as f:
            return json.load(f)
    
    def create_default_config(self):
        default_config = {
            "discord_webhook_url": "YOUR_WEBHOOK_URL_HERE",
            "cowrie_log_path": "/opt/cowrie/var/log/cowrie/cowrie.json",
            "monitoring_interval": 5,
            "alert_levels": {
                "login_success": True,
                "login_failed": False,
                "command_executed": True,
                "file_upload": True,
                "file_download": True
            },
            "interesting_commands": [
                "wget", "curl", "nc", "python", "bash", "sh", "sudo", "su",
                "cat /etc/passwd", "whoami", "id", "uname", "ps", "netstat"
            ]
        }
        
        with open(self.config_file, 'w') as f:
            json.dump(default_config, f, indent=4)
    
    def send_discord_alert(self, title, description, color=0xff9900):
        webhook_url = self.config.get("discord_webhook_url")
        
        embed = {
            "title": title,
            "description": description,
            "color": color,
            "timestamp": datetime.utcnow().isoformat(),
            "footer": {"text": "Cowrie Honeypot Alert"}
        }
        
        try:
            response = requests.post(webhook_url, json={"embeds": [embed]}, timeout=10)
            response.raise_for_status()
            time.sleep(1)  # Rate limiting
            return True
        except Exception as e:
            self.logger.error(f"Discord alert failed: {e}")
            return False
    
    def process_event(self, event):
        eventid = event.get('eventid', '')
        src_ip = event.get('src_ip', 'unknown')
        
        # Login events
        if eventid == 'cowrie.login.success':
            username = event.get('username', 'unknown')
            password = event.get('password', 'unknown')
            self.send_discord_alert(
                "🚨 SUCCESSFUL LOGIN!",
                f"**Attacker logged in!**\n\nIP: `{src_ip}`\nUser: `{username}`\nPass: `{password}`",
                0xff0000
            )
        
        elif eventid == 'cowrie.login.failed' and self.config["alert_levels"]["login_failed"]:
            username = event.get('username', 'unknown')
            password = event.get('password', 'unknown')
            self.send_discord_alert(
                "🔒 Failed Login",
                f"IP: `{src_ip}`\nUser: `{username}`\nPass: `{password}`",
                0xffaa00
            )
        
        # Command execution
        elif eventid == 'cowrie.command.input':
            command = event.get('input', 'unknown')
            interesting = any(cmd in command.lower() for cmd in self.config["interesting_commands"])
            
            if interesting:
                self.send_discord_alert(
                    "⚠️ SUSPICIOUS COMMAND!",
                    f"**Command:** `{command}`\n**IP:** `{src_ip}`",
                    0xff6600
                )
            elif self.config["alert_levels"]["command_executed"]:
                self.send_discord_alert(
                    "💻 Command Executed",
                    f"Command: `{command}`\nIP: `{src_ip}`",
                    0x0099ff
                )
        
        # File events
        elif 'file_upload' in eventid:
            filename = event.get('filename', 'unknown')
            self.send_discord_alert(
                "📤 FILE UPLOAD!",
                f"**File:** `{filename}`\n**IP:** `{src_ip}`",
                0xff3300
            )
        
        elif 'file_download' in eventid and self.config["alert_levels"]["file_download"]:
            filename = event.get('filename', 'unknown')
            self.send_discord_alert(
                "📥 File Download",
                f"File: `{filename}`\nIP: `{src_ip}`",
                0xff9900
            )
    
    def monitor_logs(self):
        log_path = Path(self.config["cowrie_log_path"])
        
        if not log_path.exists():
            self.logger.error(f"Cowrie log not found: {log_path}")
            return
        
        self.logger.info(f"Monitoring {log_path}")
        self.send_discord_alert("🟢 Monitor Started", "Discord alerts are now active!", 0x00ff00)
        
        while self.running:
            try:
                with open(log_path, 'r') as f:
                    f.seek(self.last_position)
                    
                    for line in f:
                        if line.strip():
                            try:
                                event = json.loads(line.strip())
                                self.process_event(event)
                            except json.JSONDecodeError:
                                continue
                    
                    self.last_position = f.tell()
                
                time.sleep(self.config["monitoring_interval"])
                
            except Exception as e:
                self.logger.error(f"Monitor error: {e}")
                time.sleep(10)

if __name__ == "__main__":
    monitor = DiscordHoneypotMonitor()
    monitor.monitor_logs()
EOF

echo "[3/6] Creating configuration file..."
cat > "$MONITOR_DIR/discord_config.json" << EOF
{
  "discord_webhook_url": "$WEBHOOK_URL",
  "cowrie_log_path": "/opt/cowrie/var/log/cowrie/cowrie.json",
  "monitoring_interval": 5,
  "alert_levels": {
    "login_success": true,
    "login_failed": false,
    "command_executed": true,
    "file_upload": true,
    "file_download": true
  },
  "interesting_commands": [
    "wget", "curl", "nc", "netcat", "python", "bash", "sh", "sudo", "su",
    "cat /etc/passwd", "cat /etc/shadow", "whoami", "id", "uname", "ps",
    "netstat", "nmap", "chmod", "chown", "rm -rf", "history"
  ]
}
EOF

echo "[4/6] Creating systemd service..."
cat > /etc/systemd/system/cowrie-discord-monitor.service << EOF
[Unit]
Description=Cowrie Discord Monitor
After=network.target

[Service]
Type=simple
User=cowrie
Group=cowrie
WorkingDirectory=$MONITOR_DIR
ExecStart=/usr/bin/python3 $MONITOR_DIR/discord_honeypot_monitor.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "[5/6] Setting permissions..."
chown -R cowrie:cowrie "$MONITOR_DIR"
chmod 600 "$MONITOR_DIR/discord_config.json"
chmod +x "$MONITOR_DIR/discord_honeypot_monitor.py"

echo "[6/6] Creating test script..."
cat > "$MONITOR_DIR/test_webhook.py" << EOF
#!/usr/bin/env python3
import json
import requests
from datetime import datetime

with open('discord_config.json', 'r') as f:
    config = json.load(f)

webhook_url = config['discord_webhook_url']

embed = {
    "title": "🧪 Webhook Test",
    "description": "Discord webhook is working! Your honeypot alerts are ready.",
    "color": 0x00ff00,
    "timestamp": datetime.utcnow().isoformat()
}

response = requests.post(webhook_url, json={"embeds": [embed]})
if response.status_code == 204:
    print("✅ Test successful! Check Discord.")
else:
    print(f"❌ Test failed: {response.status_code}")
EOF

chmod +x "$MONITOR_DIR/test_webhook.py"

echo ""
echo "=========================================="
echo "✅ SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Test the webhook:"
echo "   sudo -u cowrie python3 $MONITOR_DIR/test_webhook.py"
echo ""
echo "2. Start the service:"
echo "   systemctl daemon-reload"
echo "   systemctl enable cowrie-discord-monitor"
echo "   systemctl start cowrie-discord-monitor"
echo ""
echo "3. Check status:"
echo "   systemctl status cowrie-discord-monitor"
echo ""
echo "Your Discord webhook URL is already configured!"
echo "Monitor your #honeypot-alerts channel for activity."
echo "=========================================="
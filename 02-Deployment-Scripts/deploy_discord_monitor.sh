#!/bin/bash
# Discord Honeypot Monitor Deployment Script
# Created for AIT670 Team Honeypot Project
# 
# This script deploys the Discord monitoring system to your Cowrie honeypot
# Run as root on your AWS EC2 instance

set -e

echo "=========================================="
echo "Discord Honeypot Monitor Deployment"
echo "AIT670 Team Project"
echo "=========================================="

# Configuration
MONITOR_DIR="/opt/cowrie/discord-monitor"
SERVICE_NAME="cowrie-discord-monitor"
COWRIE_USER="cowrie"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

# Check if cowrie user exists
if ! id "$COWRIE_USER" &>/dev/null; then
    print_error "Cowrie user '$COWRIE_USER' does not exist. Please install Cowrie first."
    exit 1
fi

print_status "Creating Discord monitor directory..."
mkdir -p "$MONITOR_DIR"
chown "$COWRIE_USER:$COWRIE_USER" "$MONITOR_DIR"

print_status "Installing Python dependencies..."
pip3 install requests python-dateutil psutil

print_status "Copying monitor files..."
# Note: These files should be uploaded to the server first
if [[ -f "discord_honeypot_monitor.py" ]]; then
    cp discord_honeypot_monitor.py "$MONITOR_DIR/"
    chown "$COWRIE_USER:$COWRIE_USER" "$MONITOR_DIR/discord_honeypot_monitor.py"
    chmod +x "$MONITOR_DIR/discord_honeypot_monitor.py"
else
    print_error "discord_honeypot_monitor.py not found in current directory"
    exit 1
fi

if [[ -f "discord_config_template.json" ]]; then
    cp discord_config_template.json "$MONITOR_DIR/discord_config.json"
    chown "$COWRIE_USER:$COWRIE_USER" "$MONITOR_DIR/discord_config.json"
    chmod 600 "$MONITOR_DIR/discord_config.json"  # Restrict access to config file
else
    print_error "discord_config_template.json not found in current directory"
    exit 1
fi

print_status "Installing systemd service..."
if [[ -f "cowrie-discord-monitor.service" ]]; then
    cp cowrie-discord-monitor.service /etc/systemd/system/
    systemctl daemon-reload
else
    print_error "cowrie-discord-monitor.service not found in current directory"
    exit 1
fi

print_status "Setting up log rotation..."
cat > /etc/logrotate.d/discord-monitor << EOF
$MONITOR_DIR/discord_monitor.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 $COWRIE_USER $COWRIE_USER
    postrotate
        systemctl reload $SERVICE_NAME > /dev/null 2>&1 || true
    endscript
}
EOF

print_status "Creating startup script..."
cat > "$MONITOR_DIR/start_monitor.sh" << 'EOF'
#!/bin/bash
# Quick start script for Discord monitor

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -f "discord_config.json" ]]; then
    echo "Error: discord_config.json not found!"
    echo "Please copy discord_config_template.json to discord_config.json and configure your webhook URL"
    exit 1
fi

# Check if webhook URL is configured
if grep -q "REPLACE_WITH_YOUR_WEBHOOK_URL" discord_config.json; then
    echo "Error: Discord webhook URL not configured!"
    echo "Please edit discord_config.json and replace REPLACE_WITH_YOUR_WEBHOOK_URL with your actual webhook URL"
    exit 1
fi

echo "Starting Discord Honeypot Monitor..."
python3 discord_honeypot_monitor.py discord_config.json
EOF

chmod +x "$MONITOR_DIR/start_monitor.sh"
chown "$COWRIE_USER:$COWRIE_USER" "$MONITOR_DIR/start_monitor.sh"

print_status "Creating test script..."
cat > "$MONITOR_DIR/test_webhook.py" << 'EOF'
#!/usr/bin/env python3
"""Test script for Discord webhook"""

import json
import requests
import sys
from datetime import datetime

def test_webhook(config_file):
    """Test the Discord webhook configuration."""
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        webhook_url = config.get("discord_webhook_url")
        
        if webhook_url == "REPLACE_WITH_YOUR_WEBHOOK_URL":
            print("Error: Discord webhook URL not configured!")
            return False
        
        # Test message
        embed = {
            "title": "🧪 Discord Webhook Test",
            "description": "This is a test message from your Cowrie honeypot monitor!",
            "color": 0x00ff00,
            "timestamp": datetime.utcnow().isoformat(),
            "footer": {
                "text": "AIT670 Team Honeypot Project"
            }
        }
        
        payload = {"embeds": [embed]}
        
        response = requests.post(webhook_url, json=payload, timeout=10)
        response.raise_for_status()
        
        print("✅ Test successful! Check your Discord channel.")
        return True
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False

if __name__ == "__main__":
    config_file = sys.argv[1] if len(sys.argv) > 1 else "discord_config.json"
    test_webhook(config_file)
EOF

chmod +x "$MONITOR_DIR/test_webhook.py"
chown "$COWRIE_USER:$COWRIE_USER" "$MONITOR_DIR/test_webhook.py"

print_status "Deployment completed successfully!"
echo ""
echo "=========================================="
echo "NEXT STEPS:"
echo "=========================================="
echo "1. Configure your Discord webhook:"
echo "   - Edit $MONITOR_DIR/discord_config.json"
echo "   - Replace REPLACE_WITH_YOUR_WEBHOOK_URL with your actual Discord webhook URL"
echo ""
echo "2. Test the webhook:"
echo "   sudo -u $COWRIE_USER python3 $MONITOR_DIR/test_webhook.py"
echo ""
echo "3. Start the monitor service:"
echo "   systemctl enable $SERVICE_NAME"
echo "   systemctl start $SERVICE_NAME"
echo ""
echo "4. Check service status:"
echo "   systemctl status $SERVICE_NAME"
echo "   journalctl -u $SERVICE_NAME -f"
echo ""
echo "5. Manual start (for testing):"
echo "   sudo -u $COWRIE_USER $MONITOR_DIR/start_monitor.sh"
echo ""
print_warning "Remember to secure your webhook URLs and don't commit them to git!"
echo "=========================================="
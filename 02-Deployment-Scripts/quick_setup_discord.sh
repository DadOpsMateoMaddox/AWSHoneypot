#!/bin/bash
# Quick Discord Webhook Setup Script for Team Members
# AIT670 Honeypot Project

echo "=========================================="
echo "Discord Webhook Quick Setup"
echo "AIT670 Team Honeypot Project"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're on the AWS instance
if [[ ! -f "/opt/cowrie/bin/cowrie" ]]; then
    print_error "This doesn't appear to be the Cowrie honeypot server."
    print_info "Make sure you're running this on the AWS EC2 instance (44.218.220.47 - Elastic IP)"
    exit 1
fi

print_step "Checking Discord monitor installation..."
if [[ ! -f "/opt/cowrie/discord-monitor/discord_honeypot_monitor.py" ]]; then
    print_error "Discord monitor not installed. Please run deploy_discord_monitor.sh first."
    exit 1
fi

print_step "Checking configuration..."
CONFIG_FILE="/opt/cowrie/discord-monitor/discord_config.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Check if webhook is configured
if grep -q "REPLACE_WITH_YOUR_WEBHOOK_URL" "$CONFIG_FILE"; then
    print_error "Discord webhook URL not configured!"
    echo ""
    echo "Please follow these steps:"
    echo "1. Go to your Discord server"
    echo "2. Right-click on the #honeypot-alerts channel"
    echo "3. Select 'Edit Channel' → 'Integrations' → 'Create Webhook'"
    echo "4. Copy the webhook URL"
    echo "5. Edit the config file:"
    echo "   sudo nano $CONFIG_FILE"
    echo "6. Replace REPLACE_WITH_YOUR_WEBHOOK_URL with your actual URL"
    echo ""
    exit 1
fi

print_step "Testing webhook connection..."
if sudo -u cowrie python3 /opt/cowrie/discord-monitor/test_webhook.py; then
    print_step "Webhook test successful! ✅"
else
    print_error "Webhook test failed. Check your configuration."
    exit 1
fi

print_step "Checking service status..."
if systemctl is-active --quiet cowrie-discord-monitor; then
    print_step "Discord monitor is running ✅"
    echo "Recent logs:"
    sudo journalctl -u cowrie-discord-monitor --no-pager -n 5
else
    print_step "Starting Discord monitor service..."
    sudo systemctl start cowrie-discord-monitor
    
    if systemctl is-active --quiet cowrie-discord-monitor; then
        print_step "Service started successfully ✅"
    else
        print_error "Failed to start service. Check logs:"
        sudo journalctl -u cowrie-discord-monitor --no-pager -n 10
        exit 1
    fi
fi

print_step "Enabling service to start on boot..."
sudo systemctl enable cowrie-discord-monitor >/dev/null 2>&1

echo ""
echo "=========================================="
echo "✅ Discord webhook setup complete!"
echo "=========================================="
echo ""
echo "Your honeypot is now sending alerts to Discord!"
echo ""
echo "Useful commands:"
echo "• Check status: sudo systemctl status cowrie-discord-monitor"
echo "• View logs: sudo journalctl -u cowrie-discord-monitor -f"
echo "• Restart: sudo systemctl restart cowrie-discord-monitor"
echo "• Test webhook: sudo -u cowrie python3 /opt/cowrie/discord-monitor/test_webhook.py"
echo ""
echo "Monitor your Discord channel for alerts! 🎯"
echo ""
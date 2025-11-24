#!/bin/bash
# Fix Discord webhook rate limiting and restart monitoring

echo "=== FIXING DISCORD WEBHOOK ISSUES ==="

# Stop the monitor
echo "[1] Stopping Discord monitor..."
sudo systemctl stop cowrie-discord-monitor

# Update monitor config to reduce rate limit issues
echo "[2] Updating Discord config with rate limit protection..."
sudo tee /opt/cowrie/etc/discord_config.json > /dev/null <<'EOF'
{
  "webhook_url": "YOUR_WEBHOOK_URL_HERE",
  "alert_levels": {
    "login_success": true,
    "login_failed": true,
    "command_executed": true,
    "file_upload": true,
    "file_download": true,
    "session_start": true,
    "troll_response": true
  },
  "monitoring_interval": 5,
  "rate_limit_delay": 2,
  "batch_events": true,
  "max_batch_size": 5
}
EOF

# Get current webhook URL and update config
CURRENT_WEBHOOK=$(sudo grep "webhook_url" /opt/cowrie/etc/discord_config.json 2>/dev/null | cut -d'"' -f4 | head -1)
if [ ! -z "$CURRENT_WEBHOOK" ] && [ "$CURRENT_WEBHOOK" != "YOUR_WEBHOOK_URL_HERE" ]; then
    echo "Preserving existing webhook URL..."
    sudo sed -i "s|YOUR_WEBHOOK_URL_HERE|$CURRENT_WEBHOOK|g" /opt/cowrie/etc/discord_config.json
else
    echo "WARNING: No webhook URL found. Please update manually."
fi

# Restart Cowrie
echo "[3] Restarting Cowrie..."
sudo systemctl restart cowrie
sleep 3

# Restart monitor
echo "[4] Restarting Discord monitor..."
sudo systemctl restart cowrie-discord-monitor
sleep 2

# Check status
echo "[5] Checking services..."
sudo systemctl status cowrie --no-pager | head -5
sudo systemctl status cowrie-discord-monitor --no-pager | head -5

echo ""
echo "=== FIX COMPLETE ==="
echo "Monitor logs: sudo journalctl -u cowrie-discord-monitor -f"

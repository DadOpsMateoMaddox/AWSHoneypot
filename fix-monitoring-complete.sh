#!/bin/bash
# Complete fix for Discord monitoring

echo "=== FIXING DISCORD MONITORING ==="

# Kill old enhanced monitor
echo "[1] Stopping old enhanced monitor..."
sudo pkill -f enhanced_monitor.py

# Stop broken systemd service
echo "[2] Stopping broken systemd service..."
sudo systemctl stop cowrie-discord-monitor
sudo systemctl disable cowrie-discord-monitor

# Find the actual monitor script location
echo "[3] Locating monitor script..."
MONITOR_SCRIPT=$(find /opt/cowrie -name "enhanced_monitor.py" 2>/dev/null | head -1)
if [ -z "$MONITOR_SCRIPT" ]; then
    echo "❌ enhanced_monitor.py not found!"
    exit 1
fi
echo "Found: $MONITOR_SCRIPT"

# Create new systemd service with rate limiting protection
echo "[4] Creating new systemd service..."
sudo tee /etc/systemd/system/cowrie-monitor.service > /dev/null <<EOF
[Unit]
Description=Cowrie Enhanced Monitor with Rate Limit Protection
After=network.target cowrie.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/cowrie
ExecStart=/usr/bin/python3 $MONITOR_SCRIPT
Restart=always
RestartSec=10
Environment="PYTHONUNBUFFERED=1"

[Install]
WantedBy=multi-user.target
EOF

# Reload and start
echo "[5] Starting new service..."
sudo systemctl daemon-reload
sudo systemctl enable cowrie-monitor
sudo systemctl start cowrie-monitor
sleep 2

# Check status
echo "[6] Checking status..."
sudo systemctl status cowrie-monitor --no-pager | head -10

echo ""
echo "=== FIX COMPLETE ==="
echo "View logs: sudo journalctl -u cowrie-monitor -f"

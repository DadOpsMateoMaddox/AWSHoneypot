#!/bin/bash
# Nuke old broken Discord monitor completely

echo "=== NUKING OLD MONITOR ==="

# Kill all monitor processes
echo "[1] Killing all monitor processes..."
sudo pkill -9 -f enhanced_monitor.py
sudo pkill -9 -f discord_monitor.py

# Stop and disable old service
echo "[2] Removing old systemd service..."
sudo systemctl stop cowrie-discord-monitor 2>/dev/null
sudo systemctl disable cowrie-discord-monitor 2>/dev/null
sudo rm -f /etc/systemd/system/cowrie-discord-monitor.service

# Reload systemd
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo ""
echo "=== OLD MONITOR NUKED ==="
echo "Now run: ./fix-monitoring-complete.sh"

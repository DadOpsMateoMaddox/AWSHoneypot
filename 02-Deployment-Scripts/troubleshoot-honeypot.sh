#!/bin/bash
# Troubleshoot honeypot and Discord monitoring

echo "=== HONEYPOT TROUBLESHOOTING ==="
echo ""

# Check Cowrie status
echo "[1] Checking Cowrie service..."
sudo systemctl status cowrie --no-pager
echo ""

# Check if Cowrie is listening
echo "[2] Checking if port 2222 is listening..."
sudo netstat -tlnp | grep 2222
echo ""

# Check recent Cowrie logs
echo "[3] Recent Cowrie logs (last 20 lines)..."
sudo tail -n 20 /opt/cowrie/var/log/cowrie/cowrie.log
echo ""

# Check Discord monitor status
echo "[4] Checking Discord monitor service..."
sudo systemctl status cowrie-discord-monitor --no-pager
echo ""

# Check Discord monitor logs
echo "[5] Recent Discord monitor logs..."
sudo journalctl -u cowrie-discord-monitor -n 50 --no-pager
echo ""

# Test Discord webhook
echo "[6] Testing Discord webhook..."
WEBHOOK_URL=$(grep "webhook_url" /opt/cowrie/etc/discord_config.json | cut -d'"' -f4)
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "embeds": [{
      "title": "🔧 Honeypot Health Check",
      "description": "Manual troubleshooting test from '"$(date)"'",
      "color": 3447003
    }]
  }'
echo ""
echo ""

# Check for Discord rate limiting
echo "[7] Checking for rate limit errors in monitor logs..."
sudo journalctl -u cowrie-discord-monitor | grep -i "rate\|429\|throttle" | tail -n 10
echo ""

# Check Cowrie JSON log activity
echo "[8] Recent Cowrie events (last 5)..."
sudo tail -n 5 /opt/cowrie/var/log/cowrie/cowrie.json | jq -r '[.timestamp, .eventid, .src_ip] | @tsv' 2>/dev/null || sudo tail -n 5 /opt/cowrie/var/log/cowrie/cowrie.json
echo ""

# Check if enhanced monitor is running
echo "[9] Checking enhanced monitor process..."
ps aux | grep enhanced_monitor | grep -v grep
echo ""

echo "=== TROUBLESHOOTING COMPLETE ==="
echo ""
echo "Quick fixes:"
echo "  Restart Cowrie:          sudo systemctl restart cowrie"
echo "  Restart Discord monitor: sudo systemctl restart cowrie-discord-monitor"
echo "  View live logs:          sudo journalctl -u cowrie-discord-monitor -f"

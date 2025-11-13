#!/bin/bash
# Download Cowrie JSON logs from honeypot

echo "📥 Downloading Cowrie JSON logs..."

# Create logs directory
mkdir -p cowrie-logs

# Download the main log file
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47:/opt/cowrie/var/log/cowrie/cowrie.json ./cowrie-logs/cowrie-$(date +%Y%m%d).json

echo "✅ Logs downloaded to: cowrie-logs/cowrie-$(date +%Y%m%d).json"
echo ""
echo "📊 Quick stats:"
wc -l ./cowrie-logs/cowrie-$(date +%Y%m%d).json
echo ""
echo "🔍 View logs:"
echo "cat cowrie-logs/cowrie-$(date +%Y%m%d).json | jq ."

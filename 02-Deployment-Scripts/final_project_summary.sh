#!/bin/bash
# final_project_summary.sh
# Complete final project summary: Generate stats, pull all logs, create PCAP, and push to Discord
# Usage: sudo bash final_project_summary.sh

set -euo pipefail

echo "========================================="
echo "🍯 PATRIOTPOT - FINAL PROJECT SUMMARY"
echo "========================================="
echo ""
echo "This script will:"
echo "  1. Generate top 10 statistics from all 75 days"
echo "  2. Pull all Cowrie logs (JSON format)"
echo "  3. Convert logs to PCAP format"
echo "  4. Create compressed archive"
echo "  5. Post statistics to Discord"
echo ""

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
WORK_DIR="/tmp/final_project_summary_$TIMESTAMP"
COWRIE_LOG_DIR="/opt/cowrie/var/log/cowrie"
COWRIE_DOWNLOADS="/opt/cowrie/var/lib/cowrie/downloads"
ARCHIVE_DIR="$HOME/final_project_archive"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Working directory: $WORK_DIR"
echo "Archive directory: $ARCHIVE_DIR"
echo ""

# Create directories
mkdir -p "$WORK_DIR"
mkdir -p "$ARCHIVE_DIR"

# Step 1: Generate and post statistics to Discord
echo "========================================="
echo "[1/5] Generating statistics and posting to Discord..."
echo "========================================="
echo ""

if [ -f "$SCRIPTS_DIR/final_project_stats.py" ]; then
    echo "Running statistics generator..."
    sudo python3 "$SCRIPTS_DIR/final_project_stats.py" || {
        echo "⚠️  Statistics generation had issues, continuing..."
    }
else
    echo "⚠️  Statistics script not found, skipping..."
fi

echo ""
sleep 2

# Step 2: Copy all Cowrie logs
echo "========================================="
echo "[2/5] Copying all Cowrie logs..."
echo "========================================="
echo ""

if [ -d "$COWRIE_LOG_DIR" ]; then
    echo "Copying JSON logs..."
    sudo cp -a "$COWRIE_LOG_DIR"/*.json "$WORK_DIR/" 2>/dev/null || true
    sudo cp -a "$COWRIE_LOG_DIR"/*.json.* "$WORK_DIR/" 2>/dev/null || true
    
    echo "Copying text logs..."
    sudo cp -a "$COWRIE_LOG_DIR"/*.log "$WORK_DIR/" 2>/dev/null || true
    sudo cp -a "$COWRIE_LOG_DIR"/*.log.* "$WORK_DIR/" 2>/dev/null || true
    
    echo "✅ Logs copied"
else
    echo "⚠️  Cowrie log directory not found: $COWRIE_LOG_DIR"
fi

echo ""

# Step 3: Copy downloaded files/malware
echo "========================================="
echo "[3/5] Copying downloaded files/malware..."
echo "========================================="
echo ""

if [ -d "$COWRIE_DOWNLOADS" ]; then
    echo "Copying downloads..."
    sudo cp -a "$COWRIE_DOWNLOADS" "$WORK_DIR/downloads" 2>/dev/null || true
    echo "✅ Downloads copied"
else
    echo "⚠️  Downloads directory not found"
fi

echo ""

# Step 4: Convert JSON to PCAP
echo "========================================="
echo "[4/5] Converting JSON logs to PCAP..."
echo "========================================="
echo ""

if [ -f "$SCRIPTS_DIR/logs2pcap.py" ]; then
    MAIN_LOG="$WORK_DIR/cowrie.json"
    PCAP_FILE="$WORK_DIR/cowrie_complete_75days.pcap"
    
    if [ -f "$MAIN_LOG" ]; then
        echo "Converting $MAIN_LOG to PCAP..."
        python3 "$SCRIPTS_DIR/logs2pcap.py" "$MAIN_LOG" "$PCAP_FILE" || {
            echo "⚠️  PCAP conversion failed, continuing..."
        }
        
        if [ -f "$PCAP_FILE" ]; then
            echo "✅ PCAP created: $PCAP_FILE"
            ls -lh "$PCAP_FILE"
        fi
    else
        echo "⚠️  Main log file not found, skipping PCAP conversion"
    fi
else
    echo "⚠️  logs2pcap.py not found, skipping PCAP conversion"
fi

echo ""

# Fix permissions
echo "Fixing permissions..."
sudo chown -R $(whoami):$(whoami) "$WORK_DIR" 2>/dev/null || true

# Step 5: Create compressed archive
echo "========================================="
echo "[5/5] Creating compressed archive..."
echo "========================================="
echo ""

ARCHIVE_NAME="patriotpot_final_75days_$TIMESTAMP.tar.gz"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

echo "Creating archive: $ARCHIVE_NAME"
cd "$WORK_DIR"
tar -czf "$ARCHIVE_PATH" . 2>/dev/null || {
    echo "⚠️  Error creating archive"
    exit 1
}

echo ""
echo "✅ Archive created successfully!"
echo ""
ls -lh "$ARCHIVE_PATH"
echo ""

# Calculate checksums
echo "Calculating checksums..."
ARCHIVE_SHA256=$(sha256sum "$ARCHIVE_PATH" | awk '{print $1}')
echo "SHA256: $ARCHIVE_SHA256"

# Generate manifest
echo ""
echo "Generating manifest..."
MANIFEST_FILE="$ARCHIVE_DIR/manifest_$TIMESTAMP.txt"

cat > "$MANIFEST_FILE" << EOF
PATRIOTPOT FINAL PROJECT ARCHIVE
=================================

Archive: $ARCHIVE_NAME
Created: $(date)
Size: $(du -h "$ARCHIVE_PATH" | awk '{print $1}')
SHA256: $ARCHIVE_SHA256

Contents:
---------
$(tar -tzf "$ARCHIVE_PATH" | head -20)
$(tar -tzf "$ARCHIVE_PATH" | wc -l) total files

Project Duration: 75 days
Status: Complete - Cowrie Shutdown

EOF

echo "✅ Manifest created: $MANIFEST_FILE"

# Summary
echo ""
echo "========================================="
echo "✅ FINAL PROJECT SUMMARY COMPLETE!"
echo "========================================="
echo ""
echo "📦 Archive Location:"
echo "   $ARCHIVE_PATH"
echo ""
echo "📄 Manifest:"
echo "   $MANIFEST_FILE"
echo ""
echo "📊 Statistics:"
echo "   Posted to Discord (if webhook configured)"
echo ""
echo "📥 To download from EC2 to your local machine:"
echo "   scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47:$ARCHIVE_PATH ./"
echo ""
echo "Or from CloudShell:"
echo "   aws s3 cp $ARCHIVE_PATH s3://your-bucket/final-archive/"
echo ""
echo "📋 Archive contains:"
echo "   • All JSON logs (75 days)"
echo "   • All text logs"
echo "   • All downloaded files/malware"
echo "   • Complete PCAP file (if generated)"
echo "   • Total size: $(du -h "$ARCHIVE_PATH" | awk '{print $1}')"
echo ""
echo "🎓 Thank you for using PatriotPot!"
echo "   GMU AIT670 - Fall 2025"
echo ""

# Post archive info to Discord (optional)
if [ -f "$SCRIPTS_DIR/final_project_stats.py" ]; then
    echo "Posting archive info to Discord..."
    python3 << EOF
import requests
import os
import json

# Load Discord webhook
webhook = None
config_paths = [
    '/opt/cowrie/discord_config.json',
    '/home/ec2-user/discord_config.json',
    '${SCRIPTS_DIR}/discord_config.json'
]

for path in config_paths:
    try:
        with open(path, 'r') as f:
            config = json.load(f)
            w = config.get('discord_webhook_url')
            if w and w != "REPLACE_WITH_YOUR_WEBHOOK_URL":
                webhook = w
                break
    except:
        continue

if webhook:
    message = f"""
📦 **FINAL ARCHIVE READY FOR DOWNLOAD**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Archive:** \`${ARCHIVE_NAME}\`
**Size:** $(du -h "$ARCHIVE_PATH" | awk '{print $1}')
**SHA256:** \`${ARCHIVE_SHA256}\`
**Location:** \`${ARCHIVE_PATH}\`

**Contains:**
✅ All JSON logs (75 days)
✅ All text logs
✅ Downloaded files/malware
✅ Complete PCAP file

**Download Command:**
\`\`\`bash
scp -i ~/.ssh/gmu-honeypot-key.pem \\
  ec2-user@44.218.220.47:${ARCHIVE_PATH} ./
\`\`\`

🎓 **PatriotPot Project - Data Collection Complete**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""
    try:
        response = requests.post(webhook, json={"content": message}, timeout=10)
        if response.status_code in [200, 204]:
            print("✅ Archive info posted to Discord")
        else:
            print(f"⚠️  Discord returned status {response.status_code}")
    except Exception as e:
        print(f"⚠️  Could not post to Discord: {e}")
else:
    print("⚠️  Discord webhook not configured")
EOF
fi

echo ""
echo "========================================="
echo "🎉 ALL DONE!"
echo "========================================="

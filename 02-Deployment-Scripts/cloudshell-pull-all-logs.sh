#!/bin/bash
# CLOUDSHELL LOG PULL - Run this in AWS CloudShell
# This script pulls ALL Cowrie logs from day 1 to today, converts JSON to PCAP, and creates downloadable archive

set -euo pipefail

HONEYPOT_IP="44.218.220.47"
HONEYPOT_USER="ec2-user"
LOCAL_ARCHIVE_DIR="$HOME/cowrie_logs_$(date +%Y%m%d_%H%M%S)"
REMOTE_TEMP="/tmp/cowrie_archive_$(date +%Y%m%d_%H%M%S)"

echo "========================================="
echo "🚀 COWRIE LOG PULL - COMPLETE ARCHIVE"
echo "========================================="
echo ""
echo "Target: $HONEYPOT_USER@$HONEYPOT_IP"
echo "Local staging: $LOCAL_ARCHIVE_DIR"
echo ""

# Create local staging directory
mkdir -p "$LOCAL_ARCHIVE_DIR"

echo "[1/7] Installing prerequisites on honeypot..."
ssh "$HONEYPOT_USER@$HONEYPOT_IP" << 'EOF_REMOTE_PREP'
# Install Python3, pip, jq if missing
sudo yum install -y python3 python3-pip jq 2>/dev/null || sudo apt-get update && sudo apt-get install -y python3 python3-pip jq 2>/dev/null || true

# Install scapy for PCAP conversion
sudo pip3 install scapy 2>/dev/null || pip3 install --user scapy || true

echo "✅ Prerequisites ready"
EOF_REMOTE_PREP

echo ""
echo "[2/7] Copying conversion script to honeypot..."
# Create logs2pcap.py on the remote host
ssh "$HONEYPOT_USER@$HONEYPOT_IP" << 'EOF_LOGS2PCAP'
cat > /tmp/logs2pcap.py << 'PYTHON_SCRIPT'
#!/usr/bin/env python3
import json
import sys
from datetime import datetime
from scapy.all import *

def json_to_pcap(json_file, pcap_file):
    packets = []
    try:
        with open(json_file, 'r') as f:
            for line_num, line in enumerate(f, 1):
                try:
                    log_entry = json.loads(line.strip())
                    src_ip = log_entry.get('src_ip', '0.0.0.0')
                    dst_ip = '44.218.220.47'
                    src_port = log_entry.get('src_port', 0)
                    dst_port = log_entry.get('dst_port', 2222)
                    timestamp = log_entry.get('timestamp', '')
                    
                    try:
                        ts = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                        epoch_time = ts.timestamp()
                    except:
                        epoch_time = time.time()
                    
                    event_id = log_entry.get('eventid', '')
                    
                    if event_id == 'cowrie.session.connect':
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='S')
                        pkt.time = epoch_time
                        packets.append(pkt)
                    elif event_id == 'cowrie.login.success':
                        username = log_entry.get('username', '')
                        password = log_entry.get('password', '')
                        payload = f"SSH-2.0-OpenSSH_6.0p1 Login: {username}:{password}"
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='PA') / Raw(load=payload)
                        pkt.time = epoch_time
                        packets.append(pkt)
                    elif event_id == 'cowrie.command.input':
                        command = log_entry.get('input', '')
                        payload = f"CMD: {command}"
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='PA') / Raw(load=payload)
                        pkt.time = epoch_time
                        packets.append(pkt)
                    elif event_id == 'cowrie.session.file_download':
                        url = log_entry.get('url', '')
                        filename = log_entry.get('outfile', '')
                        payload = f"DOWNLOAD: {url} -> {filename}"
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='PA') / Raw(load=payload)
                        pkt.time = epoch_time
                        packets.append(pkt)
                    elif event_id == 'cowrie.session.closed':
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='FA')
                        pkt.time = epoch_time
                        packets.append(pkt)
                except:
                    continue
        
        if packets:
            wrpcap(pcap_file, packets)
            print(f"✅ Converted {len(packets)} packets to {pcap_file}")
        else:
            print("⚠️  No valid packets found")
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    json_file = sys.argv[1] if len(sys.argv) > 1 else '/opt/cowrie/var/log/cowrie/cowrie.json'
    pcap_file = sys.argv[2] if len(sys.argv) > 2 else '/tmp/cowrie_traffic.pcap'
    print(f"Converting {json_file} to {pcap_file}...")
    json_to_pcap(json_file, pcap_file)
PYTHON_SCRIPT

chmod +x /tmp/logs2pcap.py
echo "✅ Conversion script ready"
EOF_LOGS2PCAP

echo ""
echo "[3/7] Creating archive of ALL Cowrie logs..."
ssh "$HONEYPOT_USER@$HONEYPOT_IP" << EOF_REMOTE_ARCHIVE
REMOTE_TEMP="$REMOTE_TEMP"
mkdir -p "\$REMOTE_TEMP"

# Copy all log files
echo "  📁 Copying JSON logs..."
sudo cp -a /opt/cowrie/var/log/cowrie/*.json "\$REMOTE_TEMP/" 2>/dev/null || true
sudo cp -a /opt/cowrie/var/log/cowrie/*.json.* "\$REMOTE_TEMP/" 2>/dev/null || true

echo "  📁 Copying text logs..."
sudo cp -a /opt/cowrie/var/log/cowrie/*.log "\$REMOTE_TEMP/" 2>/dev/null || true
sudo cp -a /opt/cowrie/var/log/cowrie/*.log.* "\$REMOTE_TEMP/" 2>/dev/null || true

echo "  📁 Copying download artifacts..."
sudo cp -a /opt/cowrie/var/lib/cowrie/downloads "\$REMOTE_TEMP/" 2>/dev/null || true

# Fix permissions for download
sudo chown -R $HONEYPOT_USER:$HONEYPOT_USER "\$REMOTE_TEMP"

# Get earliest and latest timestamps
EARLIEST=\$(find "\$REMOTE_TEMP" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | head -1 | awk '{print \$1}')
LATEST=\$(find "\$REMOTE_TEMP" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | awk '{print \$1}')

if [ -n "\$EARLIEST" ] && [ -n "\$LATEST" ]; then
  echo "  📅 Date range: \$(date -d "@\$EARLIEST" --iso-8601=seconds) → \$(date -d "@\$LATEST" --iso-8601=seconds)"
fi

echo "✅ Archive staging complete"
EOF_REMOTE_ARCHIVE

echo ""
echo "[4/7] Converting JSON to PCAP..."
ssh "$HONEYPOT_USER@$HONEYPOT_IP" << EOF_CONVERT
python3 /tmp/logs2pcap.py /opt/cowrie/var/log/cowrie/cowrie.json /tmp/cowrie_traffic.pcap
EOF_CONVERT

echo ""
echo "[5/7] Creating compressed archive..."
ssh "$HONEYPOT_USER@$HONEYPOT_IP" << EOF_TAR
cd "$REMOTE_TEMP"
tar -czf /tmp/cowrie_logs_complete_$(date +%Y%m%d_%H%M%S).tar.gz .
ARCHIVE_NAME=\$(ls -t /tmp/cowrie_logs_complete_*.tar.gz | head -1)
ARCHIVE_SIZE=\$(du -h "\$ARCHIVE_NAME" | awk '{print \$1}')
ARCHIVE_SHA256=\$(sha256sum "\$ARCHIVE_NAME" | awk '{print \$1}')

echo "  📦 Archive: \$ARCHIVE_NAME"
echo "  📏 Size: \$ARCHIVE_SIZE"
echo "  🔐 SHA256: \$ARCHIVE_SHA256"

# Save info for later
echo "\$ARCHIVE_NAME" > /tmp/archive_name.txt
EOF_TAR

echo ""
echo "[6/7] Downloading archive and PCAP to CloudShell..."
ARCHIVE_NAME=$(ssh "$HONEYPOT_USER@$HONEYPOT_IP" cat /tmp/archive_name.txt)
scp "$HONEYPOT_USER@$HONEYPOT_IP:$ARCHIVE_NAME" "$LOCAL_ARCHIVE_DIR/"
scp "$HONEYPOT_USER@$HONEYPOT_IP:/tmp/cowrie_traffic.pcap" "$LOCAL_ARCHIVE_DIR/"

echo ""
echo "[7/7] Verifying downloads..."
cd "$LOCAL_ARCHIVE_DIR"
ls -lh
sha256sum cowrie_logs_complete_*.tar.gz
sha256sum cowrie_traffic.pcap

echo ""
echo "========================================="
echo "✅ LOG PULL COMPLETE!"
echo "========================================="
echo ""
echo "📁 Files are in: $LOCAL_ARCHIVE_DIR"
echo ""
echo "📥 To download from CloudShell to your local machine:"
echo "   1. In CloudShell menu, click 'Actions' → 'Download file'"
echo "   2. Enter path: $LOCAL_ARCHIVE_DIR/cowrie_logs_complete_*.tar.gz"
echo "   3. Repeat for: $LOCAL_ARCHIVE_DIR/cowrie_traffic.pcap"
echo ""
echo "Or upload to S3:"
echo "   aws s3 cp $LOCAL_ARCHIVE_DIR/ s3://your-bucket/cowrie-archives/ --recursive"
echo ""
echo "📊 Archive contains:"
echo "   - ALL JSON logs (day 1 → today)"
echo "   - ALL text logs"
echo "   - ALL downloaded malware samples"
echo "   - PCAP file (Wireshark-ready)"
echo ""

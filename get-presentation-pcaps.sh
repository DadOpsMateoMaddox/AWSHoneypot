#!/bin/bash
# Generate PCAP files for presentation from Cowrie JSON logs

echo "🎯 Generating PCAP files for PatriotPot presentation..."

# Create presentation directory
mkdir -p presentation-data

# Connect to honeypot and generate PCAPs
echo "📡 Connecting to honeypot to generate PCAP files..."

# Generate full PCAP from all logs
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 "cd /opt/cowrie && sudo python3 /home/ec2-user/AWSHoneypot/02-Deployment-Scripts/logs2pcap.py"

# Download full PCAP
echo "📥 Downloading full attack PCAP..."
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47:/tmp/cowrie_traffic.pcap ./presentation-data/patriotpot_all_attacks.pcap

# Generate recent attacks PCAP (last 7 days)
echo "📅 Generating recent attacks PCAP..."
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 "grep '$(date -d '7 days ago' +%Y-%m-)' /opt/cowrie/var/log/cowrie/cowrie.json > /tmp/recent_logs.json && sudo python3 /home/ec2-user/AWSHoneypot/02-Deployment-Scripts/logs2pcap.py /tmp/recent_logs.json /tmp/recent_traffic.pcap"

# Download recent PCAP
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47:/tmp/recent_traffic.pcap ./presentation-data/patriotpot_recent_attacks.pcap

# Generate top attacker PCAP
echo "🎯 Generating top attacker PCAP..."
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 '
TOP_IP=$(grep -o "\"src_ip\":\"[^\"]*\"" /opt/cowrie/var/log/cowrie/cowrie.json | sed "s/\"src_ip\":\"//" | sed "s/\"//" | sort | uniq -c | sort -nr | head -1 | awk "{print \$2}")
echo "Top attacker IP: $TOP_IP"
grep "\"src_ip\":\"$TOP_IP\"" /opt/cowrie/var/log/cowrie/cowrie.json > /tmp/top_attacker.json
sudo python3 /home/ec2-user/AWSHoneypot/02-Deployment-Scripts/logs2pcap.py /tmp/top_attacker.json /tmp/top_attacker.pcap
'

# Download top attacker PCAP
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47:/tmp/top_attacker.pcap ./presentation-data/patriotpot_top_attacker.pcap

# Generate sample JSON logs for presentation
echo "📋 Downloading sample JSON logs..."
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 "tail -100 /opt/cowrie/var/log/cowrie/cowrie.json" > ./presentation-data/sample_attack_logs.json

# Get attack statistics
echo "📊 Generating attack statistics..."
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 '
echo "=== PatriotPot Attack Statistics ===" > /tmp/stats.txt
echo "Total Events: $(wc -l < /opt/cowrie/var/log/cowrie/cowrie.json)" >> /tmp/stats.txt
echo "Unique Attackers: $(grep -o "\"src_ip\":\"[^\"]*\"" /opt/cowrie/var/log/cowrie/cowrie.json | sort | uniq | wc -l)" >> /tmp/stats.txt
echo "Login Attempts: $(grep "cowrie.login" /opt/cowrie/var/log/cowrie/cowrie.json | wc -l)" >> /tmp/stats.txt
echo "Commands Executed: $(grep "cowrie.command.input" /opt/cowrie/var/log/cowrie/cowrie.json | wc -l)" >> /tmp/stats.txt
echo "File Downloads: $(grep "cowrie.session.file_download" /opt/cowrie/var/log/cowrie/cowrie.json | wc -l)" >> /tmp/stats.txt
echo "" >> /tmp/stats.txt
echo "=== Top 10 Attacking Countries ===" >> /tmp/stats.txt
grep -o "\"src_ip\":\"[^\"]*\"" /opt/cowrie/var/log/cowrie/cowrie.json | sed "s/\"src_ip\":\"//" | sed "s/\"//" | sort | uniq -c | sort -nr | head -10 >> /tmp/stats.txt
'

# Download statistics
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47:/tmp/stats.txt ./presentation-data/attack_statistics.txt

echo "✅ Presentation data generated successfully!"
echo ""
echo "📁 Files created in presentation-data/:"
echo "   - patriotpot_all_attacks.pcap (Full attack history)"
echo "   - patriotpot_recent_attacks.pcap (Last 7 days)"
echo "   - patriotpot_top_attacker.pcap (Most active attacker)"
echo "   - sample_attack_logs.json (Sample JSON logs)"
echo "   - attack_statistics.txt (Attack statistics)"
echo ""
echo "🔍 Open PCAP files in Wireshark for analysis"
echo "📊 Use statistics file for presentation metrics"
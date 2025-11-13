# Final Project Summary - Quick Start

## 🎯 Purpose

This script generates the final 75-day project statistics, pulls all logs (JSON + PCAP), and posts everything to Discord.

## 🚀 Usage

### On the EC2 Instance:

```bash
# SSH to the honeypot
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# Navigate to scripts directory
cd AWSHoneypot/02-Deployment-Scripts

# Run the final summary script
sudo bash final_project_summary.sh
```

## 📊 What It Does

1. **Generates Top 10 Statistics** (75 days):
   - Top 10 Attacker IPs
   - Top 10 Usernames
   - Top 10 Passwords
   - Top 10 Commands
   - Top 10 Username:Password Combos
   - Top 10 SSH Client Versions
   - Top 10 Countries
   - Overall statistics summary

2. **Pulls All Logs**:
   - All JSON logs (cowrie.json + rotations)
   - All text logs
   - Downloaded malware/files

3. **Creates PCAP**:
   - Converts JSON logs to PCAP format for Wireshark analysis
   - Complete 75-day traffic capture

4. **Posts to Discord**:
   - Summary statistics
   - All top 10 lists
   - Archive download instructions

5. **Creates Archive**:
   - Compressed tar.gz with all files
   - SHA256 checksum
   - Manifest file

## 📥 Download the Archive

After the script completes, download from your local machine:

```bash
# From your local machine (not EC2)
scp -i ~/.ssh/gmu-honeypot-key.pem \
  ec2-user@44.218.220.47:~/final_project_archive/patriotpot_final_75days_*.tar.gz \
  ~/Downloads/
```

Or from CloudShell:

```bash
# Upload to S3
aws s3 cp ~/final_project_archive/patriotpot_final_75days_*.tar.gz \
  s3://your-bucket/final-archive/
```

## 🔧 Configuration

### Discord Webhook

The script will automatically find your Discord webhook from:
- `/opt/cowrie/discord_config.json`
- `/home/ec2-user/discord_config.json`
- `./discord_config.json`
- Environment variable: `DISCORD_WEBHOOK_URL`

If no webhook is configured, statistics will print to console only.

## 📦 Output Files

```
~/final_project_archive/
├── patriotpot_final_75days_YYYYMMDD_HHMMSS.tar.gz  # Main archive
└── manifest_YYYYMMDD_HHMMSS.txt                     # File manifest
```

## 📋 Archive Contents

```
patriotpot_final_75days_YYYYMMDD_HHMMSS.tar.gz
├── cowrie.json                    # Main JSON log
├── cowrie.json.1                  # Rotated logs
├── cowrie.json.*.gz               # Compressed rotations
├── cowrie.log                     # Text logs
├── cowrie_complete_75days.pcap    # PCAP file
└── downloads/                     # Downloaded files/malware
    └── [SHA256 hashes]
```

## 🎓 Project Information

**Project:** PatriotPot Deception Framework  
**Course:** GMU AIT670 - Cloud Computing  
**Semester:** Fall 2025  
**Duration:** 75 days  
**Status:** Complete - Cowrie Shutdown

## ⚡ Quick Reference

### Statistics Only (No Archive)

```bash
sudo python3 final_project_stats.py
```

### Just Create PCAP

```bash
python3 logs2pcap.py \
  /opt/cowrie/var/log/cowrie/cowrie.json \
  ~/cowrie_75days.pcap
```

### Check Archive Size Before Download

```bash
ls -lh ~/final_project_archive/
```

## 🐛 Troubleshooting

**Script fails with permission error:**
```bash
# Make sure to run with sudo
sudo bash final_project_summary.sh
```

**Discord webhook not working:**
```bash
# Check webhook configuration
cat /opt/cowrie/discord_config.json
```

**PCAP conversion fails:**
```bash
# Install scapy if needed
sudo pip3 install scapy
```

**Archive too large:**
```bash
# Check size before downloading
du -h ~/final_project_archive/*.tar.gz
```

## 📞 Support

If you encounter issues, check:
1. Cowrie logs exist: `ls -la /opt/cowrie/var/log/cowrie/`
2. Script permissions: `ls -l final_project_summary.sh`
3. Disk space: `df -h`

---

**Last Updated:** November 2025  
**Maintained By:** GMU AIT670 Team - PatriotPot Project

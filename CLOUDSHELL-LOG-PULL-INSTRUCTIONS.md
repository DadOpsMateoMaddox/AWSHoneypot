# 🚀 CLOUDSHELL LOG PULL - QUICK START

## Copy-Paste This Into Your CloudShell

```bash
# One-liner: Download script, make executable, and run
curl -sL https://raw.githubusercontent.com/DadOpsMateoMaddox/AWSHoneypot/main/02-Deployment-Scripts/cloudshell-pull-all-logs.sh -o ~/pull-logs.sh && chmod +x ~/pull-logs.sh && ~/pull-logs.sh
```

---

## OR: Manual Step-by-Step (If you already have the repo cloned in CloudShell)

### Step 1: Clone repo (if not already done)
```bash
cd ~
git clone https://github.com/DadOpsMateoMaddox/AWSHoneypot.git
cd AWSHoneypot
```

### Step 2: Run the log pull script
```bash
bash 02-Deployment-Scripts/cloudshell-pull-all-logs.sh
```

---

## What This Does

1. ✅ Installs prerequisites (python3, scapy, jq) on honeypot
2. ✅ Copies all Cowrie logs (JSON, text, rotations) from honeypot
3. ✅ Copies downloaded malware samples
4. ✅ Converts JSON logs to PCAP using logs2pcap.py
5. ✅ Creates compressed archive with checksums
6. ✅ Downloads archive and PCAP to CloudShell
7. ✅ Prints file locations and SHA256 checksums

---

## Expected Output

```
=========================================
🚀 COWRIE LOG PULL - COMPLETE ARCHIVE
=========================================

Target: ec2-user@44.218.220.47
Local staging: /home/cloudshell-user/cowrie_logs_20251113_143022

[1/7] Installing prerequisites on honeypot...
✅ Prerequisites ready

[2/7] Copying conversion script to honeypot...
✅ Conversion script ready

[3/7] Creating archive of ALL Cowrie logs...
  📁 Copying JSON logs...
  📁 Copying text logs...
  📁 Copying download artifacts...
  📅 Date range: 2025-10-01T12:00:00+00:00 → 2025-11-13T14:30:22+00:00
✅ Archive staging complete

[4/7] Converting JSON to PCAP...
Converting /opt/cowrie/var/log/cowrie/cowrie.json to /tmp/cowrie_traffic.pcap...
✅ Converted 45621 packets to /tmp/cowrie_traffic.pcap

[5/7] Creating compressed archive...
  📦 Archive: /tmp/cowrie_logs_complete_20251113_143022.tar.gz
  📏 Size: 234M
  🔐 SHA256: a1b2c3d4e5f6...

[6/7] Downloading archive and PCAP to CloudShell...
cowrie_logs_complete_20251113_143022.tar.gz     100%  234MB   15.2MB/s   00:15
cowrie_traffic.pcap                             100%   89MB   14.8MB/s   00:06

[7/7] Verifying downloads...
-rw-r--r-- 1 cloudshell-user cloudshell-user 234M Nov 13 14:30 cowrie_logs_complete_20251113_143022.tar.gz
-rw-r--r-- 1 cloudshell-user cloudshell-user  89M Nov 13 14:31 cowrie_traffic.pcap

a1b2c3d4e5f6... cowrie_logs_complete_20251113_143022.tar.gz
f6e5d4c3b2a1... cowrie_traffic.pcap

=========================================
✅ LOG PULL COMPLETE!
=========================================

📁 Files are in: /home/cloudshell-user/cowrie_logs_20251113_143022

📥 To download from CloudShell to your local machine:
   1. In CloudShell menu, click 'Actions' → 'Download file'
   2. Enter path: /home/cloudshell-user/cowrie_logs_20251113_143022/cowrie_logs_complete_20251113_143022.tar.gz
   3. Repeat for: /home/cloudshell-user/cowrie_logs_20251113_143022/cowrie_traffic.pcap

Or upload to S3:
   aws s3 cp /home/cloudshell-user/cowrie_logs_20251113_143022/ s3://your-bucket/cowrie-archives/ --recursive

📊 Archive contains:
   - ALL JSON logs (day 1 → today)
   - ALL text logs
   - ALL downloaded malware samples
   - PCAP file (Wireshark-ready)
```

---

## Download Files from CloudShell to Your Local Machine

### Option 1: CloudShell Download Menu (Recommended)

1. In CloudShell, click **Actions** → **Download file**
2. Enter the full path when prompted:
   ```
   /home/cloudshell-user/cowrie_logs_20251113_XXXXXX/cowrie_logs_complete_20251113_XXXXXX.tar.gz
   ```
3. File downloads to your browser's Downloads folder
4. Repeat for the PCAP file:
   ```
   /home/cloudshell-user/cowrie_logs_20251113_XXXXXX/cowrie_traffic.pcap
   ```

### Option 2: Upload to S3 (If you have an S3 bucket)

```bash
# In CloudShell:
LOGS_DIR=$(ls -dt ~/cowrie_logs_* | head -1)
aws s3 cp $LOGS_DIR/ s3://your-bucket-name/cowrie-archives/ --recursive

# Then download from S3 to your local machine:
aws s3 sync s3://your-bucket-name/cowrie-archives/ ~/Downloads/cowrie-archives/
```

---

## Verify Archive Integrity

After downloading to your local machine:

```bash
# Extract archive
cd ~/Downloads
tar -tzf cowrie_logs_complete_*.tar.gz | head -20  # List first 20 files
tar -xzf cowrie_logs_complete_*.tar.gz            # Extract

# Verify checksums match
sha256sum cowrie_logs_complete_*.tar.gz
sha256sum cowrie_traffic.pcap
# Compare with checksums printed by the script

# Open PCAP in Wireshark
wireshark cowrie_traffic.pcap
# or
tshark -r cowrie_traffic.pcap -q -z io,stat,0
```

---

## Troubleshooting

### If script fails to connect to honeypot:

```bash
# Test SSH connection manually
ssh ec2-user@44.218.220.47
# If this fails, check:
# 1. Security group allows your CloudShell IP
# 2. Instance is running (not stopped)
# 3. SSH key is configured in CloudShell
```

### If scapy install fails:

```bash
# SSH to honeypot and install manually
ssh ec2-user@44.218.220.47
sudo pip3 install scapy --upgrade
```

### If archive is huge (>500MB):

```bash
# Skip malware downloads (can save 100s of MB)
# Edit the script and comment out this line:
# sudo cp -a /opt/cowrie/var/lib/cowrie/downloads "$REMOTE_TEMP/" 2>/dev/null || true
```

---

## What's in the Archive

```
cowrie_logs_complete_YYYYMMDD_HHMMSS.tar.gz
├── cowrie_logs/
│   ├── cowrie.json              # Main JSON log (all events)
│   ├── cowrie.json.1            # Rotated JSON logs
│   ├── cowrie.json.2.gz         # Compressed rotated logs
│   ├── cowrie.log               # Text format logs
│   ├── cowrie.log.1             # Rotated text logs
│   └── ...
├── downloads/                    # Malware samples
│   ├── [SHA256 hashes]          # Downloaded files from attackers
│   └── ...
└── cowrie_traffic.pcap          # Wireshark PCAP file
```

---

## Next Steps After Download

1. **Analyze in Wireshark**: Open `cowrie_traffic.pcap`
2. **Extract stats**: Use `jq` to analyze JSON logs
3. **Share with team**: Upload to shared drive or S3
4. **Document findings**: Add to project report

---

## Need Help?

- Script location: `02-Deployment-Scripts/cloudshell-pull-all-logs.sh`
- Full guide: `DISCORD-MONITORING-FIX-SUMMARY.md`
- Questions? Tag @Kevin in Discord

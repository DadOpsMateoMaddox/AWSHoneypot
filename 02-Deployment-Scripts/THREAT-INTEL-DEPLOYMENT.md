# 🔐 Threat Intelligence Enrichment - Deployment Guide

## Overview

This guide shows how to add threat intelligence enrichment to your Cowrie honeypot Discord alerts using AbuseIPDB, OTX, VirusTotal, Shodan, and IPInfo.

---

## 📋 Prerequisites

- Active Cowrie honeypot on EC2 (`44.218.220.47`)
- Discord monitor already working
- API keys from threat intel providers

---

## 🔑 Step 1: Get API Keys

Sign up for free API keys:

1. **AbuseIPDB** (https://www.abuseipdb.com/api)
   - Free tier: 1,000 requests/day
   - Required for abuse reporting

2. **AlienVault OTX** (https://otx.alienvault.com/)
   - Free account
   - Sign up and get API key from settings

3. **VirusTotal** (https://www.virustotal.com/gui/my-apikey)
   - Free tier: 4 requests/minute
   - Requires Google account

4. **Shodan** (https://account.shodan.io/)
   - Free tier: 1 credit/month (very limited)
   - Optional but useful

5. **IPInfo** (https://ipinfo.io/)
   - Free tier: 50,000 requests/month
   - Optional (works without key for basic data)

---

## 📦 Step 2: Deploy Files to EC2

### A) Copy files to the instance

```bash
# From your local machine
cd "/mnt/host/d/School/AIT670 Cloud Computing In Person/Group Project/AWSHoneypot"

# Copy threat enrichment files
scp -i ~/.ssh/gmu-honeypot-key.pem \
  02-Deployment-Scripts/secrets_loader.py \
  02-Deployment-Scripts/threat_enrichment.py \
  02-Deployment-Scripts/production.env \
  02-Deployment-Scripts/requirements-threat-intel.txt \
  ec2-user@44.218.220.47:/tmp/
```

### B) SSH to instance and move files

```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# Move files to discord-monitor directory
sudo mv /tmp/secrets_loader.py /opt/cowrie/discord-monitor/
sudo mv /tmp/threat_enrichment.py /opt/cowrie/discord-monitor/
sudo mv /tmp/production.env /opt/cowrie/discord-monitor/.env

# Set ownership and permissions
sudo chown ec2-user:ec2-user /opt/cowrie/discord-monitor/*.py
sudo chown ec2-user:ec2-user /opt/cowrie/discord-monitor/.env
sudo chmod 600 /opt/cowrie/discord-monitor/.env
sudo chmod 755 /opt/cowrie/discord-monitor/*.py
```

---

## 🐍 Step 3: Install Python Dependencies

```bash
# SSH to instance
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# Install dependencies
sudo pip3 install requests python-dotenv boto3

# Or use requirements file
cd /opt/cowrie/discord-monitor
sudo pip3 install -r /tmp/requirements-threat-intel.txt
```

---

## 🧪 Step 4: Test the Setup

### Test secrets loader

```bash
cd /opt/cowrie/discord-monitor
python3 secrets_loader.py
```

**Expected output:**
```
============================================================
Secrets Loader - Safe Summary
============================================================

.env file loaded: True

Key                       Present   
-----------------------------------
ABUSEIPDB_KEY             ✓ Yes     
OTX_KEY                   ✓ Yes     
IPINFO_KEY                ✗ No      
VIRUSTOTAL_KEY            ✓ Yes     
SHODAN_KEY                ✗ No      

============================================================
Total secrets loaded: 3
============================================================

✓ All required secrets validated successfully!
```

### Test threat enrichment

```bash
# Test with a known malicious IP
python3 threat_enrichment.py 45.95.168.0
```

**Expected output:**
```json
{
  "ip": "45.95.168.0",
  "timestamp": "2025-10-12T...",
  "sources": ["abuseipdb", "otx", "virustotal", "ipinfo"],
  "abuseipdb": {
    "abuse_confidence_score": 100,
    "total_reports": 523,
    ...
  }
}
```

---

## 🔗 Step 5: Integrate with Discord Monitor

### Option A: Modify Enhanced_Honeypot_Monitor_Script.py

Add at the top (after imports):

```python
# Threat intelligence enrichment
try:
    from threat_enrichment import get_enrichment
    ENRICHMENT_ENABLED = True
    enricher = get_enrichment()
except ImportError:
    ENRICHMENT_ENABLED = False
    print("⚠️ Threat enrichment disabled (modules not found)")
```

In the alert sending function, add enrichment:

```python
async def send_discord_alert(self, event_data):
    # ... existing code ...
    
    # Add threat intel if IP address present
    if ENRICHMENT_ENABLED and 'src_ip' in event_data:
        src_ip = event_data['src_ip']
        enrichment = enricher.enrich_ip(src_ip)
        threat_intel = enricher.format_for_discord(enrichment)
        
        # Add to embed or message
        embed['fields'].append({
            'name': '🔍 Threat Intelligence',
            'value': threat_intel,
            'inline': False
        })
```

### Option B: Create new monitor script (recommended)

See `Enhanced_Honeypot_Monitor_Script.py` - already has enrichment placeholders.

---

## 🔄 Step 6: Restart Services

```bash
# Restart Discord monitor to load new code
sudo systemctl restart cowrie-discord-monitor

# Check status
sudo systemctl status cowrie-discord-monitor

# Watch logs
sudo journalctl -u cowrie-discord-monitor -f
```

---

## 📊 Step 7: Verify Alerts

1. Connect to honeypot to trigger alert:
   ```bash
   ssh -p 2222 test@44.218.220.47
   ```

2. Check Discord for enriched alert with:
   - 🔴/🟡/🟢 AbuseIPDB score
   - VirusTotal detections
   - OTX threat pulse count
   - Shodan open ports
   - Geolocation data

---

## 🗂️ Cache Management

Threat intel results are cached for 48 hours in:
```
/opt/cowrie/discord-monitor/intel_cache.json
```

**Clear cache:**
```bash
sudo rm /opt/cowrie/discord-monitor/intel_cache.json
sudo systemctl restart cowrie-discord-monitor
```

**Check cache size:**
```bash
ls -lh /opt/cowrie/discord-monitor/intel_cache.json
wc -l /opt/cowrie/discord-monitor/intel_cache.json
```

---

## 🔒 Security Notes

### Protect your .env file

```bash
# Verify permissions
ls -la /opt/cowrie/discord-monitor/.env

# Should be: -rw------- (600)
# Owner: ec2-user

# Fix if needed
sudo chmod 600 /opt/cowrie/discord-monitor/.env
sudo chown ec2-user:ec2-user /opt/cowrie/discord-monitor/.env
```

### Never commit secrets

- `.env` is in `.gitignore`
- `production.env` is in `.gitignore`
- Always use `.env.example` for templates

### Rotate keys periodically

```bash
# Edit .env with new keys
nano /opt/cowrie/discord-monitor/.env

# Restart to reload
sudo systemctl restart cowrie-discord-monitor
```

---

## 🐛 Troubleshooting

### "No threat intel API keys available"

**Check:**
```bash
cd /opt/cowrie/discord-monitor
python3 secrets_loader.py
```

**Fix:** Ensure `.env` exists and has correct keys.

### "requests library not installed"

**Fix:**
```bash
sudo pip3 install requests python-dotenv
```

### "Import threat_enrichment failed"

**Check Python path:**
```bash
cd /opt/cowrie/discord-monitor
python3 -c "import threat_enrichment; print('OK')"
```

### API rate limits exceeded

- AbuseIPDB: 1,000/day (upgrade for more)
- VirusTotal: 4/minute (upgrade for more)
- Cache reduces API calls significantly

**Check cache hit rate in logs:**
```bash
sudo journalctl -u cowrie-discord-monitor | grep "Cache hit"
```

### High latency alerts

- Each IP lookup queries 3-5 APIs (3s timeout each)
- Total delay: up to 15s per unique IP
- Cache makes subsequent lookups instant

---

## 📈 Performance Optimization

### Enable async enrichment (future)

Modify monitor to enrich IPs in background:
```python
import asyncio

async def enrich_async(ip):
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, enricher.enrich_ip, ip)
```

### Batch enrichment

Cache all IPs from last 24h during off-peak:
```bash
# Cron job to pre-cache common IPs
0 2 * * * python3 /opt/cowrie/discord-monitor/precache_ips.py
```

---

## 🔄 Migrating to AWS Secrets Manager (Optional)

### Create secret in AWS

```bash
aws secretsmanager create-secret \
  --name honeypot-threat-intel-keys \
  --description "Threat intel API keys for honeypot" \
  --secret-string file://secrets.json \
  --region us-east-1
```

### Update .env

```bash
# Add to .env
HONEYBOMB_AWS_SECRET=honeypot-threat-intel-keys
```

### Grant EC2 instance role permission

Add policy to instance role:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "secretsmanager:GetSecretValue",
    "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:honeypot-threat-intel-keys-*"
  }]
}
```

---

## 📚 API Documentation Links

- AbuseIPDB: https://docs.abuseipdb.com/
- OTX: https://otx.alienvault.com/api
- VirusTotal: https://developers.virustotal.com/reference/overview
- Shodan: https://developer.shodan.io/api
- IPInfo: https://ipinfo.io/developers

---

## ✅ Success Criteria

- [x] Secrets loaded without errors
- [x] All required API keys validated
- [x] Test IP enrichment returns data
- [x] Discord alerts include threat intel
- [x] Cache reduces API calls
- [x] No secrets logged or exposed

---

**Next Steps:**
1. Monitor API usage and upgrade if needed
2. Add custom threat scoring logic
3. Create weekly threat report from enrichment data
4. Integrate with SIEM or log aggregator

---

**Questions?** Check logs:
```bash
sudo journalctl -u cowrie-discord-monitor -n 100 --no-pager
```

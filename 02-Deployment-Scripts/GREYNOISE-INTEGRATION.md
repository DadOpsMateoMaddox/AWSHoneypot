# 🌐 GreyNoise Integration Guide

## What is GreyNoise?

**GreyNoise** identifies IPs engaged in **mass internet scanning** vs. **targeted attacks**. This is critical for honeypot analysis because it helps you distinguish between:

- 🟢 **Background Internet Noise** - Automated scanners hitting everyone (Shodan, Censys, security researchers)
- 🔴 **Malicious Mass Scanners** - Botnets, worms, and attackers searching for vulnerable systems
- 🎯 **Targeted Attacks** - IPs NOT in GreyNoise (specifically targeting YOU)

---

## Why This Matters for Honeypots

### Scenario 1: Mass Scanner (GreyNoise Seen)
```
IP: 1.2.3.4
GreyNoise: ✅ SEEN - Malicious mass scanner
Tags: SSH Bruteforce, Port Scanner, Mirai
Ports: 22, 23, 2222, 8080, 445

Conclusion: This is internet background noise. 
Part of a botnet scanning millions of IPs.
```

### Scenario 2: Targeted Attack (Not in GreyNoise)
```
IP: 5.6.7.8
GreyNoise: ❌ NOT SEEN - Not mass scanning

Conclusion: This IP is NOT scanning the entire internet.
They may be specifically targeting YOUR honeypot/network.
🚨 HIGH PRIORITY for investigation!
```

---

## API Access

### Free Community API
- **Rate Limit**: 100 requests/day
- **Features**: Basic IP lookup, classification
- **Signup**: https://www.greynoise.io/viz/account/create

### Paid API (Recommended for Production)
- **Rate Limit**: 10,000+ requests/day
- **Features**: Full metadata, tags, actor attribution, raw scan data
- **Pricing**: Contact GreyNoise sales

---

## Integration Status

### ✅ Already Integrated
GreyNoise is **already built into** your threat enrichment system:

1. **threat_enrichment.py** - Has `_query_greynoise()` method
2. **secrets_loader.py** - Supports `GREYNOISE_KEY` environment variable
3. **.env.example** - Template includes GreyNoise key placeholder

### 🔧 To Enable

**Step 1: Get API Key**
```bash
# Visit: https://www.greynoise.io/viz/account
# Sign up → API → Copy your API key
```

**Step 2: Add to .env**
```bash
# On EC2 honeypot
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# Edit .env file
sudo nano /opt/cowrie/discord-monitor/.env

# Add this line:
GREYNOISE_KEY=your_api_key_here_1234567890abcdef
```

**Step 3: Restart Discord Monitor**
```bash
sudo systemctl restart cowrie-discord-monitor

# Verify it loaded
sudo journalctl -u cowrie-discord-monitor -n 20 | grep -i greynoise
# Should see: "Threat enrichment initialized (6/6 APIs available)"
```

**Step 4: Test**
```bash
# Trigger alert
ssh -p 2222 test@44.218.220.47

# Check Discord - should see GreyNoise data:
# 🟢 GreyNoise: Not mass scanning (targeted attack?)
```

---

## Testing GreyNoise

### Command-Line Test (Standalone)

```bash
# Test with the standalone script
cd ~/AWSHoneypot/02-Deployment-Scripts

# Test known malicious scanner
python3 greynoiserequest.py 185.220.101.1

# Output:
# ============================================================
# GreyNoise Report for 185.220.101.1
# ============================================================
# 🔍 Classification: MALICIOUS
#    Seen scanning: Yes
#    ⚠️  Known malicious scanner
# 👤 Actor: Tor Exit Node
# 🏷️  Tags: Tor, VPN Proxy, Anonymous
# 🔎 Scanning Activity:
#    - Port 22/tcp
#    - Port 23/tcp
#    - Port 80/tcp
# ⏰ Last seen: 2025-10-13T10:23:45Z
# ============================================================

# Test your home IP (probably not mass scanning)
python3 greynoiserequest.py $(curl -s ifconfig.me)
# Output: ❌ IP not found in GreyNoise database
```

### Integration Test

```bash
# Test threat_enrichment.py with GreyNoise
cd /opt/cowrie/discord-monitor

# Source environment
export $(grep -v '^#' .env | xargs)

# Test enrichment for known scanner
python3 threat_enrichment.py 185.220.101.1

# Should see output including:
# {
#   "greynoise": {
#     "seen": true,
#     "classification": "malicious",
#     "noise": true,
#     "actor": "Tor Exit Node",
#     "tags": ["Tor", "VPN Proxy"],
#     "scanned_ports": [22, 23, 80, 443, 2222]
#   }
# }
```

---

## Discord Alert Examples

### Mass Scanner (Seen by GreyNoise)
```
🔴 New SSH Login Attempt
IP: 185.220.101.1
Username: root
Password: admin123

Threat Intel for 185.220.101.1
Sources: greynoise, abuseipdb, virustotal, ipinfo

🔴 GreyNoise: MALICIOUS mass scanner
   👤 Actor: Tor Exit Node
   🏷️ Tags: Tor, VPN Proxy, SSH Bruteforce
   🔍 Scanning ports: 22, 23, 2222, 8080
🔴 AbuseIPDB: 98% confidence, 234 reports
🔴 VirusTotal: 45 malicious, 12 suspicious
🌍 Location: Unknown, Unknown
```

### Targeted Attack (NOT in GreyNoise)
```
🟠 New SSH Login Attempt
IP: 203.0.113.42
Username: ubuntu
Password: MyH0neypotP@ss

Threat Intel for 203.0.113.42
Sources: greynoise, abuseipdb, ipinfo

🟢 GreyNoise: Not mass scanning (targeted attack?)
🟡 AbuseIPDB: 12% confidence, 2 reports
🌍 Location: Beijing, CN
🏢 Org: Example ISP (AS12345)

⚠️ ALERT: This IP is not mass scanning!
Possibly targeted reconnaissance.
```

---

## API Response Fields

### Key Fields from GreyNoise

```json
{
  "seen": true,                      // Is this IP scanning the internet?
  "classification": "malicious",     // benign, malicious, unknown
  "noise": true,                     // Is this background internet noise?
  "actor": "Mirai Botnet",          // Known threat actor
  "tags": [                          // What they're scanning for
    "SSH Bruteforce",
    "Telnet Scanner",
    "Mirai Botnet"
  ],
  "scanned_ports": [22, 23, 2222],  // Ports they scan
  "last_seen": "2025-10-13T10:23:45Z",
  "country": "CN",
  "organization": "Example Hosting"
}
```

### Classifications

| Classification | Meaning | Example |
|----------------|---------|---------|
| `malicious` | Known bad actor | Mirai botnet, ransomware scanners |
| `benign` | Research/legitimate | Shodan, Censys, security researchers |
| `unknown` | Unclear intent | New scanners without attribution |
| NOT SEEN | Not mass scanning | Potentially targeted (investigate!) |

---

## Analysis Workflows

### Workflow 1: Triaging Alerts

```python
if greynoise_data['seen']:
    if greynoise_data['classification'] == 'malicious':
        priority = "LOW"  # Known malicious mass scanner
        action = "Log for statistics, block if desired"
    
    elif greynoise_data['classification'] == 'benign':
        priority = "IGNORE"  # Legitimate research scanner
        action = "Whitelist (Shodan, Censys, etc.)"
else:
    priority = "HIGH"  # NOT mass scanning
    action = "Investigate immediately - potential targeted attack"
```

### Workflow 2: Automated Response

```python
# In your Discord monitor integration:

intel = enricher.enrich_ip(src_ip)

if 'greynoise' in intel:
    gn = intel['greynoise']
    
    if not gn['seen']:
        # Not mass scanning - high priority!
        alert_level = "🚨 HIGH PRIORITY"
        color = 0xFF0000  # Red
        
        # Additional actions:
        # - Send alert to security team
        # - Create incident ticket
        # - Enable detailed logging
        # - Block at firewall
    
    elif gn['classification'] == 'malicious' and 'Mirai' in gn.get('tags', []):
        # Known Mirai botnet
        alert_level = "📊 Statistical"
        color = 0x808080  # Gray
        
        # Actions:
        # - Auto-block
        # - Increment botnet counter
        # - No manual investigation needed
```

---

## Rate Limiting

### Free Tier (100/day)
```python
# Cache aggressively - already built in!
# Cache TTL: 48 hours
# 100 requests = 100 unique IPs/day

# Tips:
# - Let cache handle repeated IPs
# - Focus on new/unusual IPs
# - Use for high-priority alerts only
```

### Production (10,000+/day)
```python
# Enrich every connection
# Real-time classification
# Full metadata access
```

---

## Troubleshooting

### Issue: "GreyNoise API key not found"

```bash
# Check .env file
sudo cat /opt/cowrie/discord-monitor/.env | grep GREYNOISE

# Should see:
GREYNOISE_KEY=your_key_here

# If missing, add it:
echo "GREYNOISE_KEY=your_api_key" | sudo tee -a /opt/cowrie/discord-monitor/.env
sudo chmod 600 /opt/cowrie/discord-monitor/.env
```

### Issue: "GreyNoise API timeout"

```bash
# Check network connectivity
curl -s https://api.greynoise.io/ping

# Check logs for details
sudo journalctl -u cowrie-discord-monitor | grep -i greynoise
```

### Issue: "Rate limit exceeded"

```bash
# Check your current usage
curl -H "key: your_api_key" https://api.greynoise.io/v3/ping

# Upgrade to paid plan or:
# - Increase cache TTL (default: 48h)
# - Reduce enrichment frequency
# - Filter low-priority IPs
```

---

## Advanced: Custom GreyNoise Queries

### GNQL (GreyNoise Query Language)

```bash
# Find all Mirai scanners
curl -X GET "https://api.greynoise.io/v2/experimental/gnql" \
  -H "key: YOUR_API_KEY" \
  -d "query=tags:Mirai AND classification:malicious"

# Find SSH bruteforcers from China
curl -X GET "https://api.greynoise.io/v2/experimental/gnql" \
  -H "key: YOUR_API_KEY" \
  -d "query=tags:'SSH Bruteforce' AND country:CN"
```

### IP Timeline (Historical Data)

```bash
# See IP activity over time
curl "https://api.greynoise.io/v3/ip/timeline/185.220.101.1" \
  -H "key: YOUR_API_KEY"
```

---

## References

- **GreyNoise API Docs**: https://docs.greynoise.io/
- **GreyNoise Visualizer**: https://www.greynoise.io/viz
- **Community Forums**: https://discuss.greynoise.io/
- **Blog**: https://www.greynoise.io/blog
- **GNQL Guide**: https://docs.greynoise.io/docs/using-gnql

---

## Quick Reference

```bash
# Enable GreyNoise
echo "GREYNOISE_KEY=your_key" | sudo tee -a /opt/cowrie/discord-monitor/.env

# Test standalone
python3 greynoiserequest.py 185.220.101.1

# Test integration
python3 threat_enrichment.py 185.220.101.1

# Check if loaded
sudo journalctl -u cowrie-discord-monitor | grep "APIs available"

# Monitor alerts
tail -f /var/log/cowrie/cowrie.json | jq 'select(.eventid=="cowrie.login.failed")'
```

---

**Key Takeaway**: GreyNoise helps you focus on **targeted attacks** by filtering out **internet background noise**. IPs **NOT** in GreyNoise are your highest priority! 🎯

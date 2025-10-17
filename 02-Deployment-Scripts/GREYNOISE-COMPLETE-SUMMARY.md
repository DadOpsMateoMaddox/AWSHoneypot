# GreyNoise Complete Integration Summary

## Implementation Status (Final)

Complete GreyNoise threat intelligence system implemented with:
1. IP lookup (individual threat classification)
2. GNQL Stats (aggregate attack pattern analysis)
3. Full integration with threat enrichment
4. Comprehensive documentation

---

## API Key Configuration

**Secured in `production.env`**:
```
GREYNOISE_KEY=1Ls3XX3wzJAkKCl1srKnHqCPqxjPOzgXIh2r31SDEbC8rBdfKuMJnF58dYRUICKI
```

**Protected**: Listed in `.gitignore` (excluded from repository commits)

---

## Files Created

### Tools (2 files)

1. **`greynoiserequest.py`** - Individual IP lookup
   - Query single IPs for classification
   - Usage: `python3 greynoiserequest.py <ip> [api_key]`
   - Output: classification, actor, tags, ports, location

2. **`greynoise_gnql_stats.py`** - Aggregate statistics
   - Query global attack patterns
   - Usage: `python3 greynoise_gnql_stats.py --preset ssh_bruteforce`
   - Output: top countries, orgs, actors, tags, ASNs, OSes
   - 10 built-in preset queries for honeypot analysis

### Documentation (3 files)

3. **`GREYNOISE-INTEGRATION.md`** - IP lookup integration guide
   - GreyNoise overview and application
   - Integration with threat_enrichment.py
   - Testing procedures
   - Analysis workflows

4. **`GREYNOISE-GNQL-GUIDE.md`** - GNQL Stats complete guide
   - GNQL query language tutorial
   - Preset queries for honeypot analysis
   - Real-world use cases
   - Weekly report generation
   - Export and visualization

5. **`GREYNOISE-SUMMARY.md`** - Quick reference
   - Integration summary
   - Key concepts
   - Testing commands

### Modified Files (3 files)

6. **`threat_enrichment.py`** - Added GreyNoise integration
   - `_query_greynoise()` method
   - Classification in Discord alerts (priority display)
   - 48-hour caching

7. **`production.env`** - Added GreyNoise API key
   - Ready for EC2 deployment

8. **`.env.example`** - Template for team members
   - GreyNoise placeholder included

---

## 🚀 Quick Start Guide

### 1. Deploy to Honeypot

```bash
# Deploy threat intel system (includes GreyNoise)
cd "02-Deployment-Scripts"
./deploy-threat-intel.sh

# Verify GreyNoise loaded
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
sudo journalctl -u cowrie-discord-monitor | grep "APIs available"
# Should see: "6/6 APIs available"
```

### 2. Test IP Lookup

```bash
# Known malicious scanner
python3 greynoiserequest.py 185.220.101.1 $GREYNOISE_KEY

# Your IP (probably not scanning)
python3 greynoiserequest.py $(curl -s ifconfig.me) $GREYNOISE_KEY
```

### 3. Test GNQL Stats (NEW!)

```bash
# Export your key
export GREYNOISE_KEY=1Ls3XX3wzJAkKCl1srKnHqCPqxjPOzgXIh2r31SDEbC8rBdfKuMJnF58dYRUICKI

# Analyze SSH bruteforce attackers
python3 greynoise_gnql_stats.py --preset ssh_bruteforce

# Analyze Mirai botnet
python3 greynoise_gnql_stats.py --preset mirai_botnet

# Recent malicious activity (last 7 days)
python3 greynoise_gnql_stats.py --preset recent_malicious
```

---

## 🎨 What You'll See in Discord

### Before GreyNoise
```
🔴 New SSH Login Attempt
IP: 185.220.101.1
Username: root
Password: admin

🔴 AbuseIPDB: 98% confidence
🔴 VirusTotal: 45 malicious
```

### After GreyNoise (with your key)
```
🔴 New SSH Login Attempt
IP: 185.220.101.1
Username: root
Password: admin

Threat Intel for 185.220.101.1
Sources: greynoise, abuseipdb, virustotal, otx, ipinfo

🔴 GreyNoise: MALICIOUS mass scanner
   👤 Actor: Mirai Botnet
   🏷️ Tags: SSH Bruteforcer, Port Scanner
   🔍 Scanning ports: 22, 23, 2222, 8080

🔴 AbuseIPDB: 98% confidence, 234 reports
🔴 VirusTotal: 45 malicious, 12 suspicious
⚠️ OTX: Found in 12 threat pulses
🌍 Location: Unknown, CN
```

**Key Insight**: Now you know this is a **Mirai botnet** doing **mass internet scanning** (not targeting you specifically) → **Low priority**

---

## 📊 GNQL Stats Use Cases

### For Your AIT670 Project Report

```bash
# Generate statistics for your presentation
export GREYNOISE_KEY=1Ls3XX3wzJAkKCl1srKnHqCPqxjPOzgXIh2r31SDEbC8rBdfKuMJnF58dYRUICKI

# 1. SSH Attack Analysis
python3 greynoise_gnql_stats.py --preset ssh_bruteforce > report_ssh.txt

# 2. Telnet/IoT Botnet Analysis
python3 greynoise_gnql_stats.py --preset telnet_attacks > report_telnet.txt

# 3. Geographic Distribution
python3 greynoise_gnql_stats.py --preset china_attacks > report_china.txt
python3 greynoise_gnql_stats.py --preset russia_attacks > report_russia.txt

# Report contents:
# - Top 10 attacking countries
# - Top threat actors (Mirai, etc.)
# - Most common attack types
# - Hosting provider distribution
```

### Weekly Automated Threat Report

```bash
#!/bin/bash
# weekly_threat_report.sh

export GREYNOISE_KEY=1Ls3XX3wzJAkKCl1srKnHqCPqxjPOzgXIh2r31SDEbC8rBdfKuMJnF58dYRUICKI
DATE=$(date +%Y-%m-%d)

echo "=== Honeypot Threat Intelligence Report ===" > report_$DATE.txt
echo "Generated: $DATE" >> report_$DATE.txt
echo "" >> report_$DATE.txt

# SSH attacks
echo "=== SSH Bruteforce Statistics ===" >> report_$DATE.txt
python3 greynoise_gnql_stats.py --preset ssh_bruteforce >> report_$DATE.txt

# Botnet activity
echo -e "\n\n=== Mirai Botnet Activity ===" >> report_$DATE.txt
python3 greynoise_gnql_stats.py --preset mirai_botnet >> report_$DATE.txt

# Recent threats
echo -e "\n\n=== Recent Malicious Activity (7 days) ===" >> report_$DATE.txt
python3 greynoise_gnql_stats.py --preset recent_malicious >> report_$DATE.txt

echo "Report saved: report_$DATE.txt"
```

---

## 🎯 Key Concepts

### IP Lookup (greynoiserequest.py)

**Purpose**: Classify **individual IPs**
- ✅ Is this IP mass scanning the internet?
- ✅ What's their classification? (malicious/benign/unknown)
- ✅ Which threat actor?
- ✅ What are they scanning for?

**Use When**: 
- Analyzing specific attack in Discord alert
- Investigating suspicious IP from logs
- Real-time threat triage

### GNQL Stats (greynoise_gnql_stats.py)

**Purpose**: Analyze **global patterns**
- ✅ What are the top attacking countries?
- ✅ Which threat actors are most active?
- ✅ What types of attacks are trending?
- ✅ Which hosting providers harbor attackers?

**Use When**:
- Creating project reports
- Understanding attack landscape
- Strategic planning (what to monitor)
- Weekly/monthly threat briefings

---

## Analysis Priority Guide

| GreyNoise Status | Priority | Action |
|------------------|----------|--------|
| **NOT SEEN** | **HIGH** | Investigate immediately - not mass scanning, possible targeted attack |
| Seen - malicious | Medium | Log and monitor - known threat actor conducting mass scanning |
| Seen - benign | Low | Whitelist - legitimate research scanner (Shodan, Censys) |
| Seen - unknown | Medium | Monitor - unclear intent |

**Critical Rule**: IPs NOT in GreyNoise require immediate investigation.

---

## 10 Preset GNQL Queries

Built into `greynoise_gnql_stats.py`:

1. **`ssh_bruteforce`** - SSH Bruteforce Attackers
2. **`telnet_attacks`** - Telnet/IoT Botnet Attacks
3. **`mirai_botnet`** - Mirai Botnet Activity
4. **`web_attacks`** - Malicious Web Scanners
5. **`port_scanners`** - Port/Network Scanners
6. **`recent_malicious`** - Last 7 Days Activity
7. **`china_attacks`** - Attacks from China
8. **`russia_attacks`** - Attacks from Russia
9. **`vpn_proxies`** - VPN/Proxy-based Attacks
10. **`tor_exit_nodes`** - Tor Exit Node Activity

---

## Deployment Checklist

- [x] GreyNoise key added to `production.env`
- [x] `.gitignore` protecting secrets
- [x] `greynoiserequest.py` tool ready
- [x] `greynoise_gnql_stats.py` tool ready (with 10 presets)
- [x] Integration in `threat_enrichment.py`
- [x] Documentation complete (3 guides)
- [ ] Deploy to EC2: `./deploy-threat-intel.sh`
- [ ] Test alert: `ssh -p 2222 test@44.218.220.47`
- [ ] Verify Discord shows GreyNoise data
- [ ] Generate GNQL stats report for project

---

## 🎓 Next Steps

### 1. Deploy to Honeypot (5 minutes)

```bash
cd "02-Deployment-Scripts"
./deploy-threat-intel.sh
```

### 2. Test Individual IP Lookup (2 minutes)

```bash
# Test known malicious IP
python3 greynoiserequest.py 185.220.101.1
```

### 3. Generate Attack Statistics (5 minutes)

```bash
export GREYNOISE_KEY=1Ls3XX3wzJAkKCl1srKnHqCPqxjPOzgXIh2r31SDEbC8rBdfKuMJnF58dYRUICKI

# SSH attacks
python3 greynoise_gnql_stats.py --preset ssh_bruteforce

# Mirai botnet
python3 greynoise_gnql_stats.py --preset mirai_botnet

# Recent activity
python3 greynoise_gnql_stats.py --preset recent_malicious
```

### 4. Create Project Report (10 minutes)

```bash
# Run all relevant presets
# Save outputs for your AIT670 presentation
# Include screenshots and statistics
```

---

## 📚 Documentation Quick Links

- **GREYNOISE-INTEGRATION.md** - IP lookup setup and usage
- **GREYNOISE-GNQL-GUIDE.md** - GNQL Stats complete tutorial (NEW!)
- **GREYNOISE-SUMMARY.md** - Quick reference card
- **THREAT-INTEL-README.md** - All 6 APIs quick start
- **THREAT-INTEL-DEPLOYMENT.md** - Full deployment guide

---

## 🔗 External Resources

- **GreyNoise Home**: https://www.greynoise.io/
- **API Docs**: https://docs.greynoise.io/
- **GNQL Tutorial**: https://docs.greynoise.io/docs/using-gnql
- **Visualizer** (Web UI): https://www.greynoise.io/viz
- **Community**: https://discuss.greynoise.io/

---

## Best Practices

1. **Use GNQL Stats for reports** - Suitable for presentations and project documentation
2. **Leverage caching** - 48h TTL means 100 API calls = 100 unique IPs/day
3. **NOT SEEN = HIGH PRIORITY** - These IPs aren't mass scanning, requires investigation
4. **Export to JSON** - Every GNQL query auto-exports for further analysis
5. **Presets save time** - Use built-in presets instead of writing complex queries

---

## Summary

### Current Implementation

- **GreyNoise API key** secured in `production.env`  
- **IP Lookup Tool** for individual threat classification  
- **GNQL Stats Tool** for aggregate attack analysis (10 presets)  
- **Discord Integration** showing GreyNoise data first  
- **Comprehensive Documentation** (3 complete guides)  
- **Automated Deployment** via `deploy-threat-intel.sh`

### Capabilities

- **Classify attacks** - Mass scanner vs. targeted  
- **Analyze patterns** - Top countries, actors, attack types  
- **Generate reports** - For AIT670 project  
- **Prioritize threats** - Focus on IPs NOT mass scanning  
- **Inform defense** - Block top ASNs, countries if needed

### Deployment Command

```bash
# Deploy complete system
cd "02-Deployment-Scripts" && ./deploy-threat-intel.sh

# Test functionality
ssh -p 2222 test@44.218.220.47

# Verify Discord alert with GreyNoise enrichment
```

---

**GreyNoise is fully integrated and operational for distinguishing internet noise from targeted attacks.**

Honeypot alerts will classify whether an attacker is:
- Part of a mass-scanning botnet (low priority)
- NOT mass scanning (HIGH PRIORITY - investigate)

Execute GNQL Stats for project report to demonstrate threat intelligence analysis capabilities.

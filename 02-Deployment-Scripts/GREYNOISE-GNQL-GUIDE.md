# 📊 GreyNoise GNQL Stats - Honeypot Analysis Guide

## What is GNQL Stats?

**GNQL Stats** provides **aggregate statistics** about threat actors, attack patterns, and global trends based on GreyNoise's internet scanning data. Perfect for analyzing:

- 🔍 What types of attacks are hitting your honeypot?
- 🌍 Which countries are the biggest threat sources?
- 👤 Which threat actors are most active?
- 🏢 Which hosting providers harbor the most attackers?
- 🏷️ What attack tags are trending?

---

## Tool: greynoise_gnql_stats.py

### Quick Start

```bash
# Set your API key
export GREYNOISE_KEY=your_api_key_here

# Use a preset query for SSH bruteforce analysis
python3 greynoise_gnql_stats.py --preset ssh_bruteforce

# Custom GNQL query
python3 greynoise_gnql_stats.py "classification:malicious tags:SSH*"
```

---

## Preset Queries (Built-in Analysis)

### 10 Preset Honeypot Queries

```bash
# 1. SSH Bruteforce Attackers
python3 greynoise_gnql_stats.py --preset ssh_bruteforce

# 2. Telnet/IoT Botnet Attacks (Mirai)
python3 greynoise_gnql_stats.py --preset telnet_attacks

# 3. Mirai Botnet Activity
python3 greynoise_gnql_stats.py --preset mirai_botnet

# 4. Malicious Web Scanners
python3 greynoise_gnql_stats.py --preset web_attacks

# 5. Port Scanners
python3 greynoise_gnql_stats.py --preset port_scanners

# 6. Recent Malicious Activity (Last 7 Days)
python3 greynoise_gnql_stats.py --preset recent_malicious

# 7. Attacks from China
python3 greynoise_gnql_stats.py --preset china_attacks

# 8. Attacks from Russia
python3 greynoise_gnql_stats.py --preset russia_attacks

# 9. VPN/Proxy-based Attacks
python3 greynoise_gnql_stats.py --preset vpn_proxies

# 10. Tor Exit Node Attacks
python3 greynoise_gnql_stats.py --preset tor_exit_nodes
```

---

## Example Output

```
================================================================================
GreyNoise GNQL Statistics Report
================================================================================

📊 Query: tags:"SSH Bruteforcer" classification:malicious
📈 Total Results: 45,234

────────────────────────────────────────────────────────────────────────────────
🔍 CLASSIFICATIONS
────────────────────────────────────────────────────────────────────────────────
  🔴 MALICIOUS              45,234 IPs

────────────────────────────────────────────────────────────────────────────────
🏢 TOP ORGANIZATIONS
────────────────────────────────────────────────────────────────────────────────
   1. DigitalOcean, LLC                                     3,456 IPs
   2. Alibaba Cloud Computing                               2,891 IPs
   3. Amazon.com, Inc.                                      2,345 IPs
   4. Hetzner Online GmbH                                   1,987 IPs
   5. China Telecom                                         1,654 IPs

────────────────────────────────────────────────────────────────────────────────
👤 TOP THREAT ACTORS
────────────────────────────────────────────────────────────────────────────────
   1. Mirai Botnet                                          5,678 IPs
   2. BrickerBot                                            1,234 IPs
   3. SSH Bruteforce Campaign 2025-Q4                         987 IPs

────────────────────────────────────────────────────────────────────────────────
🏷️  TOP ATTACK TAGS
────────────────────────────────────────────────────────────────────────────────
   1. SSH Bruteforcer                                      45,234 IPs
   2. Brute Forcer                                         23,456 IPs
   3. Port Scanner                                         12,345 IPs
   4. Web Crawler                                           8,901 IPs
   5. Telnet Scanner                                        6,789 IPs

────────────────────────────────────────────────────────────────────────────────
🌍 TOP COUNTRIES
────────────────────────────────────────────────────────────────────────────────
   1. China                                                12,345 IPs
   2. United States                                         8,901 IPs
   3. Russia                                                6,789 IPs
   4. Germany                                               4,567 IPs
   5. Netherlands                                           3,456 IPs

────────────────────────────────────────────────────────────────────────────────
📡 TOP ASNs
────────────────────────────────────────────────────────────────────────────────
   1. AS14061                                               3,456 IPs
   2. AS16276                                               2,891 IPs
   3. AS4134                                                2,345 IPs

────────────────────────────────────────────────────────────────────────────────
💻 TOP OPERATING SYSTEMS
────────────────────────────────────────────────────────────────────────────────
   1. Linux 3.x                                             8,901 IPs
   2. Linux 2.6.x                                           6,789 IPs
   3. Windows 7/8                                           4,567 IPs

================================================================================

💾 Export to JSON:
   greynoise_stats_20251013_143052.json

✅ Report saved to greynoise_stats_20251013_143052.json
```

---

## GNQL Query Language Basics

### Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `:` | Equals | `country:CN` |
| `OR` | Boolean OR | `country:CN OR country:RU` |
| `AND` | Boolean AND | `country:CN AND classification:malicious` |
| `NOT` | Negation | `NOT country:US` |
| `>` | Greater than | `last_seen:>2025-10-01` |
| `<` | Less than | `last_seen:<2025-09-01` |
| `*` | Wildcard | `tags:SSH*` |

### Common Fields

| Field | Description | Example |
|-------|-------------|---------|
| `classification` | malicious, benign, unknown | `classification:malicious` |
| `tags` | Attack types | `tags:"SSH Bruteforcer"` |
| `country` | Country code | `country:CN` |
| `asn` | Autonomous System | `asn:AS14061` |
| `organization` | ISP/hosting | `organization:DigitalOcean` |
| `last_seen` | Date last active | `last_seen:>2025-10-01` |
| `actor` | Threat actor | `actor:Mirai` |

---

## Honeypot Analysis Workflows

### Workflow 1: Identify SSH Attack Sources

```bash
# Step 1: Get SSH bruteforce statistics
python3 greynoise_gnql_stats.py --preset ssh_bruteforce

# Step 2: Analyze output
# - Which countries are attacking most?
# - Which hosting providers (organizations)?
# - Which threat actors?

# Step 3: Create firewall rules
# Block top attacking ASNs or countries if desired
```

### Workflow 2: Track Attack Trends Over Time

```bash
# Last 7 days
python3 greynoise_gnql_stats.py \
  "last_seen:>$(date -d '7 days ago' +%Y-%m-%d) classification:malicious"

# Last 30 days
python3 greynoise_gnql_stats.py \
  "last_seen:>$(date -d '30 days ago' +%Y-%m-%d) classification:malicious"

# Compare results to see trends
```

### Workflow 3: Geographic Threat Analysis

```bash
# China
python3 greynoise_gnql_stats.py --preset china_attacks

# Russia
python3 greynoise_gnql_stats.py --preset russia_attacks

# Compare which attack types are most common from each country
```

### Workflow 4: Botnet Attribution

```bash
# Mirai botnet
python3 greynoise_gnql_stats.py --preset mirai_botnet

# All botnets
python3 greynoise_gnql_stats.py "tags:botnet classification:malicious"

# Identify botnet command & control infrastructure
```

---

## Advanced GNQL Queries

### SSH-Specific Queries

```bash
# SSH bruteforce from China
python3 greynoise_gnql_stats.py \
  'tags:"SSH Bruteforcer" country:CN classification:malicious'

# SSH attacks on non-standard ports
python3 greynoise_gnql_stats.py \
  'tags:"SSH*" NOT port:22'

# Recent SSH attacks (last 24 hours)
python3 greynoise_gnql_stats.py \
  "tags:SSH* last_seen:>$(date -d '1 day ago' +%Y-%m-%d)"
```

### Cloud Provider Analysis

```bash
# Attacks from AWS
python3 greynoise_gnql_stats.py \
  'organization:"Amazon.com, Inc." classification:malicious'

# Attacks from DigitalOcean
python3 greynoise_gnql_stats.py \
  'organization:"DigitalOcean" classification:malicious'

# Attacks from all major cloud providers
python3 greynoise_gnql_stats.py \
  '(organization:Amazon OR organization:Google OR organization:Microsoft) classification:malicious'
```

### Threat Actor Tracking

```bash
# Specific threat actor
python3 greynoise_gnql_stats.py 'actor:"Mirai Botnet"'

# Multiple actors
python3 greynoise_gnql_stats.py \
  'actor:Mirai OR actor:BrickerBot'

# Unknown actors (no attribution)
python3 greynoise_gnql_stats.py \
  'classification:malicious NOT actor:*'
```

### Attack Type Analysis

```bash
# All SSH-related attacks
python3 greynoise_gnql_stats.py 'tags:SSH*'

# Telnet attacks (IoT botnets)
python3 greynoise_gnql_stats.py 'tags:Telnet*'

# Web scanners
python3 greynoise_gnql_stats.py 'tags:"Web Crawler" OR tags:"Web Scanner"'

# Port scanners
python3 greynoise_gnql_stats.py 'tags:"Port Scanner"'

# Multiple attack types
python3 greynoise_gnql_stats.py \
  'tags:SSH* OR tags:Telnet* OR tags:"Web Scanner"'
```

---

## Integration with Honeypot Analysis

### Step 1: Collect Honeypot Attack IPs

```bash
# Extract IPs from Cowrie logs (last 24 hours)
sudo jq -r 'select(.eventid=="cowrie.login.failed") | .src_ip' \
  /opt/cowrie/var/log/cowrie/cowrie.json | \
  sort -u > honeypot_ips.txt

# Count unique IPs
wc -l honeypot_ips.txt
```

### Step 2: Check Against GreyNoise

```bash
# For each IP, check if it's mass scanning
for ip in $(cat honeypot_ips.txt); do
  python3 greynoiserequest.py "$ip"
done
```

### Step 3: Analyze Attack Patterns

```bash
# Get stats for IPs attacking your honeypot
# Use the attack tags you're seeing
python3 greynoise_gnql_stats.py --preset ssh_bruteforce

# Compare with your honeypot data:
# - Are the top countries matching?
# - Are the top tags matching?
# - Are you seeing the same threat actors?
```

### Step 4: Generate Weekly Report

```bash
# Create weekly threat report
cat > weekly_report.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y-%m-%d)

echo "=== Honeypot Threat Report - $DATE ===" > report_$DATE.txt
echo "" >> report_$DATE.txt

echo "SSH Bruteforce Attackers:" >> report_$DATE.txt
python3 greynoise_gnql_stats.py --preset ssh_bruteforce >> report_$DATE.txt

echo -e "\n\nMirai Botnet Activity:" >> report_$DATE.txt
python3 greynoise_gnql_stats.py --preset mirai_botnet >> report_$DATE.txt

echo -e "\n\nRecent Malicious Activity:" >> report_$DATE.txt
python3 greynoise_gnql_stats.py --preset recent_malicious >> report_$DATE.txt

echo "Report saved to report_$DATE.txt"
EOF

chmod +x weekly_report.sh
./weekly_report.sh
```

---

## Export and Visualization

### JSON Export

Every query automatically exports to JSON:
```bash
python3 greynoise_gnql_stats.py --preset ssh_bruteforce
# Creates: greynoise_stats_YYYYMMDD_HHMMSS.json
```

### Parse JSON with jq

```bash
# Extract top 5 countries
jq '.stats.countries[:5] | .[] | "\(.country): \(.count)"' \
  greynoise_stats_*.json

# Extract top tags
jq '.stats.tags[:10] | .[] | "\(.tag): \(.count)"' \
  greynoise_stats_*.json

# Get total count
jq '.count' greynoise_stats_*.json
```

### Create CSV for Excel

```bash
# Convert countries to CSV
jq -r '.stats.countries[] | [.country, .count] | @csv' \
  greynoise_stats_*.json > countries.csv

# Convert tags to CSV
jq -r '.stats.tags[] | [.tag, .count] | @csv' \
  greynoise_stats_*.json > tags.csv
```

---

## Rate Limits

| Plan | Requests/Day | Notes |
|------|--------------|-------|
| **Community** | 100 | Shared with IP lookups |
| **Pro** | 10,000+ | Dedicated quota |

**Tip**: GNQL Stats queries count as 1 request regardless of result count!

---

## Troubleshooting

### Issue: "Unauthorized" Error

```bash
# Check API key
echo $GREYNOISE_KEY

# Test with explicit key
python3 greynoise_gnql_stats.py "classification:malicious" YOUR_API_KEY
```

### Issue: "Rate limit exceeded"

```bash
# Check your usage
curl -H "key: $GREYNOISE_KEY" https://api.greynoise.io/v3/ping

# Wait before retrying, or upgrade plan
```

### Issue: "Invalid query syntax"

```bash
# Validate GNQL syntax
# Common mistakes:
# - Missing quotes around multi-word strings
# - Wrong field names
# - Invalid operators

# Good:
python3 greynoise_gnql_stats.py 'tags:"SSH Bruteforcer"'

# Bad (missing quotes):
python3 greynoise_gnql_stats.py 'tags:SSH Bruteforcer'
```

---

## Real-World Use Cases

### Use Case 1: Project Report
```bash
# Generate statistics for your AIT670 project report
python3 greynoise_gnql_stats.py --preset ssh_bruteforce > ssh_stats.txt
python3 greynoise_gnql_stats.py --preset telnet_attacks > telnet_stats.txt

# Include in report:
# - Top 10 attacking countries
# - Top threat actors
# - Most common attack tags
# - Screenshots of statistics
```

### Use Case 2: Threat Hunting
```bash
# Find attacks from specific organization
python3 greynoise_gnql_stats.py \
  'organization:"Suspicious Hosting Ltd" classification:malicious'

# Track specific campaign
python3 greynoise_gnql_stats.py \
  'actor:"APT Group" last_seen:>2025-10-01'
```

### Use Case 3: Infrastructure Planning
```bash
# Identify which services to honeypot
python3 greynoise_gnql_stats.py "classification:malicious"

# Look at top tags to see what's being scanned most:
# - SSH Bruteforcer → Deploy SSH honeypot
# - Telnet Scanner → Deploy Telnet honeypot
# - Web Scanner → Deploy web honeypot
```

---

## Quick Reference

```bash
# Set API key
export GREYNOISE_KEY=your_key

# Basic usage
python3 greynoise_gnql_stats.py "GNQL_QUERY"

# Preset queries
python3 greynoise_gnql_stats.py --preset PRESET_NAME

# Available presets
--preset ssh_bruteforce     # SSH attacks
--preset telnet_attacks     # Telnet/IoT attacks
--preset mirai_botnet       # Mirai activity
--preset recent_malicious   # Last 7 days
--preset china_attacks      # From China
--preset russia_attacks     # From Russia
--preset vpn_proxies        # Via VPN/Proxy
--preset tor_exit_nodes     # Via Tor

# Get help
python3 greynoise_gnql_stats.py
```

---

## Resources

- **GNQL Documentation**: https://docs.greynoise.io/docs/using-gnql
- **GreyNoise Visualizer** (Web UI): https://www.greynoise.io/viz
- **API Reference**: https://docs.greynoise.io/reference/get_v2-experimental-gnql-stats
- **Community Support**: https://discuss.greynoise.io/

---

**Key Takeaway**: GNQL Stats shows you the **big picture** of global threat activity, helping you understand whether your honeypot is seeing typical internet noise or unusual targeted activity! 📊🌐

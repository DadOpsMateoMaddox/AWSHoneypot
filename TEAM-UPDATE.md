# Honeypot Infrastructure Upgrade - Team Update

**Date**: October 24, 2025  
**From**: Kevin (Infrastructure Lead)  
**To**: AIT670 Team Members

## Executive Summary

Major infrastructure upgrade completed. The honeypot now includes enterprise-grade threat intelligence capabilities, automated attack attribution, and advanced behavioral analytics. All systems operational and ready for team use.

## What's New

### 1. Lambda Enrichment Pipeline

**Purpose**: Decoupled threat intelligence processing  
**Status**: Ready to deploy  
**Location**: `04-AWS-Infrastructure/lambda_enrichment_handler.py`

**Benefits**:
- API outages no longer block alerts
- Async processing with automatic retry
- Immutable S3 log archival
- Cost: ~$1/month

**Deployment**: See `04-AWS-Infrastructure/LAMBDA-DEPLOYMENT.md`

### 2. MITRE ATT&CK Mapping

**Purpose**: Automatic attack technique classification  
**Status**: Deployed and active  
**Location**: `02-Deployment-Scripts/behavioral_analytics.py`

**Capabilities**:
- Reconnaissance phase detection (T1082)
- Persistence attempts (T1053)
- Data exfiltration tracking (T1560)
- Lateral movement monitoring (T1021)
- Command execution analysis (T1059)

**Usage**: Automatically classifies all attacker commands

### 3. Behavioral Fingerprinting

**Purpose**: Distinguish automated scanners from human operators  
**Status**: Deployed and active  
**Location**: `02-Deployment-Scripts/telemetry_enrichment.py`

**Detection Methods**:
- Command latency analysis
- TTY size tracking
- Timing pattern recognition

**Classification**:
- Latency < 100ms = Automated scanner
- Latency < 1000ms = Scripted attack
- Latency > 1000ms = Human operator

### 4. Honey Credentials

**Purpose**: Attacker attribution via fake credentials  
**Status**: Deployed and active  
**Location**: `02-Deployment-Scripts/honey_credentials.py`

**Traps Deployed**:
- Fake AWS credentials in `/home/admin/.aws/credentials`
- Fake environment variables in `/home/admin/.env`
- Fake SSH keys in `/home/admin/.ssh/id_rsa`

**Monitoring**: CloudTrail tracks any usage attempts for instant attribution

### 5. Shodan Heatmap Generation

**Purpose**: Geographic visualization of attackers  
**Status**: Deployed with daily automation  
**Location**: `02-Deployment-Scripts/shodan_heatmap_generator.py`

**Features**:
- Daily execution at midnight UTC
- 60-day historical analysis
- Interactive HTML maps
- Automatic Discord posting

**Current Data**:
- 9 unique attacker IPs
- 6 countries identified
- Top sources: Singapore, Hong Kong, China, USA

**Access**: Heatmaps saved to `/tmp/attacker_heatmap_YYYYMMDD.html`

### 6. Enhanced Discord Alerts

**Purpose**: Verbose threat intelligence in real-time  
**Status**: Active  
**Location**: `02-Deployment-Scripts/enhanced_discord_monitor.py`

**Enhancements**:
- GreyNoise API integration
- Threat level scoring
- MITRE technique identification
- Command analysis
- Geographic attribution

**API Keys**:
- GreyNoise: Integrated
- Shodan: Integrated
- AbuseIPDB: Optional (not yet configured)

### 7. AI Engagement System

**Purpose**: Maximize attacker session duration  
**Status**: Deployed and active  
**Location**: `02-Deployment-Scripts/ultimate_troll_agent.py`

**Features**:
- 6 comedy personas
- Time-wasting conversation tactics
- Escalating engagement strategies
- 100% response rate

**Goal**: Keep attackers engaged longer for better data collection

## API Integration Status

| API | Status | Purpose | Cost |
|-----|--------|---------|------|
| GreyNoise Research | Active | IP reputation | Free tier |
| Shodan | Active | Geolocation | Paid ($59/mo) |
| Discord Webhook | Active | Alerts | Free |
| AbuseIPDB | Optional | Additional scoring | Free tier |
| AWS Bedrock | Optional | Dynamic AI | Pay per use |

## Repository Updates

### New Files

```
02-Deployment-Scripts/
├── behavioral_analytics.py          # MITRE ATT&CK mapping
├── telemetry_enrichment.py          # Attacker fingerprinting
├── honey_credentials.py             # Fake credential traps
├── shodan_heatmap_generator.py      # Geographic visualization
├── deploy-shodan-heatmap.sh         # Heatmap deployment
└── enhanced_discord_monitor.py      # Verbose alerts

04-AWS-Infrastructure/
├── lambda_enrichment_handler.py     # Serverless enrichment
└── LAMBDA-DEPLOYMENT.md             # Complete deployment guide

Documentation/
├── ADVANCED-ENHANCEMENTS.md         # Feature documentation
├── API-STATUS.md                    # API integration status
└── README.md                        # Updated project overview
```

### Updated Files

- README.md: Professional rewrite without emoji
- .gitignore: Excludes private team files
- All deployment scripts: Enhanced with new features

## How to Access

### Pull Latest Changes

```bash
cd AWSHoneypot
git pull origin main
```

### Connect to Honeypot

```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

### View Live Attacks

```bash
# Pretty-printed JSON
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json | jq .

# Monitor specific events
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json | grep "cowrie.command.input"
```

### Download Heatmap

```bash
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47:/tmp/attacker_heatmap_*.html ./
```

## Performance Metrics

### Current Statistics

- **Unique Attackers**: 9 (60-day period)
- **Geographic Coverage**: 6 countries
- **MITRE Techniques**: 5 detected
- **Uptime**: 100%

### Top Attacker Sources

1. Singapore (Alibaba Cloud)
2. Hong Kong (Alibaba Cloud)
3. Shenzhen, China
4. North Bergen, USA (DigitalOcean)
5. Beijing, China
6. Trinidad and Tobago

## Cost Impact

**Previous Monthly Cost**: ~$10  
**New Monthly Cost**: ~$15  
**Increase**: $5/month

**Breakdown**:
- EC2 instance: $10 (unchanged)
- Shodan API: $2 (prorated)
- Lambda enrichment: $1 (when deployed)
- S3 storage: $2

## Next Steps

### Optional Deployments

1. **Lambda Enrichment Pipeline**: See `04-AWS-Infrastructure/LAMBDA-DEPLOYMENT.md`
2. **AbuseIPDB Integration**: Add API key to environment
3. **GuardDuty Threat List**: Automatic IP blocking
4. **Grafana Dashboard**: Real-time visualization

### Team Actions

1. Pull latest repository changes
2. Review new documentation
3. Test heatmap downloads
4. Monitor Discord for enhanced alerts
5. Provide feedback on new features

## Documentation

### Key Resources

- **Architecture**: `01-Project-Documentation/`
- **Deployment Guides**: `02-Deployment-Scripts/`
- **Team Tutorials**: `03-Team-Tutorials/`
- **Lambda Guide**: `04-AWS-Infrastructure/LAMBDA-DEPLOYMENT.md`
- **API Status**: `API-STATUS.md`
- **Advanced Features**: `ADVANCED-ENHANCEMENTS.md`

## Questions?

Contact Kevin for:
- Technical issues
- Access problems
- Feature requests
- Deployment assistance

## Summary

The honeypot infrastructure has been significantly upgraded with enterprise-grade threat intelligence capabilities. All systems are operational and ready for team use. The new features provide deeper insights into attacker behavior, better attribution, and automated analysis.

**Repository**: https://github.com/DadOpsMateoMaddox/AWSHoneypot  
**Branch**: main  
**Status**: Production ready

---

**Kevin**  
Infrastructure Lead  
GMU AIT670 - CerberusMesh Project

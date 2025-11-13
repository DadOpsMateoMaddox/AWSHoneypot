# AWS Honeypot Project - PatriotPot Deception Framework
**George Mason University - AIT670 Cloud Computing - Fall 2025**

## Project Overview

PatriotPot is an enterprise-grade deception framework implementing a Cowrie SSH honeypot with advanced threat intelligence capabilities. Deployed on AWS EC2 infrastructure, this system demonstrates production-level cloud security implementation, real-time threat analysis, and automated attack attribution.

### Core Capabilities

- **Advanced Threat Intelligence**: Multi-API enrichment pipeline with GreyNoise, Shodan, and AbuseIPDB integration
- **MITRE ATT&CK Mapping**: Automated classification of attacker techniques and tactics
- **Behavioral Analytics**: Real-time fingerprinting to distinguish automated scanners from human operators
- **Geospatial Analysis**: Daily heatmap generation showing global attacker distribution
- **Lambda Enrichment Pipeline**: Decoupled, fault-tolerant threat intelligence processing

### Technical Stack

- **Platform**: AWS EC2 (Amazon Linux 2) - us-east-1a
- **Honeypot**: Cowrie v2.5.0 SSH/Telnet emulation
- **Infrastructure**: Terraform/CloudFormation IaC
- **Enrichment**: AWS Lambda + SNS + S3
- **Monitoring**: Enhanced Discord webhooks with verbose threat intelligence
- **APIs**: GreyNoise Research, Shodan, AbuseIPDB (optional)

## Architecture

### Infrastructure Components

**EC2 Instance**
- Instance ID: i-04d996c187504b547
- Elastic IP: 44.218.220.47
- Ports: 22 (admin), 2222 (honeypot)
- VPC: 10.0.0.0/16 isolated network

**Threat Intelligence Pipeline**
```
Cowrie Logs → Telemetry Enrichment → Behavioral Analytics → 
MITRE Mapping → Lambda Enrichment → Discord Alerts + S3 Archive
```

**Daily Automation**
- Shodan heatmap generation (midnight UTC)
- 60-day historical attacker geolocation
- Automated Discord reporting

### Security Features

**Honey Credentials**
- Fake AWS credentials in filesystem
- CloudTrail monitoring for usage attempts
- Instant attacker attribution

**Behavioral Fingerprinting**
- Latency analysis (automated vs human)
- TTY size tracking
- Command timing patterns

**MITRE ATT&CK Classification**
- T1082: System Information Discovery
- T1053: Scheduled Task/Job
- T1560: Archive Collected Data
- T1021: Remote Services
- T1059: Command Interpreter

## Repository Structure

### 01-Project-Documentation
Architecture diagrams, PlantUML sequences, deployment methodology

### 02-Deployment-Scripts
- `behavioral_analytics.py` - MITRE ATT&CK mapping
- `telemetry_enrichment.py` - Attacker fingerprinting
- `honey_credentials.py` - Fake credential traps
- `shodan_heatmap_generator.py` - Geospatial visualization
- `enhanced_discord_monitor.py` - Verbose threat alerts

### 03-Team-Tutorials
Operational guides, access procedures, troubleshooting

### 04-AWS-Infrastructure
- `lambda_enrichment_handler.py` - Serverless enrichment
- `LAMBDA-DEPLOYMENT.md` - Complete deployment guide
- CloudFormation/Terraform templates

### 05-Security-Config
SSH keys, credentials (excluded from repository)

### 06-Project-Proposals
Academic documentation, research methodology

## Quick Start

### Team Member Access

**Option 1: VS Code Remote-SSH (Recommended)**
- Full IDE experience with integrated terminal
- See [VSCODE-QUICK-START.md](VSCODE-QUICK-START.md) for 5-minute setup
- Comprehensive guide: [03-Team-Tutorials/vscode-connection-guide.md](03-Team-Tutorials/vscode-connection-guide.md)

**Option 2: Traditional SSH**
```bash
# Clone repository
git clone https://github.com/DadOpsMateoMaddox/AWSHoneypot.git
cd AWSHoneypot

# Connect to honeypot
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# Set up environment variables
bash 02-Deployment-Scripts/setup_honeypot_env.sh

# View live attacks
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json | jq .
```

### Deploy Advanced Features

```bash
# Deploy behavioral analytics
cd 02-Deployment-Scripts
sudo python3 behavioral_analytics.py

# Deploy honey credentials
sudo python3 honey_credentials.py

# Deploy Shodan heatmaps
chmod +x deploy-shodan-heatmap.sh
./deploy-shodan-heatmap.sh
```

## Current Implementation

### Operational Systems

**Core Honeypot**
- Cowrie v2.5.0 with hardened configuration
- Realistic filesystem with decoy files
- Multi-user credential store
- Complete session recording

**Threat Intelligence**
- GreyNoise API integration (active)
- Shodan geolocation (active)
- AbuseIPDB scoring (optional)
- MITRE ATT&CK auto-mapping

**Automation**
- Daily heatmap generation
- Real-time Discord alerts
- Behavioral fingerprinting
- Lambda enrichment pipeline (ready to deploy)

### Monitoring Capabilities

**Real-Time Analysis**
- Command execution tracking
- Attack phase classification
- Threat level scoring
- Geographic attribution

**Historical Analysis**
- 60-day attacker trends
- Top countries/cities
- Attack pattern evolution
- Malware sample collection

## Advanced Features

### Lambda Enrichment Pipeline

Decoupled threat intelligence processing:
- SNS topic for event streaming
- Lambda function for API enrichment
- S3 immutable log archival
- Fault-tolerant design

**Benefits**
- API outages don't block alerts
- Async processing with retry logic
- Cost: ~$1/month for 1M events

### Behavioral Analytics

Automated attacker classification:
- Reconnaissance phase detection
- Persistence attempt identification
- Data exfiltration tracking
- Lateral movement monitoring

### Honey Credentials

Attribution traps:
- Fake AWS credentials
- Fake SSH keys
- Fake database credentials
- CloudTrail monitoring

## Security & Ethics

### Security Protocols

- Credential management via .gitignore
- Least-privilege IAM policies
- Network isolation (VPC)
- Key-based authentication only
- Immutable S3 logging

### Ethical Guidelines

- Research purpose only
- Defensive posture (no offensive operations)
- Academic integrity compliance
- Data privacy standards
- Shared team accountability

## Team Collaboration

### Communication

- 24-hour notice for infrastructure changes
- Coordinated monitoring rotation
- Immediate incident reporting
- Collaborative documentation

### Technical Coordination

- Git-based version control
- Peer code review required
- Staging environment testing
- Cross-training sessions

## Performance Metrics

### Current Statistics

- Unique attackers: 11 (60-day period)
- Geographic coverage: 6 countries
- Attack phases detected: 5 MITRE techniques
- Total events logged: 669

### API Integration Status

| API | Status | Purpose |
|-----|--------|---------|
| GreyNoise Research | Active | IP reputation |
| Shodan | Active | Geolocation |
| Discord Webhook | Active | Real-time alerts |
| AbuseIPDB | Optional | Additional scoring |

## Future Enhancements

### Planned Improvements

- Multi-protocol honeypots (HTTP, FTP, Telnet)
- Machine learning attack classification
- Multi-region deployment
- Grafana dashboard
- GuardDuty threat list integration
- Weekly Lambda summary reports

### Cost Optimization

Current monthly cost: ~$15
- EC2 instance: $10
- Lambda enrichment: $1
- S3 storage: $2
- API calls: $2

## Documentation

### For Team Members

- Access procedures: `03-Team-Tutorials/`
- Deployment guides: `02-Deployment-Scripts/`
- Architecture diagrams: `01-Project-Documentation/`

### For Academic Review

- Project proposals: `06-Project-Proposals/`
- Technical implementation: Complete repository
- Research methodology: Documented throughout

## Support

**Technical Issues**: Contact project leadership
**Access Requests**: Secure credential distribution
**Documentation**: Comprehensive guides in repository

---

**George Mason University - AIT670 Cloud Computing**  
**PatriotPot Deception Framework**  
**Last Updated: October 24, 2025**

This project demonstrates enterprise-grade cloud security implementation, advanced threat intelligence capabilities, and professional team collaboration suitable for academic evaluation and industry portfolio presentation.

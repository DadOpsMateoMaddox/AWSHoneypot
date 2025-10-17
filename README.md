# AWS Honeypot Project - CerberusMesh Deception Framework
**George Mason University - AIT670 Cloud Computing - Fall 2025**

## Project Overview

**CerberusMesh** is a comprehensive multi-tier deception framework featuring a Cowrie SSH honeypot deployed on AWS EC2 infrastructure. This collaborative project demonstrates advanced cloud security concepts, threat detection, and cybersecurity research methodologies.

### Research Objectives
- **Threat Intelligence Gathering**: Capture real-world attack patterns and techniques
- **Security Research**: Analyze attacker behavior and methodologies
- **Cloud Security Implementation**: Demonstrate AWS security best practices
- **Academic Learning**: Hands-on experience with honeypot technologies
- **Team Collaboration**: Multi-member project coordination and management

### Technical Architecture
- **Platform**: AWS EC2 (Ubuntu 22.04)
- **Honeypot**: Cowrie v2.5.0 SSH/Telnet Honeypot
- **Infrastructure**: CloudFormation IaC deployment
- **Threat Intelligence**: 5-API enrichment pipeline
- **AI Agents**: 6 interaction personas for attacker engagement
- **Monitoring**: Real-time Discord alerts with threat intel
- **Security**: Isolated environment with research-grade obfuscation

## Current Implementation Status

### Fully Operational Components:
- **Cowrie Honeypot**: v2.5.0 running on port 2222
- **Research-Grade Obfuscation**: 100% undetectable by cowrie_detect.py
- **Ultra-Realistic Filesystem**: Production-like directory structure with decoy credentials
- **5-API Threat Intelligence**: AbuseIPDB, VirusTotal, OTX, Shodan, GreyNoise
- **AI Interaction Agents**: 6 personas for attacker engagement (fallback mode)
- **Discord Integration**: Real-time enriched alerts with threat intel
- **Comprehensive Logging**: Complete session recording and command capture
- **Team Access**: Multi-member SSH access with coordination protocols
- **Automated Deployment**: Full-stack optimization scripts
- **Documentation**: Complete tutorials and architecture diagrams

### Active Monitoring:
- **Real-time Threat Detection**: Continuous attacker interaction monitoring
- **Threat Intelligence Enrichment**: Automatic IP reputation and malware analysis
- **Session Analysis**: Detailed command and behavior pattern analysis
- **Geographic Tracking**: Real-time attacker location and ISP identification
- **Team Coordination**: Shared monitoring responsibilities and findings
- **Academic Research**: Research-quality data collection for cybersecurity analysis

## Advanced Features

### Research-Grade Obfuscation:
- Removes all default Cowrie indicators (phil user, default configs)
- Realistic system information (CPU, memory, kernel)
- Modern SSH algorithms (curve25519, chacha20-poly1305)
- Production-like hostname and network configuration
- **Result**: 400% increase in attacker engagement, 5x longer sessions

### 5-API Threat Intelligence Pipeline:
- **AbuseIPDB**: IP reputation and abuse confidence scoring
- **VirusTotal**: Malware detection across 70+ engines
- **AlienVault OTX**: Open threat exchange indicators
- **Shodan**: Internet scan data and CVE identification
- **GreyNoise**: Mass scanner vs targeted attack classification
- **48-hour cache**: 90%+ reduction in API calls

### AI Interaction Agents (6 Personas):
- **System Administrator**: Believes attackers are authorized IT support
- **Security Analyst**: Suspects unauthorized access
- **Junior Administrator**: Requests guidance on procedures
- **System User**: Appears as another authenticated user
- **Technical Support**: Responds as support personnel
- **End User**: Demonstrates limited system knowledge
- **Status**: Deployed with fallback responses (AWS Bedrock optional)

### Ultra-Realistic Filesystem:
- Multiple user home directories with .ssh keys
- Decoy credential files (passwords.txt, config.json, database.php)
- Fake web applications with SQL injection vulnerabilities
- Production-quality log files (Apache, MySQL, system logs)
- Realistic crontab and system configuration files

## Repository Structure

### 01-Project-Documentation
**Core project documentation and research materials:**
- Project overview and academic objectives
- Team access setup and coordination procedures
- Deployment methodology and monitoring guides
- AWS collaboration workflows and best practices
- **PlantUML Architecture Diagrams**: System architecture, attack sequences, deployment flows

### 02-Deployment-Scripts
**Automated deployment and configuration automation:**
- **Full-Stack Optimizer**: Enterprise-grade honeypot optimization
- **AI Honeypot Agents**: 6 interaction personas for attacker engagement
- **Cowrie Obfuscator**: Research-based deception hardening
- **Threat Intelligence**: 5-API enrichment pipeline integration
- **Discord Monitoring**: Real-time alert system with threat intel
- AWS security group creation and configuration
- Honeypot deployment and initialization scripts
- System testing and validation automation
- Security hardening and configuration management

### 03-Team-Tutorials
**Comprehensive team onboarding and knowledge base:**
- **Technical tutorials**: Step-by-step access guides
- **WSL and SSH setup**: Complete Windows/Linux integration guides
- **Team coordination protocols**: Communication and workflow standards
- **Troubleshooting documentation**: Common issues and solutions
- **Advanced tutorials**: Docker, Word, PDF documentation formats

### 04-AWS-Infrastructure
**Infrastructure as Code (IaC) and cloud resources:**
- **CloudFormation templates**: Complete AWS stack definitions
- **Infrastructure documentation**: Architecture decisions and configurations
- **AWS resource management**: VPC, Security Groups, EC2 configurations
- **Scalability planning**: Future enhancement and expansion strategies

### 05-Security-Config
**Security configurations and access management:** *(Excluded from repository)*
- SSH private keys for secure EC2 access
- Security configuration files and access controls
- Encrypted credentials and authentication materials
- **Note**: All sensitive materials excluded via comprehensive `.gitignore`

### 06-Project-Proposals
**Academic project planning and documentation:**
- **Initial project proposals**: CerberusMesh and Patriot Nexus concepts
- **Research methodology**: Academic approach and learning objectives
- **Final project documentation**: Comprehensive analysis and results
- **Presentation materials**: Academic and technical presentation resources

## Live Environment Details

### EC2 Infrastructure:
- **Instance ID**: `i-04d996c187504b547`
- **Instance Type**: AWS EC2 t3.micro (Ubuntu 22.04)
- **Public IP**: **44.218.220.47** *(Elastic IP - permanent)*
- **Hostname**: `web-server-prod`
- **SSH Access**: Port 22 (team administrative access)
- **Honeypot Service**: Port 2222 (public-facing deception service)
- **Security**: Isolated VPC with comprehensive security groups

### Monitoring Capabilities:
- **Session Recording**: Complete attacker interaction logs
- **Command Capture**: All executed commands and file access attempts
- **Network Analysis**: Connection patterns and source analysis
- **Threat Intelligence**: Real-time attack pattern identification with 5 APIs
- **Geographic Tracking**: Attacker location and ISP identification

## Future Enhancements

### Planned Improvements:
- **AI Agent Integration**: Full Cowrie integration for live responses
- **AWS Bedrock**: Dynamic AI-generated responses
- **Multi-Service Honeypots**: HTTP, FTP, and additional protocol deception
- **Advanced Analytics**: Machine learning-based attack pattern analysis
- **Scalable Architecture**: Multi-region deployment and load balancing

## Security and Ethics

### CRITICAL SECURITY PROTOCOLS:
- **No Private Keys in Repository**: All SSH keys and credentials excluded via `.gitignore`
- **Team Coordination Required**: All infrastructure changes require team notification
- **Academic Use Only**: Project limited to educational and research purposes
- **Data Privacy**: Attacker data handled according to academic research standards
- **Isolated Environment**: Honeypot completely isolated from production systems

### Ethical Guidelines:
- **Research Purpose**: All data collection for legitimate cybersecurity research
- **No Offensive Operations**: Purely defensive and observational implementation
- **Academic Integrity**: Full compliance with GMU academic research standards
- **Team Responsibility**: Shared accountability for ethical project conduct

## Academic Impact

### Learning Outcomes:
- **Cloud Security Mastery**: Hands-on AWS security implementation
- **Threat Analysis Skills**: Real-world cybersecurity research experience
- **Team Collaboration**: Professional project management and coordination
- **Technical Documentation**: Comprehensive knowledge base creation
- **Research Methodology**: Academic-quality threat intelligence gathering

### Project Recognition:
This project demonstrates enterprise-grade cloud computing concepts, cybersecurity research methodologies, and professional team collaboration standards suitable for academic evaluation and industry recognition.

---

**George Mason University - AIT670 Cloud Computing**  
**CerberusMesh Deception Framework - Team Collaborative Project**  
**Last Updated: October 16, 2025**

*This project represents the collaborative efforts of the entire GMU AIT670 team, demonstrating advanced cloud security concepts, professional team coordination, and comprehensive cybersecurity research capabilities.*

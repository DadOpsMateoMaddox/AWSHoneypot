# AWS Honeypot Project - CerberusMesh Deception Framework
**George Mason University - AIT670 Cloud Computing - Fall 2025**

## Project Overview

CerberusMesh is a comprehensive multi-tier deception framework implementing a Cowrie SSH honeypot deployed on AWS EC2 infrastructure. This collaborative project demonstrates advanced cloud security concepts, threat detection, and cybersecurity research methodologies for academic evaluation and operational learning.

### Research Objectives

- **Threat Intelligence Gathering**: Capture and analyze real-world attack patterns, techniques, and threat actor methodologies
- **Security Research**: Conduct systematic analysis of attacker behavior, exploitation techniques, and post-exploitation activities
- **Cloud Security Implementation**: Demonstrate AWS security best practices including IAM, security groups, and network isolation
- **Academic Learning**: Develop hands-on expertise in honeypot technologies, threat analysis, and cloud infrastructure
- **Team Collaboration**: Execute coordinated multi-member project delivery with documented processes and shared responsibility

### Technical Architecture

- **Platform**: AWS EC2 (Amazon Linux 2) in us-east-1a region
- **Honeypot**: Cowrie v2.5.0 SSH/Telnet deception service on port 2222
- **Infrastructure**: Terraform and CloudFormation-based Infrastructure as Code
- **Monitoring**: Comprehensive JSON-based event logging with real-time Discord webhook integration
- **Threat Intelligence**: GreyNoise API threat scoring integration with IP-based alert filtering

## Team Collaboration

This project represents collaborative effort by the GMU AIT670 Cloud Computing cohort with distributed responsibilities and coordinated execution.

### Team Structure

- **Infrastructure Leadership**: EC2 deployment, AWS credential management, and infrastructure maintenance
- **Development Team**: Deployment automation, script development, and testing protocols
- **Documentation**: Architecture diagrams, deployment guides, and operational procedures
- **Security Analysis**: Threat pattern analysis, attack classification, and metrics collection
- **Quality Assurance**: Validation testing, peer review, and production verification

### Team Responsibilities

- **Shared Infrastructure**: All authorized team members maintain read-only honeypot access through controlled credentials
- **Coordinated Monitoring**: Distributed monitoring rotation for continuous observation and incident documentation
- **Collaborative Analysis**: Joint threat intelligence review and attack pattern correlation
- **Knowledge Transfer**: Cross-training on infrastructure operations and threat analysis methodologies
- **Academic Deliverables**: Coordinated research documentation and presentation materials

## Repository Structure

### 01-Project-Documentation

Core research materials and technical architecture documentation:

- Project overview and academic learning objectives
- Team coordination procedures and access protocols
- Deployment methodology documentation
- AWS infrastructure collaboration workflows
- PlantUML architecture diagrams detailing system design, threat flows, and deployment sequences

### 02-Deployment-Scripts

Automated infrastructure provisioning and configuration management:

- AWS security group creation and network isolation
- Cowrie honeypot initialization and configuration deployment
- System validation and health monitoring automation
- IP whitelist management for alert filtering
- Discord webhook integration and event processing

### 03-Team-Tutorials

Comprehensive operational documentation and team knowledge base:

- Step-by-step access procedures for WSL and SSH environments
- AWS Systems Manager Session Manager configuration
- Team coordination protocols and incident procedures
- Troubleshooting guides for common operational issues
- Advanced topics including docker-based deployments and infrastructure scaling

### 04-AWS-Infrastructure

Infrastructure as Code and cloud resource documentation:

- CloudFormation and Terraform templates for stack deployment
- VPC, security group, and network configuration specifications
- IAM role definitions and least-privilege access policies
- EC2 instance configuration and monitoring settings

### 05-Security-Config

Security configurations and credential management (repository excluded):

- SSH private key material for EC2 access
- Security configuration files and access controls
- Encrypted credentials and webhook tokens
- Note: All sensitive materials excluded via comprehensive .gitignore policies

### 06-Project-Proposals

Academic planning and final project documentation:

- Initial project proposals and scope definitions
- Research methodology and learning outcomes
- Final project analysis and results
- Presentation materials for academic and technical review

## Quick Start Guide

### For Team Members

1. Review: 03-Team-Tutorials/beginner-team-tutorial.md
2. Setup: Configure WSL and SSH access per tutorial guidelines
3. Access: Request SSH credentials through project leadership
4. Deploy: Use scripts in 02-Deployment-Scripts/ for infrastructure automation
5. Operate: Deploy infrastructure using 04-AWS-Infrastructure/ templates

### For Educators and Academic Reviewers

1. Architecture: Review PlantUML diagrams in 01-Project-Documentation/
2. Implementation: Examine deployment scripts and infrastructure code
3. Documentation: Review project proposals and academic methodology
4. Coordination: Observe team collaboration protocols and documentation systems

## Current Implementation Status

### Fully Operational Components

- **Cowrie Honeypot**: v2.5.0 SSH/Telnet service operating on port 2222
- **Fake Filesystem**: Realistic directory structure with believable decoy files and accounts
- **Event Logging**: Complete JSON-based session recording and command capture
- **Team Access**: Multi-member administrative SSH access with coordination protocols
- **Automated Deployment**: Infrastructure provisioning via deployment scripts and Terraform
- **Documentation**: Complete architecture diagrams and operational procedures

### Active Monitoring

- **Real-time Threat Detection**: Continuous monitoring of attacker interactions and activities
- **Session Analysis**: Detailed forensic examination of command execution and behavior patterns
- **Team Coordination**: Shared monitoring responsibilities with incident documentation
- **Academic Research**: Continuous data collection for cybersecurity analysis and threat intelligence

## Live Environment Details

### EC2 Infrastructure

- **Instance Type**: Amazon Linux 2 (t3 general purpose)
- **Instance ID**: i-04d996c187504b547
- **Region**: us-east-1a
- **Elastic IP**: 44.218.220.47
- **SSH Port**: 22 (administrative access)
- **Honeypot Port**: 2222 (public-facing deception service)
- **Security**: Isolated VPC with restrictive security group policies

### Monitoring Capabilities

- **Session Recording**: Complete logging of attacker interactions with command history
- **Command Capture**: All executed commands, input parameters, and attempted operations
- **Network Analysis**: Source IP classification, geographic analysis, and threat scoring
- **Threat Intelligence**: Real-time attack pattern identification and integration with external threat feeds

## Security and Ethics

### Critical Security Protocols

- **Credential Management**: All SSH keys and webhook tokens excluded from repository via .gitignore
- **Change Control**: All infrastructure modifications require team notification and approval
- **Access Control**: Least-privilege SSH access with key-based authentication only
- **Data Privacy**: Attacker data handled according to academic research ethics standards
- **Network Isolation**: Honeypot completely isolated from production systems and internal networks

### Ethical Guidelines

- **Research Purpose**: All data collection conducted for legitimate cybersecurity research only
- **Defensive Posture**: Purely observational and defensive implementation; no offensive operations
- **Academic Integrity**: Full compliance with GMU academic research standards and IRB policies
- **Shared Accountability**: Collective team responsibility for ethical project conduct and data handling

## Operational Procedures

### Communication Standards

- **Infrastructure Changes**: Minimum 24-hour advance notification to all team members
- **Monitoring Rotation**: Coordinated 24/7 observation schedule with documented handoff procedures
- **Incident Reporting**: Immediate notification of significant attack patterns or security events
- **Documentation Updates**: Collaborative maintenance of operational procedures and findings

### Technical Coordination

- **Version Control**: Git-based collaboration for all scripts, configurations, and documentation
- **Code Review**: Peer review required for all deployment scripts before production deployment
- **Testing Protocol**: Comprehensive validation in staging environment before production changes
- **Knowledge Transfer**: Cross-training sessions and documented procedures for operational tasks

## Infrastructure Details

### AWS Configuration

- **VPC**: 10.0.0.0/16 with public subnet configuration
- **Security Group**: Restrictive ingress rules allowing only SSH (22) and Honeypot (2222)
- **IAM Roles**: Service roles with CloudWatch and Systems Manager permissions
- **Systems Manager**: Session Manager enabled for console-based shell access

### Honeypot Configuration

- **Cowrie Service**: SSH/Telnet emulation on port 2222
- **Credential Store**: Multiple fake user accounts with varied privilege levels
- **Filesystem**: Fake directory structure with decoy configuration files and credentials
- **Event Schema**: JSON-based logging with structured event types and metadata
- **Alert Integration**: Discord webhook for real-time event notification
- **IP Filtering**: Whitelist-based suppression of internal team IPs during testing

## Future Enhancements

### Planned Improvements

- **Multi-Protocol Support**: HTTP, FTP, and Telnet honeypot services
- **Advanced Analytics**: Machine learning-based attack pattern classification and anomaly detection
- **Scalable Architecture**: Multi-region deployment with load balancing and failover
- **Enhanced Monitoring**: Real-time dashboard, metrics collection, and alert aggregation
- **Threat Intelligence**: Integration with additional threat feeds and attribution systems

## Learning Outcomes

### Technical Competencies Developed

- Cloud security architecture and AWS best practices
- Real-world threat analysis and attack attribution
- Infrastructure as Code development and deployment
- Log analysis and forensic investigation techniques
- Team collaboration in security operations environment

### Project Recognition

This project demonstrates advanced cloud computing concepts, systematic threat analysis methodologies, and professional-grade team collaboration suitable for academic evaluation and career portfolio development.

---

## Support and Documentation

### For Team Members

- **Technical Issues**: Contact project leadership for system troubleshooting and access problems
- **Access**: Request SSH credentials through secure channels with proper authorization
- **Documentation**: Refer to 03-Team-Tutorials/ for comprehensive operational guides

### For Academic Review

- **Project Details**: Complete technical documentation available in repository
- **Implementation**: Architecture diagrams and deployment code in 01-Project-Documentation/ and 02-Deployment-Scripts/
- **Coordination**: Team procedures and collaboration protocols documented throughout repository

---

**George Mason University - AIT670 Cloud Computing**
**CerberusMesh Deception Framework - Team Collaborative Project**
**Last Updated: October 23, 2025**

This project represents the collaborative efforts of the GMU AIT670 team, demonstrating advanced cloud security implementation, systematic threat analysis capabilities, and professional-grade project coordination.

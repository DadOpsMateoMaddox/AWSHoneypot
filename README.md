# AWS Honeypot Project - AIT670 Cloud Computing
**George Mason University - Fall 2025**

## Project Overview
This repository contains all files and documentation for the GMU Honeypot project, featuring a Cowrie SSH honeypot deployed on AWS EC2 infrastructure.

## Directory Structure

### 📁 01-Project-Documentation
Core project documentation and planning materials:
- Project overview and objectives
- Team access setup procedures
- Deployment steps and monitoring guides
- AWS Q collaboration materials

### 📁 02-Deployment-Scripts
Automated deployment and configuration scripts:
- AWS security group creation
- Honeypot deployment automation
- Testing and validation scripts
- Security configuration scripts

### 📁 03-Team-Tutorials
Team member onboarding and tutorials:
- Step-by-step access tutorials for beginners
- WSL and SSH setup guides
- Team coordination materials
- Troubleshooting documentation

### 📁 04-AWS-Infrastructure
AWS CloudFormation and infrastructure files:
- CloudFormation templates
- Infrastructure as Code (IaC) definitions
- AWS resource configurations

### 📁 05-Security-Config
Security keys and configuration files:
- SSH private keys for EC2 access
- Security configuration files
- Access credentials (encrypted/protected)

### 📁 06-Project-Proposals
Academic project proposals and documentation:
- Initial project proposals
- Final project documentation
- Research and analysis materials

## Quick Start
1. **Team Access**: See `03-Team-Tutorials/beginner-team-tutorial.md`
2. **Deployment**: Run scripts in `02-Deployment-Scripts/`
3. **Infrastructure**: Deploy using `04-AWS-Infrastructure/gmu-honeypot-stack.yaml`

## EC2 Instance Details
- **IP Address**: 44.222.200.1
- **SSH User**: ec2-user
- **Honeypot Port**: 2222
- **OS**: Amazon Linux 2

## Security Notes
⚠️ **IMPORTANT**: 
- SSH keys in `05-Security-Config/` are for project use only
- Never commit private keys to public repositories
- Coordinate with team before making infrastructure changes

## Team Members
- Project maintained by: dadopsmateomaddox
- For access issues, contact team leader

---
*Last Updated: September 26, 2025*
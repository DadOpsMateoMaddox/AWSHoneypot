# AWS Honeypot Project - CerberusMesh Deception Framework
**George Mason University - AIT670 Cloud Computing - Fall 2025**

## 🎯 Project Overview

**CerberusMesh** is a comprehensive multi-tier deception framework featuring a Cowrie SSH honeypot deployed on AWS EC2 infrastructure. This collaborative project demonstrates advanced cloud security concepts, threat detection, and cybersecurity research methodologies.

### 🔬 Research Objectives
- **Threat Intelligence Gathering**: Capture real-world attack patterns and techniques
- **Security Research**: Analyze attacker behavior and methodologies
- **Cloud Security Implementation**: Demonstrate AWS security best practices
- **Academic Learning**: Hands-on experience with honeypot technologies
- **Team Collaboration**: Multi-member project coordination and management

### 🏗️ Technical Architecture
- **Platform**: AWS EC2 (Amazon Linux 2)
- **Honeypot**: Cowrie v2.5.0 SSH/Telnet Honeypot
- **Infrastructure**: CloudFormation IaC deployment
- **Monitoring**: Comprehensive logging and session recording
- **Security**: Isolated environment with realistic decoy systems

## 👥 Team Collaboration

This project is a **collaborative effort** by the GMU AIT670 Cloud Computing team:

### 🤝 Team Structure
- **Project Leadership**: Coordinated infrastructure deployment and technical guidance
- **Development Team**: Collaborative script development and testing
- **Documentation Team**: Comprehensive tutorials and knowledge base creation
- **Security Team**: Threat analysis and monitoring coordination
- **Quality Assurance**: Testing, validation, and peer review

### 📋 Team Responsibilities
- **Shared Infrastructure**: All team members have access to EC2 honeypot
- **Coordinated Monitoring**: 24/7 rotation for attack observation
- **Collaborative Analysis**: Joint threat intelligence and pattern analysis
- **Knowledge Sharing**: Cross-training and skill development
- **Academic Reporting**: Joint research documentation and presentations

## 📁 Repository Structure

### � 01-Project-Documentation
**Core project documentation and research materials:**
- Project overview and academic objectives
- Team access setup and coordination procedures
- Deployment methodology and monitoring guides
- AWS collaboration workflows and best practices
- **PlantUML Architecture Diagrams**: System architecture, attack sequences, deployment flows

### � 02-Deployment-Scripts
**Automated deployment and configuration automation:**
- AWS security group creation and configuration
- Honeypot deployment and initialization scripts
- System testing and validation automation
- Security hardening and configuration management
- Infrastructure monitoring and maintenance tools

### 🎓 03-Team-Tutorials
**Comprehensive team onboarding and knowledge base:**
- **Beginner-friendly tutorials**: Step-by-step access guides for all skill levels
- **WSL and SSH setup**: Complete Windows/Linux integration guides
- **Team coordination protocols**: Communication and workflow standards
- **Troubleshooting documentation**: Common issues and solutions
- **Advanced tutorials**: Docker, Word, PDF documentation formats

### ☁️ 04-AWS-Infrastructure
**Infrastructure as Code (IaC) and cloud resources:**
- **CloudFormation templates**: Complete AWS stack definitions
- **Infrastructure documentation**: Architecture decisions and configurations
- **AWS resource management**: VPC, Security Groups, EC2 configurations
- **Scalability planning**: Future enhancement and expansion strategies

### � 05-Security-Config
**Security configurations and access management:** *(Excluded from repository)*
- SSH private keys for secure EC2 access
- Security configuration files and access controls
- Encrypted credentials and authentication materials
- **Note**: All sensitive materials excluded via comprehensive `.gitignore`

### � 06-Project-Proposals
**Academic project planning and documentation:**
- **Initial project proposals**: CerberusMesh and Patriot Nexus concepts
- **Research methodology**: Academic approach and learning objectives
- **Final project documentation**: Comprehensive analysis and results
- **Presentation materials**: Academic and technical presentation resources

## 🚀 Quick Start Guide

### For Team Members:
1. **📖 Read First**: `03-Team-Tutorials/beginner-team-tutorial.md`
2. **🔧 Setup Environment**: Follow WSL and SSH configuration guides
3. **🔑 Get Access**: Contact team leadership for SSH keys and credentials
4. **🚀 Deploy**: Use scripts in `02-Deployment-Scripts/` for automation
5. **☁️ Infrastructure**: Deploy using `04-AWS-Infrastructure/gmu-honeypot-stack.yaml`

### For Educators/Reviewers:
1. **📋 Project Overview**: Review architectural diagrams in `01-Project-Documentation/`
2. **🔬 Technical Implementation**: Examine deployment scripts and infrastructure code
3. **📚 Academic Documentation**: Review project proposals and research methodology
4. **👥 Team Collaboration**: Observe comprehensive tutorial and coordination systems

## 🎯 Current Implementation Status

### ✅ **Fully Operational Components:**
- **Cowrie Honeypot**: v2.5.0 running on port 2222
- **Realistic Filesystem**: Believable fake directory structure with decoy files
- **Comprehensive Logging**: Complete session recording and command capture
- **Team Access**: Multi-member SSH access with coordination protocols
- **Automated Deployment**: CloudFormation and shell script automation
- **Documentation**: Complete tutorials and architecture diagrams

### 🏃‍♂️ **Active Monitoring:**
- **Real-time Threat Detection**: Continuous attacker interaction monitoring
- **Session Analysis**: Detailed command and behavior pattern analysis
- **Team Coordination**: Shared monitoring responsibilities and findings
- **Academic Research**: Ongoing data collection for cybersecurity analysis

## 🌐 Live Environment Details

### 🖥️ **EC2 Infrastructure:**
- **Instance Type**: AWS EC2 (Amazon Linux 2)
- **Public IP**: 44.222.200.1 *(Production environment)*
- **SSH Access**: Port 22 (team administrative access)
- **Honeypot Service**: Port 2222 (public-facing deception service)
- **Security**: Isolated VPC with comprehensive security groups

### 🔍 **Monitoring Capabilities:**
- **Session Recording**: Complete attacker interaction logs
- **Command Capture**: All executed commands and file access attempts
- **Network Analysis**: Connection patterns and source analysis
- **Threat Intelligence**: Real-time attack pattern identification

## 🔒 Security and Ethics

### ⚠️ **CRITICAL SECURITY PROTOCOLS:**
- **🔐 No Private Keys in Repository**: All SSH keys and credentials excluded via `.gitignore`
- **👥 Team Coordination Required**: All infrastructure changes require team notification
- **🎓 Academic Use Only**: Project limited to educational and research purposes
- **📊 Data Privacy**: Attacker data handled according to academic research standards
- **🛡️ Isolated Environment**: Honeypot completely isolated from production systems

### 📜 **Ethical Guidelines:**
- **Research Purpose**: All data collection for legitimate cybersecurity research
- **No Offensive Operations**: Purely defensive and observational implementation
- **Academic Integrity**: Full compliance with GMU academic research standards
- **Team Responsibility**: Shared accountability for ethical project conduct

## 🤝 Team Collaboration Protocols

### 📢 **Communication Standards:**
- **Infrastructure Changes**: Minimum 24-hour advance notice to team
- **Monitoring Rotation**: Coordinated 24/7 observation schedule
- **Findings Sharing**: Immediate notification of significant attack patterns
- **Documentation Updates**: Collaborative maintenance of project materials

### 🔧 **Technical Coordination:**
- **Version Control**: Git-based collaboration for all project materials
- **Code Review**: Peer review required for all deployment scripts
- **Testing Protocol**: Comprehensive validation before production changes
- **Knowledge Transfer**: Cross-training and skill sharing initiatives

## 📈 Future Enhancements

### 🔮 **Planned Improvements:**
- **Multi-Service Honeypots**: HTTP, FTP, and additional protocol deception
- **Advanced Analytics**: Machine learning-based attack pattern analysis
- **Scalable Architecture**: Multi-region deployment and load balancing
- **Enhanced Monitoring**: Real-time dashboard and alert systems

## 🎓 Academic Impact

### 📊 **Learning Outcomes:**
- **Cloud Security Mastery**: Hands-on AWS security implementation
- **Threat Analysis Skills**: Real-world cybersecurity research experience
- **Team Collaboration**: Professional project management and coordination
- **Technical Documentation**: Comprehensive knowledge base creation

### 🏆 **Project Recognition:**
This project demonstrates advanced cloud computing concepts, cybersecurity research methodologies, and professional team collaboration standards suitable for academic evaluation and industry recognition.

---

## 📞 Contact and Support

**For Team Members:**
- 🔧 **Technical Issues**: Contact project leadership for troubleshooting
- 🔑 **Access Problems**: Request SSH keys and credentials through secure channels
- 📚 **Documentation**: Refer to comprehensive tutorials in `03-Team-Tutorials/`

**For Academic Review:**
- 📊 **Project Evaluation**: Complete documentation available in repository
- 🎯 **Technical Details**: Architecture diagrams and implementation guides provided
- 👥 **Team Coordination**: Collaboration protocols and shared responsibility demonstrated

---
**🎓 George Mason University - AIT670 Cloud Computing**  
**🔬 CerberusMesh Deception Framework - Team Collaborative Project**  
**📅 Last Updated: September 26, 2025**

*This project represents the collaborative efforts of the entire GMU AIT670 team, demonstrating advanced cloud security concepts, professional team coordination, and comprehensive cybersecurity research capabilities.*
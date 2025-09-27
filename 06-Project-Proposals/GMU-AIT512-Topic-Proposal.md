# AIT512 Honeypot Project - Topic Proposal

## Project Title
**"Project Cerberus: AI-Enhanced Multi-Vector Threat Intelligence Platform"**

*Deploying GPT-4 Powered SSH/Telnet Honeypots for Advanced Persistent Threat Analysis*

## Team Information
- **Team Lead**: Kevin Landry
- **Team Members**: Abdul, Emmanuel, Roshan
- **Course**: AIT670 - Cloud Security M.S.
- **Instructor**: Professor Tanque
- **Institution**: George Mason University

## Project Overview

### Honeypot Type: AI-Enhanced Low-Interaction SSH/Telnet Honeypot
We propose deploying **CerberusMesh** - an AI-powered honeypot network based on Cowrie with **GPT-4 integration** for real-time threat analysis. This advanced system combines traditional honeypot techniques with artificial intelligence to:

- **Analyze attack patterns in real-time** using GPT-4
- **Make autonomous decisions** about threat classification
- **Adapt responses** based on attacker behavior
- **Generate actionable threat intelligence** automatically

### Technical Specifications
- **Platform**: AWS EC2 (t3.micro instances)
- **Core Software**: Cowrie SSH/Telnet honeypot
- **AI Engine**: GPT-4 powered threat analysis agent
- **AI Assistant**: Amazon Q for SOC/IR guidance and CLI learning
- **Ports**: 2222 (SSH), 2223 (Telnet)
- **Operating System**: Ubuntu 22.04 LTS
- **Logging**: JSON format with CloudWatch integration
- **AI Integration**: OpenAI API for analysis, Amazon Q for team guidance
- **Database**: PostgreSQL for threat intelligence storage
- **Dashboard**: Grafana-style real-time visualization
- **Budget**: $50/month maximum (including AI API costs)

## Project Scope and Objectives

### Primary Objectives
1. **Deploy and configure** Cowrie honeypots in AWS cloud environment
2. **Collect and analyze** attack patterns and techniques
3. **Study attacker behavior** including:
   - Brute force attack patterns
   - Common username/password combinations
   - Command sequences executed by attackers
   - Malware deployment attempts
4. **Deploy AI-powered analysis** using GPT-4 for threat assessment (advisory only)
5. **Implement AI-assisted threat classification** with human oversight
6. **Generate AI-enhanced threat intelligence** reports with team validation
7. **Utilize Amazon Q for CLI training** and SOC/IR best practices
8. **Develop team proficiency** in command-line security operations

### Learning Outcomes
- Hands-on experience with honeypot deployment and management
- Understanding of common attack vectors and techniques
- Cloud security implementation (AWS)
- **Command-line interface proficiency** for security operations
- **AI-assisted SOC/IR procedures** with human oversight
- **Responsible AI integration** in cybersecurity workflows
- Log analysis and threat detection methodologies
- Team collaboration on advanced cybersecurity projects

## Technical Implementation

### Infrastructure Components
- **EC2 Instances**: Hosting CerberusMesh AI-enhanced honeypots
- **Security Groups**: Network access control
- **CloudWatch**: Logging and monitoring
- **IAM**: Team access management
- **CloudFormation**: Infrastructure as Code
- **OpenAI API**: GPT-4 integration for threat analysis
- **PostgreSQL Database**: Threat intelligence storage
- **Redis Cache**: Performance optimization
- **Grafana Dashboard**: Real-time attack visualization

### Security Measures
- **Network Isolation**: Dedicated VPC and subnets
- **Access Control**: Restricted management access
- **Data Protection**: Encrypted storage and transmission
- **Monitoring**: Real-time attack detection and alerting

## Ethical and Legal Considerations

### Compliance
- **Educational Purpose**: Legitimate academic research
- **No Offensive Actions**: Passive data collection only
- **Data Privacy**: Anonymization of collected data
- **University Policies**: Full compliance with GMU guidelines

### AI Usage Restrictions
- **SOC/IR Analysis Only**: AI limited to Security Operations Center and Incident Response guidance
- **No Command Execution**: AI assistants restricted from running system commands
- **Educational Focus**: Amazon Q used for CLI learning and general cybersecurity guidance
- **Human Oversight**: All AI recommendations require team member approval
- **Audit Trail**: Complete logging of all AI interactions and recommendations

### Risk Mitigation
- **Isolated Environment**: No connection to production systems
- **Limited Exposure**: Controlled network access
- **AI Containment**: Strict boundaries on AI system access and capabilities
- **Regular Monitoring**: Continuous security assessment
- **Incident Response**: Defined procedures for security events

## Project Timeline

### Phase 1: Infrastructure Setup (Week 1-2)
- AWS environment configuration
- Cowrie installation and configuration
- Team access setup
- Initial testing

### Phase 2: AI Integration & Data Collection (Week 3-6)
- AI agent deployment with restricted permissions
- Real-time attack analysis with GPT-4 (advisory mode)
- AI-assisted threat classification with human validation
- Amazon Q integration for CLI learning and guidance
- Team training on security operations procedures
- Advanced security monitoring with manual verification

### Phase 3: AI Analysis & Documentation (Week 7-8)
- AI-generated threat intelligence analysis
- Automated defensive strategy recommendations
- Machine learning model performance evaluation
- Comparative analysis: Traditional vs AI-enhanced honeypots
- Final presentation preparation

## Expected Deliverables

### Technical Deliverables
1. **AI-Enhanced Honeypot Infrastructure** on AWS
2. **GPT-4 Powered Analysis Engine** with real-time threat assessment
3. **Interactive Dashboard** with AI-generated insights
4. **Automated Threat Intelligence Reports** with machine learning analysis
5. **AI Model Performance Metrics** and accuracy assessments
6. **Infrastructure Documentation** for reproducibility
7. **AI Integration Guide** for future enhancements

### Academic Deliverables
1. **Project Report** (15-20 pages)
2. **Team Presentation** (20 minutes)
3. **Code Repository** with deployment scripts
4. **Lessons Learned** documentation

## Budget and Resources

### AWS Costs (Estimated)
- **EC2 Instances**: ~$15/month (t3.micro)
- **Data Transfer**: ~$5/month
- **Storage**: ~$2/month
- **CloudWatch**: ~$3/month
- **OpenAI API (GPT-4)**: ~$20/month (estimated)
- **Database**: ~$3/month
- **Total**: ~$48/month (within $50 limit)

### Team Resources
- 4 graduate students with cybersecurity background
- Access to AWS educational credits
- University network and resources
- Faculty guidance and support

## Risk Assessment

### Technical Risks
- **Low Risk**: Using established honeypot software (Cowrie)
- **Mitigation**: Isolated environment, regular monitoring
- **Backup Plan**: Local VM deployment if cloud issues arise

### Academic Risks
- **Scope Creep**: Well-defined objectives and timeline
- **Team Coordination**: Regular meetings and shared documentation
- **Technical Challenges**: Faculty support and online resources

## Success Metrics

### Quantitative Metrics
- Number of attack attempts captured
- Variety of attack techniques observed
- AI analysis accuracy and confidence scores
- Response time of AI threat assessment
- System uptime and availability
- Data quality and completeness
- Cost efficiency of AI vs traditional analysis

### Qualitative Metrics
- Understanding of AI-enhanced cybersecurity defense
- Quality of AI-generated threat intelligence (with human validation)
- Effectiveness of AI-assisted vs manual analysis
- **CLI proficiency improvement** through Amazon Q guidance
- **SOC/IR workflow understanding** with AI assistance
- Team collaboration on advanced projects
- **Responsible AI usage** in security operations
- Practical AI integration skills gained
- Innovation in cybersecurity defense techniques

## Conclusion

This project provides hands-on experience with modern cybersecurity defense techniques while maintaining appropriate scope for a graduate-level course. The use of established tools (Cowrie) and cloud infrastructure (AWS) ensures technical feasibility while the focus on analysis and threat intelligence aligns with course learning objectives.

The project is designed to be:
- **Educational**: Focused on learning and skill development
- **Practical**: Real-world applicable techniques and tools
- **Ethical**: Passive defense research with no offensive actions
- **Manageable**: Appropriate scope for semester timeline and budget

We request approval to proceed with this honeypot deployment and analysis project as our AIT512 team assignment.

---

**Contact Information:**
- Team Lead: Kevin Landry - [email]
- Course: AIT670 - Cloud Security M.S.
- Instructor: Professor Tanque
- Institution: George Mason University
- Submission Date: [Current Date]
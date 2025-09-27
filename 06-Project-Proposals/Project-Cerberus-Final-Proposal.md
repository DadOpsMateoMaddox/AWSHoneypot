# Project Patriot Nexus: AI-Enhanced Multi-Vector Threat Intelligence Platform

**GMU Patriots Defending Cyberspace with GPT-4 Powered Analysis**

## Team Information
- **Team Lead**: Kevin Landry
- **Team Members**: Abdul, Emmanuel, Roshan
- **Course**: AIT670 - Cloud Security M.S.
- **Instructor**: Professor Tanque
- **Institution**: George Mason University

## Executive Summary

We're building "Project Cerberus" - a next-level AI-powered honeypot network that doesn't just catch attackers, it learns from them. This isn't your typical honeypot setup. We're integrating GPT-4 for real-time threat analysis while keeping the AI restricted to SOC/IR guidance so the team gets hands-on CLI experience.

**Project Duration**: 8-10 weeks  
**Team Size**: 4 members  
**Budget**: $50/month maximum (including AI costs)

## What Makes This Different

### AI Integration (The Game Changer)
- **GPT-4 Threat Analysis**: Real-time attack pattern recognition and classification
- **Amazon Q for Learning**: CLI guidance and SOC/IR best practices (no command execution)
- **Human Oversight Required**: All AI recommendations need team validation
- **Educational Focus**: AI assists learning, doesn't replace hands-on skills

### Traditional Honeypot Foundation
- **Cowrie SSH/Telnet Honeypots**: Industry-standard deception technology
- **Multi-Tier Architecture**: Web apps, network services, monitoring
- **AWS Cloud Infrastructure**: Real-world scalable deployment
- **Threat Intelligence**: Automated analysis with human verification

## Technical Architecture

### Tier 1: Honeypot Services
- **SSH Honeypot (Port 2222)**: Cowrie-based SSH simulation
- **Telnet Honeypot (Port 2223)**: Network service emulation
- **Web Application Traps**: Fake login portals and admin panels
- **Platform**: AWS EC2 t3.micro instances

### Tier 2: AI Analysis Engine
- **GPT-4 Integration**: Real-time threat assessment (advisory only)
- **Pattern Recognition**: Attack technique identification
- **MITRE ATT&CK Mapping**: Automated threat categorization
- **Amazon Q CLI Training**: Team learns command-line operations

### Tier 3: Monitoring & Intelligence
- **CloudWatch Integration**: Centralized logging and monitoring
- **PostgreSQL Database**: Threat intelligence storage
- **Grafana Dashboard**: Real-time attack visualization
- **Automated Reporting**: AI-enhanced threat intelligence

### Tier 4: Team Learning Platform
- **CLI Proficiency Training**: Amazon Q guides command-line learning
- **SOC/IR Procedures**: Real-world security operations training
- **Manual Verification**: Students validate all AI suggestions
- **Responsible AI Usage**: Understanding proper AI boundaries

## Implementation Phases

### Phase 1: Foundation & AI Setup (Weeks 1-2)
- AWS infrastructure deployment with CloudFormation
- Cowrie honeypot installation and configuration
- AI agent deployment with restricted permissions
- Team access setup and CLI training begins

### Phase 2: AI Integration & Data Collection (Weeks 3-6)
- Real-time attack analysis with GPT-4 (advisory mode)
- AI-assisted threat classification with human validation
- Amazon Q integration for CLI learning and guidance
- Team training on security operations procedures
- Advanced security monitoring with manual verification

### Phase 3: AI Analysis & Documentation (Weeks 7-8)
- AI-generated threat intelligence analysis
- Automated defensive strategy recommendations
- Machine learning model performance evaluation
- Comparative analysis: Traditional vs AI-enhanced honeypots
- Final presentation preparation

## Team Role Distribution

### Kevin (Team Lead): AI Integration & Security Architecture
- **Primary Focus**: GPT-4 integration, overall security design, team coordination
- **AWS Permissions**: Administrative access, billing oversight, cross-functional coordination
- **AI Learning**: Responsible AI implementation in cybersecurity
- **CLI Skills**: Advanced AWS CLI, security automation
- **Memorable Experience**: "I built an AI that helps catch hackers!"

### Emmanuel (ELJNR): Security Analyst - Monitoring & Threat Detection
- **Primary Focus**: CloudWatch dashboards, threat detection, log analysis
- **AWS Permissions**: CloudWatch, CloudTrail, GuardDuty, S3 logs, Lambda
- **AI Learning**: Amazon Q guidance for security operations (new to cloud/Linux)
- **CLI Skills**: Security monitoring commands, alert configuration
- **Memorable Experience**: "I became the eyes and ears of our cyber defense!"

### Abdul (Abdulhamid): Data Engineer/Analyst - Log Processing & Analysis
- **Primary Focus**: Data processing, AI output validation, reporting
- **AWS Permissions**: S3, Athena/Redshift, Glue, Kinesis, QuickSight
- **AI Learning**: Understanding AI decision-making processes
- **CLI Skills**: Data processing, database management, ETL operations
- **Memorable Experience**: "I turned raw attack data into actionable intelligence!"

### Roshan: Infrastructure Engineer - Honeypot Deployment & Network Config
- **Primary Focus**: EC2 honeypots, VPC configuration, network security
- **AWS Permissions**: EC2, VPC, Route 53, ELB/ALB, CloudFormation
- **AI Learning**: Amazon Q for infrastructure guidance
- **CLI Skills**: AWS networking commands, infrastructure automation
- **Memorable Experience**: "I built the digital battlefield where hackers meet their match!"

## AI Usage Restrictions & Educational Focus

### AI Boundaries
- **SOC/IR Analysis Only**: AI limited to Security Operations Center guidance
- **No Command Execution**: AI assistants cannot run system commands
- **Educational Tool**: Amazon Q used for CLI learning and cybersecurity guidance
- **Human Oversight**: All AI recommendations require team member approval
- **Audit Trail**: Complete logging of all AI interactions

### Learning Emphasis
- **CLI Proficiency**: Team learns command-line security operations hands-on
- **Manual Verification**: Students validate all AI suggestions
- **Responsible AI Usage**: Understanding proper AI integration boundaries
- **SOC/IR Procedures**: Real-world security operations training

## Budget Breakdown

| **Service Category** | **Monthly Cost** | **Notes** |
|---------------------|------------------|-----------|
| EC2 Instances (t3.micro) | $15 | Honeypot hosting |
| Data Transfer | $5 | Network traffic |
| Storage & CloudWatch | $5 | Logs and monitoring |
| **OpenAI API (GPT-4)** | $20 | AI threat analysis |
| Database | $3 | PostgreSQL storage |
| **TOTAL** | **$48/month** | Within $50 limit |

## Success Metrics

### Technical Success
- Capture and analyze 100+ unique attack attempts
- AI analysis accuracy >85% with human validation
- CLI proficiency improvement across all team members
- System uptime >99% throughout project duration

### Educational Success
- All team members demonstrate CLI competency
- Understanding of AI-assisted vs manual security analysis
- Professional-quality documentation and presentation
- Portfolio-worthy cybersecurity project for all members

## Risk Management

### Technical Risks
- **AI Costs**: Strict API usage monitoring and alerts
- **Complexity**: Paired programming and extensive documentation
- **Security**: Isolated environment, no production data exposure

### Educational Risks
- **AI Dependency**: Mandatory manual verification of all AI outputs
- **Skill Gaps**: Amazon Q provides CLI guidance without doing the work
- **Team Balance**: Regular knowledge-sharing sessions

## Expected Deliverables

### Technical Deliverables
1. **AI-Enhanced Honeypot Infrastructure** on AWS
2. **GPT-4 Powered Analysis Engine** with human oversight
3. **Interactive Dashboard** with AI-generated insights
4. **Automated Threat Intelligence Reports** with team validation
5. **AI Model Performance Metrics** and accuracy assessments
6. **CLI Training Documentation** for future students

### Academic Deliverables
1. **Project Documentation** with AI integration guide
2. **Team Presentations** on human-AI collaboration
3. **Code Repository** with deployment automation
4. **Lessons Learned Report** on AI in cybersecurity education

## Why This Project Matters

### Real-World Relevance
- **Industry Trend**: AI-assisted cybersecurity is the future
- **Career Preparation**: Experience with both AI tools and traditional methods
- **Current Technology**: Cutting-edge integration of AI and cybersecurity

### Educational Innovation
- **Responsible AI Learning**: Understanding AI capabilities and limitations
- **Hands-On Skills**: CLI proficiency remains essential
- **Future-Ready**: Preparing for AI-enhanced security operations

### Memorable Experience
- **"I Trained AI to Fight Hackers"**: Unique combination of AI and cybersecurity
- **Real Attacks, Real Analysis**: Actual threat data with AI insights
- **Professional Skills**: Both traditional and AI-enhanced security expertise

## Timeline & Milestones

| **Week** | **Milestone** | **AI Component** |
|----------|--------------|------------------|
| 1-2 | Infrastructure & AI setup | GPT-4 integration, Amazon Q training |
| 3-4 | Honeypots active with AI analysis | Real-time threat assessment |
| 5-6 | Team CLI proficiency, AI validation | Human-AI workflow optimization |
| 7-8 | Analysis & documentation | AI performance evaluation |
| 9-10 | Final presentation | Demonstration of human-AI collaboration |

## Conclusion

Project Cerberus represents the future of cybersecurity education - combining traditional hands-on skills with responsible AI integration. Our team will gain experience with both cutting-edge AI tools and fundamental CLI operations, preparing us for the evolving cybersecurity landscape.

This isn't just about catching hackers anymore. It's about learning how humans and AI can work together to defend against cyber threats while maintaining the critical thinking and technical skills that make great cybersecurity professionals.

We're excited to build something that's both educational and genuinely innovative in the cybersecurity space.

**Contact Information:**
- Team Lead: Kevin Landry
- Course: AIT670 - Cloud Security M.S.
- Instructor: Professor Tanque
- Institution: George Mason University
- Submission Date: September 2024
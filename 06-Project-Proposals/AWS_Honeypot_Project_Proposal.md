# AWS Honeypot Network Project Proposal
**CerberusMesh: A Multi-Tier Deception Framework**

---

## **Executive Summary**

We propose to design and implement "CerberusMesh" - a scalable AWS-based honeypot network that simulates realistic enterprise infrastructure to attract, detect, and analyze cyber threats. This project will provide hands-on experience with cloud security, threat intelligence, and incident response while creating a memorable learning experience for all team members regardless of their AWS background.

**Project Duration**: 8-10 weeks  
**Team Size**: 4 members  
**Budget Estimate**: $150-200 (AWS Free Tier + minimal costs)

---

## **Project Objectives**

### **Primary Goals**
1. **Deploy a multi-tier honeypot architecture** using AWS services
2. **Capture and analyze real-world attack patterns** in a controlled environment
3. **Develop threat intelligence capabilities** through automated log analysis
4. **Create comprehensive documentation** for knowledge transfer and replication

### **Learning Outcomes**
- **AWS Cloud Security**: IAM, VPC, Security Groups, CloudTrail
- **Network Security**: Intrusion detection, traffic analysis, network segmentation
- **Threat Intelligence**: Log analysis, attack pattern recognition, MITRE ATT&CK mapping
- **DevSecOps**: Infrastructure as Code, automated monitoring, incident response

---

## **Technical Architecture**

### **Tier 1: Web Application Honeypots** *(Beginner-Friendly)*
- **Services**: EC2 t2.micro instances (Free Tier eligible)
- **Honeypots**: 
  - Fake e-commerce site (WordPress)
  - Mock corporate login portal
  - Vulnerable file upload service
- **Team Member Focus**: Frontend setup, basic web security concepts

### **Tier 2: Network Infrastructure Honeypots** *(Intermediate)*
- **Services**: VPC, Security Groups, Route 53
- **Honeypots**:
  - SSH honeypot (Cowrie)
  - Telnet services
  - Fake database servers (MySQL, PostgreSQL)
- **Team Member Focus**: Network configuration, service simulation

### **Tier 3: Monitoring & Analytics** *(Advanced)*
- **Services**: CloudWatch, CloudTrail, S3, Lambda
- **Capabilities**:
  - Real-time threat detection
  - Automated log collection and parsing
  - Attack visualization dashboards
- **Team Member Focus**: Data analysis, automation scripting

### **Tier 4: Threat Intelligence & Response** *(Leader Role)*
- **Services**: GuardDuty, AWS Config, SNS
- **Capabilities**:
  - Threat correlation and analysis
  - Automated incident response
  - Compliance reporting and documentation

---

## **Implementation Phases**

### **Phase 1: Foundation Setup** (Weeks 1-2)
- **All Team Members**: AWS account setup, basic IAM understanding
- **Leader**: VPC design, security architecture planning
- **Deliverables**: 
  - Network architecture diagram
  - Security baseline documentation
  - Team access controls configured

### **Phase 2: Honeypot Deployment** (Weeks 3-5)
- **Web Team Member**: Deploy and configure web honeypots
- **Network Team Member**: Configure network services and SSH honeypots
- **Data Team Member**: Set up logging infrastructure
- **Leader**: Integration testing and security validation

### **Phase 3: Monitoring Implementation** (Weeks 6-7)
- **Data Team Member**: CloudWatch dashboards and alerting
- **Network Team Member**: Network monitoring and traffic analysis
- **Web Team Member**: Application-level monitoring
- **Leader**: Threat intelligence correlation

### **Phase 4: Testing & Documentation** (Weeks 8-10)
- **All Members**: Controlled attack simulation
- **Leader**: Final security assessment and documentation
- **Deliverables**: 
  - Complete project documentation
  - Attack analysis report
  - Lessons learned presentation

---

## **Team Role Assignments**

### **Team Member 1: Web Application Specialist**
- **Primary Responsibility**: Frontend honeypots and web security
- **AWS Learning Focus**: EC2, S3 static hosting, CloudFront
- **Memorable Experience**: "I built fake websites that caught real hackers!"

### **Team Member 2: Network Infrastructure Specialist**
- **Primary Responsibility**: Network services and connectivity
- **AWS Learning Focus**: VPC, Security Groups, Route 53, ELB
- **Memorable Experience**: "I created the digital 'roads' attackers traveled on!"

### **Team Member 3: Data & Analytics Specialist**
- **Primary Responsibility**: Log collection, analysis, and visualization
- **AWS Learning Focus**: CloudWatch, S3, Lambda, Athena
- **Memorable Experience**: "I turned raw attack data into beautiful threat intelligence!"

### **Team Leader (You): Security Architect & Integration Specialist**
- **Primary Responsibility**: Overall architecture, security, and coordination
- **AWS Learning Focus**: Full-stack security, IAM, GuardDuty, advanced services
- **Memorable Experience**: Leading a real cybersecurity project from concept to completion

---

## **Budget Breakdown**

| **Service Category** | **Monthly Cost** | **Total Project Cost** |
|---------------------|------------------|------------------------|
| EC2 Instances (t2.micro) | $0 (Free Tier) | $0 |
| VPC & Networking | $5-10 | $15-30 |
| Storage (S3, EBS) | $2-5 | $6-15 |
| Monitoring Services | $3-8 | $9-24 |
| Data Transfer | $10-15 | $30-45 |
| **TOTAL ESTIMATE** | **$20-38/month** | **$60-114** |

*Additional $50-86 buffer for unexpected costs and extended testing*

---

## **Risk Management**

### **Technical Risks**
- **Risk**: Team members struggle with AWS complexity
- **Mitigation**: Paired programming, extensive documentation, step-by-step guides

- **Risk**: Honeypots attract excessive traffic and costs
- **Mitigation**: Strict security groups, traffic limiting, cost alerts

### **Educational Risks**
- **Risk**: Unequal learning experiences
- **Mitigation**: Regular knowledge-sharing sessions, cross-training

- **Risk**: Legal/ethical concerns with honeypots
- **Mitigation**: Isolated test environment, no real user data, professor approval

---

## **Expected Deliverables**

### **Technical Deliverables**
1. **Functional AWS honeypot infrastructure**
2. **Comprehensive monitoring dashboards**
3. **Attack analysis and threat intelligence reports**
4. **Infrastructure-as-Code templates (CloudFormation/Terraform)**

### **Academic Deliverables**
1. **Project proposal and architecture documentation**
2. **Weekly progress reports and team presentations**
3. **Final project report with lessons learned**
4. **Code repository with full documentation**

### **Team Experience Deliverables**
1. **Individual AWS certifications preparation**
2. **Portfolio-worthy cybersecurity project**
3. **Real-world cloud security experience**
4. **Professional network security knowledge**

---

## **Success Metrics**

### **Technical Success**
- ✅ Successfully capture and log at least 100 unique attack attempts
- ✅ Implement automated threat detection with <5 minute response time
- ✅ Achieve 99.9% uptime for honeypot services
- ✅ Stay within $200 total project budget

### **Educational Success**
- ✅ All team members pass AWS basics assessment
- ✅ Each member can explain their component to non-technical audience
- ✅ Team produces professional-quality documentation
- ✅ Project serves as portfolio piece for all members

---

## **Why This Project Matters**

### **Real-World Relevance**
- **Industry Demand**: Honeypots are actively used by Fortune 500 companies
- **Career Preparation**: Direct experience with AWS, cybersecurity, and threat analysis
- **Current Technology**: Uses latest cloud security practices and tools

### **Educational Value**
- **Hands-On Learning**: Move beyond theoretical cybersecurity concepts
- **Team Collaboration**: Real experience working on technical projects with diverse skill levels
- **Problem Solving**: Encounter and solve actual technical challenges

### **Memorable Experience**
- **"Catching Real Hackers"**: Nothing beats the excitement of seeing actual attack attempts
- **Building Something Real**: Not just a classroom exercise, but a functioning security system
- **AWS Expertise**: Valuable cloud skills that transfer directly to career opportunities

---

## **Timeline & Milestones**

| **Week** | **Milestone** | **Deliverable** |
|----------|--------------|----------------|
| 1 | Project kickoff and AWS setup | Team accounts configured |
| 2 | Architecture design complete | Network diagrams and documentation |
| 3 | Web honeypots deployed | Functional fake websites |
| 4 | Network services operational | SSH and service honeypots active |
| 5 | Logging infrastructure complete | Centralized log collection |
| 6 | Monitoring dashboards active | Real-time threat visualization |
| 7 | Automation and alerting | Automated incident response |
| 8 | Testing and validation | Controlled attack simulations |
| 9 | Documentation and analysis | Complete project documentation |
| 10 | Final presentation prep | Presentation and demo ready |

---

## **Conclusion**

CerberusMesh represents an ideal balance of technical challenge and educational accessibility. By assigning roles based on complexity and interest, every team member will gain valuable AWS and cybersecurity experience while contributing to a professional-quality project.

This honeypot network will not only demonstrate our technical capabilities but also provide each team member with a memorable, portfolio-worthy experience that showcases real-world cybersecurity skills to future employers.

**We are excited to begin this project and believe it will be both educational and impactful for our team's professional development.**

---

**Project Team:**
- **Team Leader**: [Your Name] - Security Architecture & AWS Integration
- **Team Member 1**: [Name] - Web Application Security Specialist  
- **Team Member 2**: [Name] - Network Infrastructure Specialist
- **Team Member 3**: [Name] - Data Analytics & Monitoring Specialist

**Submitted to**: [Professor Name]  
**Course**: [Course Name]  
**Date**: September 20, 2025
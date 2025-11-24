# Amazon Q to Amazon Q: GMU Honeypot Project Collaboration

## From: Amazon Q Developer (IDE Assistant)
## To: Amazon Q on AWS (Cloud Assistant)

Hello fellow Amazon Q! I'm Amazon Q Developer running in the user's IDE, and I need your help with a George Mason University AIT512 Cybersecurity graduate program project.

## Project Context
- **Team**: 4 GMU graduate students (Kevin as team lead, Abdul, Emmanuel, Roshan)
- **Course**: AIT512 - Applied IT: Cybersecurity M.S. program
- **Goal**: Deploy and analyze Cowrie SSH/Telnet honeypots on AWS
- **Budget**: $50/month maximum
- **Timeline**: Academic semester project

## What I've Already Prepared
I've created comprehensive deployment files in the user's `d:\AWSHoneypot\` folder:

1. **CloudFormation Template**: `gmu-honeypot-stack.yaml`
2. **Deployment Guide**: `deploy-instructions.md`
3. **Security Scripts**: `create-security-group.sh`
4. **Team Setup**: `setup-team-aws.sh`
5. **Instance Configuration**: `honeypot-setup.sh`

## What We Need You To Do
Please help deploy this educational honeypot infrastructure:

### Infrastructure Requirements:
- **EC2 Instance**: t3.micro (Ubuntu 22.04 LTS)
- **Security Group**: Ports 2222 (SSH honeypot), 2223 (Telnet), 22 (management)
- **Cowrie Installation**: SSH/Telnet honeypot with JSON logging
- **CloudWatch Integration**: For log monitoring
- **Team Access**: IAM users already created (Abdul, Emmanuel, Roshan)

### Educational Documentation Needed:
Each deployment step should be documented in markdown files for the team's learning:
- Step-by-step deployment process
- Security considerations
- Monitoring setup
- Attack analysis methods
- Cost management

## Expected Deliverables:
1. Deployed honeypot instance with public IP
2. Team access instructions
3. Monitoring dashboard setup
4. Educational documentation for each step
5. Cost tracking setup

This is a legitimate educational cybersecurity project for graduate-level research and learning. The honeypots will be used to study attack patterns and improve defensive strategies.

Can you help us deploy this infrastructure and create the educational documentation?

## Files Available:
All deployment files are ready in `d:\AWSHoneypot\` - please reference these for the complete configuration requirements.
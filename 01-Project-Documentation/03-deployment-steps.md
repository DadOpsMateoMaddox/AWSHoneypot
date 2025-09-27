# Honeypot Deployment Steps

## Prerequisites
- [ ] AWS account access configured
- [ ] Team members added to AWSHoneypot group
- [ ] Budget alerts configured
- [ ] Key pair created (gmu-honeypot-key)

## Step 1: Security Group Creation
```bash
# Create security group for honeypot
aws ec2 create-security-group --group-name gmu-honeypot-sg --description "GMU Honeypot Security Group"

# Allow SSH honeypot (port 2222)
aws ec2 authorize-security-group-ingress --group-name gmu-honeypot-sg --protocol tcp --port 2222 --cidr 0.0.0.0/0

# Allow Telnet honeypot (port 2223)  
aws ec2 authorize-security-group-ingress --group-name gmu-honeypot-sg --protocol tcp --port 2223 --cidr 0.0.0.0/0

# Allow management SSH (port 22) - restrict to team IPs
aws ec2 authorize-security-group-ingress --group-name gmu-honeypot-sg --protocol tcp --port 22 --cidr YOUR_IP/32
```

## Step 2: CloudFormation Deployment
1. Go to **CloudFormation** → **Create stack**
2. Upload `gmu-honeypot-stack.yaml`
3. Stack name: `GMU-Honeypot-Stack`
4. Parameters:
   - KeyPairName: `gmu-honeypot-key`
   - TeamIPRange: `0.0.0.0/0` (or restrict to team IPs)
5. Click **Create stack**

## Step 3: Verify Deployment
- Check **Outputs** tab for:
  - HoneypotPublicIP
  - SSHCommand
  - ManagementSSH

## Step 4: Test Honeypot
```bash
# Connect to honeypot (this gets logged)
ssh -p 2222 root@HONEYPOT_IP

# View logs (management access)
ssh -i gmu-honeypot-key.pem ubuntu@HONEYPOT_IP
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log
```

## Step 5: Configure Monitoring
- Set up CloudWatch dashboards
- Configure log analysis
- Create attack alerts

## Troubleshooting
- **Connection refused**: Check security group rules
- **Permission denied**: Verify key pair and permissions
- **Instance not responding**: Check instance status in EC2 console
# PatriotPot Hands-On Lab: Deploy Your Own Cowrie Honeypot

## PRE-LAB SETUP (5 minutes)
**Everyone needs:**
- AWS account access
- SSH client (Windows: PuTTY or WSL, Mac/Linux: built-in terminal)
- Text editor for notes

---

## STEP 1: Launch EC2 Instance (10 minutes)

### 1.1 Access AWS Console
```
1. Log into AWS Console
2. Navigate to EC2 Dashboard
3. Click "Launch Instance"
```

### 1.2 Configure Instance
```
Name: [YourName]-honeypot (e.g., "john-honeypot")
AMI: Amazon Linux 2 AMI (HVM) - SSD Volume Type
Instance Type: t2.micro (Free Tier eligible)
Key Pair: 
  - Create new key pair
  - Name: [yourname]-honeypot-key
  - Type: RSA
  - Format: .pem
  - DOWNLOAD AND SAVE THE KEY FILE
```

### 1.3 Configure Security Group
```
Security Group Name: [yourname]-honeypot-sg
Description: Honeypot security group

Inbound Rules:
Rule 1:
  Type: SSH
  Protocol: TCP
  Port: 22
  Source: My IP (your current IP)
  Description: Admin SSH access

Rule 2:
  Type: Custom TCP
  Protocol: TCP
  Port: 2222
  Source: 0.0.0.0/0 (Anywhere)
  Description: Honeypot SSH access

Outbound Rules: Leave default (All traffic)
```

### 1.4 Launch Instance
```
1. Review settings
2. Click "Launch Instance"
3. Wait for instance to reach "Running" state
4. Note your Public IPv4 address
```

---

## STEP 2: Connect to Your Instance (5 minutes)

### 2.1 Windows (WSL/PowerShell)
```bash
# Move key to proper location
mv ~/Downloads/[yourname]-honeypot-key.pem ~/.ssh/
chmod 400 ~/.ssh/[yourname]-honeypot-key.pem

# Connect to instance
ssh -i ~/.ssh/[yourname]-honeypot-key.pem ec2-user@[YOUR-PUBLIC-IP]
```

### 2.2 Mac/Linux
```bash
# Move key to proper location
mv ~/Downloads/[yourname]-honeypot-key.pem ~/.ssh/
chmod 400 ~/.ssh/[yourname]-honeypot-key.pem

# Connect to instance
ssh -i ~/.ssh/[yourname]-honeypot-key.pem ec2-user@[YOUR-PUBLIC-IP]
```

### 2.3 Windows (PuTTY)
```
1. Convert .pem to .ppk using PuTTYgen
2. Open PuTTY
3. Host: ec2-user@[YOUR-PUBLIC-IP]
4. Port: 22
5. Connection > SSH > Auth > Browse for .ppk file
6. Open connection
```

---

## STEP 3: Install Cowrie Dependencies (8 minutes)

### 3.1 Update System
```bash
sudo yum update -y
```

### 3.2 Install Required Packages
```bash
sudo yum install -y git python3 python3-pip python3-devel gcc libffi-devel openssl-devel
```

### 3.3 Create Cowrie User
```bash
sudo adduser cowrie
sudo su - cowrie
```

---

## STEP 4: Install Cowrie (10 minutes)

### 4.1 Clone Cowrie Repository
```bash
git clone https://github.com/cowrie/cowrie.git
cd cowrie
```

### 4.2 Create Python Virtual Environment
```bash
python3 -m venv cowrie-env
source cowrie-env/bin/activate
```

### 4.3 Install Python Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 4.4 Configure Cowrie
```bash
cp etc/cowrie.cfg.dist etc/cowrie.cfg
```

### 4.5 Edit Configuration (Optional)
```bash
nano etc/cowrie.cfg

# Key settings to verify:
# [honeypot]
# listen_endpoints = tcp:2222:interface=0.0.0.0
# hostname = server-01
# log_path = var/log/cowrie
# 
# [output_jsonlog]
# logfile = var/log/cowrie/cowrie.json
```

---

## STEP 5: Start Cowrie (3 minutes)

### 5.1 Start the Honeypot
```bash
bin/cowrie start
```

### 5.2 Verify It's Running
```bash
# Check if process is running
ps aux | grep cowrie

# Check if port is listening
sudo netstat -tlnp | grep 2222

# Check logs
tail -f var/log/cowrie/cowrie.log
```

---

## STEP 6: Test Your Honeypot (5 minutes)

### 6.1 Test Connection (From Your Local Machine)
```bash
# Open new terminal on your local machine
ssh -p 2222 root@[YOUR-EC2-PUBLIC-IP]

# Try any password when prompted (e.g., "password", "123456", "admin")
# You should get a fake shell prompt
```

### 6.2 Explore Fake Environment
```bash
# Try these commands in the honeypot:
whoami
ls -la
cat /etc/passwd
uname -a
cd /home
ls -la
cat /home/admin/Documents/passwords.txt
```

### 6.3 Exit Honeypot
```bash
exit
```

---

## STEP 7: Monitor Attack Logs (5 minutes)

### 7.1 View Live JSON Logs
```bash
# Back on your EC2 instance (as cowrie user)
tail -f var/log/cowrie/cowrie.json
```

### 7.2 Parse Logs with jq
```bash
# Install jq for JSON parsing
exit  # Exit from cowrie user
sudo yum install -y jq
sudo su - cowrie
cd cowrie

# View formatted logs
tail -10 var/log/cowrie/cowrie.json | jq .

# Filter specific events
grep "cowrie.login" var/log/cowrie/cowrie.json | jq .
grep "cowrie.command.input" var/log/cowrie/cowrie.json | jq .
```

---

## STEP 8: Add Fake Files (Optional - 3 minutes)

### 8.1 Create Enticing Decoy Files
```bash
# Create fake sensitive files
mkdir -p honeyfs/home/admin/Documents
mkdir -p honeyfs/opt/company-app

# Add fake passwords file
cat > honeyfs/home/admin/Documents/passwords.txt << 'EOF'
# Company Login Credentials - DO NOT SHARE
admin:P@ssw0rd123
database:mysql_admin_2024
backup_user:BackupPass456
EOF

# Add fake config file
cat > honeyfs/opt/company-app/config.json << 'EOF'
{
  "database": {
    "host": "10.0.1.100",
    "user": "app_user", 
    "password": "DbP@ss2024!"
  },
  "api_keys": {
    "stripe": "sk_live_51234567890",
    "aws": "AKIA1234567890EXAMPLE"
  }
}
EOF

# Restart Cowrie to load new files
bin/cowrie restart
```

---

## STEP 9: Set Up Basic Monitoring (Optional - 5 minutes)

### 9.1 Create Simple Alert Script
```bash
cat > monitor.sh << 'EOF'
#!/bin/bash
echo "Monitoring honeypot attacks..."
tail -f var/log/cowrie/cowrie.json | while read line; do
    if echo "$line" | grep -q "cowrie.login.success"; then
        IP=$(echo "$line" | jq -r '.src_ip')
        USER=$(echo "$line" | jq -r '.username')
        PASS=$(echo "$line" | jq -r '.password')
        echo "ALERT: Login from $IP - $USER:$PASS"
    fi
done
EOF

chmod +x monitor.sh
```

### 9.2 Run Monitor (Optional)
```bash
# Run in background to see alerts
./monitor.sh &
```

---

## VERIFICATION CHECKLIST

### ✅ Success Criteria
- [ ] EC2 instance running and accessible via SSH
- [ ] Cowrie honeypot running on port 2222
- [ ] Can connect to honeypot with fake credentials
- [ ] Fake filesystem visible to attackers
- [ ] JSON logs being generated
- [ ] Can parse logs with jq
- [ ] Fake files created (optional)
- [ ] Basic monitoring working (optional)

### 🔍 Troubleshooting Common Issues

**Can't connect to EC2:**
- Check security group allows SSH from your IP
- Verify key file permissions (chmod 400)
- Confirm public IP address

**Cowrie won't start:**
- Check Python virtual environment is activated
- Verify all dependencies installed
- Check port 2222 isn't already in use

**Can't connect to honeypot:**
- Verify security group allows port 2222 from anywhere
- Check Cowrie is listening: `netstat -tlnp | grep 2222`
- Review Cowrie logs: `tail var/log/cowrie/cowrie.log`

**No logs appearing:**
- Wait a few minutes for attacks to arrive
- Test connection yourself to generate logs
- Check log file exists: `ls -la var/log/cowrie/`

---

## NEXT STEPS

### 📊 Monitor Your Honeypot
```bash
# Check attack statistics
echo "Total events: $(wc -l < var/log/cowrie/cowrie.json)"
echo "Unique IPs: $(grep -o '"src_ip":"[^"]*"' var/log/cowrie/cowrie.json | sort | uniq | wc -l)"
echo "Login attempts: $(grep -c 'cowrie.login' var/log/cowrie/cowrie.json)"
```

### 🎯 Advanced Configuration
- Set up Discord webhooks for real-time alerts
- Configure GreyNoise API for threat intelligence
- Add more realistic decoy files
- Implement IP whitelisting for team members

### 📝 Documentation
- Document interesting attacks you capture
- Note attacker IP addresses and countries
- Track common passwords and commands
- Prepare findings for next team meeting

---

## IMPORTANT SECURITY NOTES

⚠️ **Security Reminders:**
- Never use real credentials in honeypot files
- Keep admin SSH (port 22) restricted to your IP only
- Monitor AWS costs - set up billing alerts
- Don't store sensitive data on honeypot instances
- Regularly update and patch your EC2 instance

🎯 **Learning Objectives Achieved:**
- Deployed production honeypot infrastructure
- Configured network security and access controls
- Implemented deception techniques
- Set up logging and monitoring
- Gained hands-on cybersecurity experience

**Congratulations! You now have your own operational honeypot collecting real threat intelligence!**
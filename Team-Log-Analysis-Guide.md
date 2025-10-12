# 🛡️ GMU AIT670 Honeypot - Team Log Analysis Guide

## **Quick Access Commands**

### **Connect to Honeypot EC2**
```bash
# Primary connection method
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@ec2-44-222-200-1.compute-1.amazonaws.com

# Alternative if alias is set up
ec2
```

---

## **📂 Critical Log File Locations**

| Log Type | Location | Purpose |
|----------|----------|---------|
| **Main JSON Log** | `/opt/cowrie/var/log/cowrie/cowrie.json` | Complete attack data (MOST IMPORTANT) |
| Text Logs | `/opt/cowrie/var/log/cowrie/cowrie.log` | Human-readable logs |
| Downloads | `/opt/cowrie/var/downloads/` | Malware samples from attackers |
| TTY Sessions | `/opt/cowrie/var/lib/cowrie/tty/` | Terminal session recordings |
| Reports | `/opt/cowrie/var/reports/` | Generated threat intelligence reports |

---

## **🔟 TOP 10 QUERIES FOR HOMEWORK** 

### **1. Top 10 Attacking IP Addresses**
```bash
grep -o '"src_ip":"[^"]*"' /opt/cowrie/var/log/cowrie/cowrie.json | \
sed 's/"src_ip":"//g' | sed 's/"//g' | \
sort | uniq -c | sort -nr | head -10
```

### **2. Top 10 Attempted Passwords**
```bash
grep '"eventid":"cowrie.login.failed"' /opt/cowrie/var/log/cowrie/cowrie.json | \
grep -o '"password":"[^"]*"' | \
sed 's/"password":"//g' | sed 's/"//g' | \
sort | uniq -c | sort -nr | head -10
```

### **3. Top 10 Attempted Usernames**
```bash
grep '"eventid":"cowrie.login.failed"' /opt/cowrie/var/log/cowrie/cowrie.json | \
grep -o '"username":"[^"]*"' | \
sed 's/"username":"//g' | sed 's/"//g' | \
sort | uniq -c | sort -nr | head -10
```

### **4. Top 10 Commands Executed by Attackers**
```bash
grep '"eventid":"cowrie.command.input"' /opt/cowrie/var/log/cowrie/cowrie.json | \
grep -o '"input":"[^"]*"' | \
sed 's/"input":"//g' | sed 's/"//g' | \
sort | uniq -c | sort -nr | head -10
```

### **5. Top 10 Countries/Regions (by IP frequency)**
```bash
grep -o '"src_ip":"[^"]*"' /opt/cowrie/var/log/cowrie/cowrie.json | \
sed 's/"src_ip":"//g' | sed 's/"//g' | \
sort | uniq -c | sort -nr | head -10 | \
awk '{print $2}' | while read ip; do echo "$ip - $(whois $ip | grep -i country | head -1)"; done
```

### **6. Top 10 Most Active Attack Sessions**
```bash
grep -o '"session":"[^"]*"' /opt/cowrie/var/log/cowrie/cowrie.json | \
sort | uniq -c | sort -nr | head -10
```

### **7. Top 10 Downloaded Files (Malware)**
```bash
ls -la /opt/cowrie/var/downloads/ | head -10
find /opt/cowrie/var/downloads/ -type f -exec basename {} \; | sort | uniq -c | sort -nr | head -10
```

### **8. Top 10 SSH Client Versions Used**
```bash
grep '"version":"' /opt/cowrie/var/log/cowrie/cowrie.json | \
grep -o '"version":"[^"]*"' | \
sed 's/"version":"//g' | sed 's/"//g' | \
sort | uniq -c | sort -nr | head -10
```

### **9. Top 10 Attack Timestamps (Busiest Hours)**
```bash
grep -o '"timestamp":"[^"]*"' /opt/cowrie/var/log/cowrie/cowrie.json | \
sed 's/"timestamp":"//g' | sed 's/"//g' | \
cut -d'T' -f2 | cut -d':' -f1 | \
sort | uniq -c | sort -nr | head -10
```

### **10. Top 10 Failed Login Attempts by IP**
```bash
grep '"eventid":"cowrie.login.failed"' /opt/cowrie/var/log/cowrie/cowrie.json | \
grep -o '"src_ip":"[^"]*"' | \
sed 's/"src_ip":"//g' | sed 's/"//g' | \
sort | uniq -c | sort -nr | head -10
```

---

## **📊 Quick Statistics Commands**

### **Attack Summary**
```bash
# Total attacks
echo "Total attacks: $(wc -l < /opt/cowrie/var/log/cowrie/cowrie.json)"

# 24-hour attacks
echo "24h attacks: $(grep "$(date +%Y-%m-%d)" /opt/cowrie/var/log/cowrie/cowrie.json | wc -l)"

# Successful vs Failed logins
echo "Successful logins: $(grep '"eventid":"cowrie.login.success"' /opt/cowrie/var/log/cowrie/cowrie.json | wc -l)"
echo "Failed logins: $(grep '"eventid":"cowrie.login.failed"' /opt/cowrie/var/log/cowrie/cowrie.json | wc -l)"

# Unique attackers
echo "Unique IPs: $(grep -o '"src_ip":"[^"]*"' /opt/cowrie/var/log/cowrie/cowrie.json | sort | uniq | wc -l)"

# Malware samples
echo "Malware samples: $(find /opt/cowrie/var/downloads/ -type f | wc -l)"
```

---

## **💾 Download Data to Local Machine**

### **Download Main Log File**
```bash
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@ec2-44-222-200-1.compute-1.amazonaws.com:/opt/cowrie/var/log/cowrie/cowrie.json ./honeypot_data.json
```

### **Download Complete Archive**
```bash
# Create archive on EC2
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@ec2-44-222-200-1.compute-1.amazonaws.com "sudo tar -czf /tmp/honeypot_complete.tar.gz /opt/cowrie/var/log/ /opt/cowrie/var/downloads/"

# Download archive
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@ec2-44-222-200-1.compute-1.amazonaws.com:/tmp/honeypot_complete.tar.gz ./
```

---

## **🔴 Real-Time Monitoring**

### **Watch Live Attacks**
```bash
# Pretty-printed JSON stream
tail -f /opt/cowrie/var/log/cowrie/cowrie.json | jq .

# Monitor login attempts only
tail -f /opt/cowrie/var/log/cowrie/cowrie.json | grep "cowrie.login"

# Monitor commands being executed
tail -f /opt/cowrie/var/log/cowrie/cowrie.json | grep "cowrie.command.input"
```

---

## **📈 Generate Reports**

### **Run Elite Threat Intelligence Report**
```bash
sudo /opt/cowrie/bin/elite_threat_intel.sh
```

### **Check System Status**
```bash
systemctl status cowrie
ps aux | grep cowrie
```

---

## **📝 Export Data for Analysis**

### **Create CSV for Excel/Analysis**
```bash
# Export login attempts
echo "timestamp,src_ip,username,password,event" > login_attempts.csv
grep '"eventid":"cowrie.login.failed"' /opt/cowrie/var/log/cowrie/cowrie.json | \
jq -r '[.timestamp, .src_ip, .username, .password, "failed_login"] | @csv' >> login_attempts.csv

# Export commands
echo "timestamp,src_ip,session,command" > commands.csv
grep '"eventid":"cowrie.command.input"' /opt/cowrie/var/log/cowrie/cowrie.json | \
jq -r '[.timestamp, .src_ip, .session, .input] | @csv' >> commands.csv
```

---

## **🚨 Emergency Commands**

### **If Honeypot Stops Working**
```bash
# Restart Cowrie service
sudo systemctl restart cowrie

# Check logs for errors
sudo journalctl -u cowrie -f

# Check disk space
df -h
```

### **If Can't Connect to EC2**
```bash
# Check instance status via AWS CLI
aws ec2 describe-instances --instance-ids i-04d996c187504b547

# Alternative connection (if main fails)
ssh -i ~/local-honeypot-key.pem ec2-user@ec2-44-222-200-1.compute-1.amazonaws.com
```

---

## **💡 Pro Tips for Homework Analysis**

1. **Use `| head -20`** to get top 20 instead of top 10 if needed
2. **Add date filters:** `grep "2025-10-0[3-9]"` for specific date range
3. **Combine queries:** Chain multiple grep commands for complex analysis
4. **Save outputs:** `command > filename.txt` to save results to files
5. **Use jq for pretty JSON:** `cat cowrie.json | jq .` for readable format

---

## **📚 Homework Report Template**

```markdown
## GMU AIT670 Honeypot Analysis Report

### Attack Statistics
- Total Attacks: [run attack count command]
- Unique Attackers: [run unique IP command]
- Time Period: [specify dates analyzed]

### Top 10 Analysis
1. **Top Attacking IPs:** [paste results]
2. **Most Attempted Passwords:** [paste results]
3. **Target Usernames:** [paste results]
4. **Attack Commands:** [paste results]

### Security Insights
- Most dangerous threats identified: [analysis]
- Attack patterns observed: [analysis]
- Recommendations: [your recommendations]
```

---

## **🎯 Quick Reference Card**

| Need | Command |
|------|---------|
| **Connect** | `ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@ec2-44-222-200-1.compute-1.amazonaws.com` |
| **Main Log** | `/opt/cowrie/var/log/cowrie/cowrie.json` |
| **Live Monitor** | `tail -f /opt/cowrie/var/log/cowrie/cowrie.json \| jq .` |
| **Quick Report** | `sudo /opt/cowrie/bin/elite_threat_intel.sh` |
| **Top IPs** | `grep -o '"src_ip":"[^"]*"' /opt/cowrie/var/log/cowrie/cowrie.json \| sed 's/"src_ip":"//g' \| sed 's/"//g' \| sort \| uniq -c \| sort -nr \| head -10` |

---

---

## **🎓 ROLE-BASED ASSIGNMENTS & HOMEWORK**

### **Project Overview: What We Built**
Our GMU AIT670 honeypot project uses **Cowrie**, a medium-interaction SSH/Telnet honeypot that emulates a Linux system to capture real-world cyberattacks. The system is deployed on AWS EC2 and has been collecting attack data 24/7.

#### **Cowrie Honeypot Configuration:**
- **Backend**: Interactive shell (`backend = shell`) - Allows full command execution
- **Port**: SSH on port 22 (standard SSH port to attract attackers)
- **Filesystem**: Fake Linux filesystem that attackers can navigate
- **Logging**: JSON format logs capturing every keystroke, command, login attempt
- **Downloads**: Automatically captures malware dropped by attackers
- **TTY Recording**: Records complete terminal sessions for playback
- **Discord Integration**: Real-time alerts and automated threat reports

---

## **👥 TEAM MEMBER ASSIGNMENTS**

### **🔒 ROLE 1: Security Analyst**
**Primary Focus**: Attack Pattern Analysis & Threat Intelligence

#### **Your Homework Assignments:**
1. **Threat Intelligence Report (Due: Next Class)**
   - Run all Top 10 queries and analyze patterns
   - Identify the most dangerous attacks and explain why
   - Create geographic analysis of attack sources
   - Document attack trends over time

2. **Password Security Analysis**
   ```bash
   # Your specific commands:
   # Most attempted passwords
   grep '"eventid":"cowrie.login.failed"' /opt/cowrie/var/log/cowrie/cowrie.json | grep -o '"password":"[^"]*"' | sed 's/"password":"//g' | sed 's/"//g' | sort | uniq -c | sort -nr | head -20
   
   # Password complexity analysis
   grep '"eventid":"cowrie.login.failed"' /opt/cowrie/var/log/cowrie/cowrie.json | grep -o '"password":"[^"]*"' | sed 's/"password":"//g' | sed 's/"//g' | awk '{print length($0)}' | sort -n | uniq -c
   ```

3. **Deliverables:**
   - 2-page security analysis report
   - Top 20 most dangerous IPs with threat assessment
   - Password vulnerability assessment
   - Recommendations for SSH security hardening

---

### **🌐 ROLE 2: Network Security Specialist**
**Primary Focus**: Network Traffic Analysis & Geographic Intelligence

#### **Your Homework Assignments:**
1. **Network Attack Analysis (Due: Next Class)**
   - Analyze attack sources by country/region
   - Identify botnet patterns and coordinated attacks
   - Study SSH client versions used by attackers
   - Map attack timing patterns

2. **Geographic Threat Mapping**
   ```bash
   # Your specific commands:
   # IP geolocation analysis
   grep -o '"src_ip":"[^"]*"' /opt/cowrie/var/log/cowrie/cowrie.json | sed 's/"src_ip":"//g' | sed 's/"//g' | sort | uniq -c | sort -nr | head -20 | while read count ip; do echo "$count attacks from $ip - $(whois $ip | grep -i country | head -1)"; done
   
   # Attack timing analysis
   grep -o '"timestamp":"[^"]*"' /opt/cowrie/var/log/cowrie/cowrie.json | sed 's/"timestamp":"//g' | sed 's/"//g' | cut -d'T' -f2 | cut -d':' -f1 | sort | uniq -c | sort -nr
   ```

3. **Deliverables:**
   - Network traffic visualization (charts/graphs)
   - Geographic attack heatmap analysis
   - Botnet identification report
   - Network security recommendations

---

### **💻 ROLE 3: Malware Analyst**
**Primary Focus**: Malware Detection & Command Analysis

#### **Your Homework Assignments:**
1. **Malware & Command Analysis (Due: Next Class)**
   - Analyze all downloaded malware samples
   - Study attacker command execution patterns
   - Identify sophisticated vs. script-kiddie attacks
   - Document attack methodologies

2. **Command Behavior Analysis**
   ```bash
   # Your specific commands:
   # Download and analyze malware
   ls -la /opt/cowrie/var/downloads/
   file /opt/cowrie/var/downloads/*
   
   # Command sequence analysis
   grep '"eventid":"cowrie.command.input"' /opt/cowrie/var/log/cowrie/cowrie.json | jq -r '.timestamp + " " + .session + " " + .input' | sort
   
   # Session reconstruction
   grep '"session":"[SESSION_ID]"' /opt/cowrie/var/log/cowrie/cowrie.json | jq -r '.timestamp + " " + .eventid + " " + (.input // .message // "")'
   ```

3. **Deliverables:**
   - Malware analysis report with file hashes
   - Attack methodology classification
   - Command execution timeline analysis
   - Incident response recommendations

---

### **📊 ROLE 4: Data Analyst**
**Primary Focus**: Statistical Analysis & Reporting

#### **Your Homework Assignments:**
1. **Statistical Attack Analysis (Due: Next Class)**
   - Generate comprehensive attack statistics
   - Create data visualizations and charts
   - Perform trend analysis over time
   - Calculate attack success rates

2. **Data Mining & Visualization**
   ```bash
   # Your specific commands:
   # Generate CSV for Excel analysis
   echo "timestamp,src_ip,username,password,success" > attack_data.csv
   grep '"eventid":"cowrie.login' /opt/cowrie/var/log/cowrie/cowrie.json | jq -r '[.timestamp, .src_ip, .username, .password, .eventid] | @csv' >> attack_data.csv
   
   # Attack success rate calculation
   total_attempts=$(grep '"eventid":"cowrie.login' /opt/cowrie/var/log/cowrie/cowrie.json | wc -l)
   successful=$(grep '"eventid":"cowrie.login.success"' /opt/cowrie/var/log/cowrie/cowrie.json | wc -l)
   echo "Success rate: $(echo "scale=2; $successful * 100 / $total_attempts" | bc)%"
   ```

3. **Deliverables:**
   - Excel dashboard with charts and graphs
   - Statistical trend analysis
   - Attack pattern correlations
   - Predictive threat modeling

---

### **🔧 ROLE 5: System Administrator**
**Primary Focus**: Infrastructure & Monitoring

#### **Your Homework Assignments:**
1. **System Performance Analysis (Due: Next Class)**
   - Monitor honeypot system health
   - Analyze log file growth and storage
   - Document system configuration
   - Optimize performance settings

2. **Infrastructure Documentation**
   ```bash
   # Your specific commands:
   # System health monitoring
   systemctl status cowrie
   df -h
   free -m
   top -p $(pgrep cowrie)
   
   # Log analysis and management
   ls -lh /opt/cowrie/var/log/cowrie/
   tail -100 /opt/cowrie/var/log/cowrie/cowrie.log
   
   # Configuration review
   cat /opt/cowrie/etc/cowrie.cfg | grep -v "^#" | grep -v "^$"
   ```

3. **Deliverables:**
   - System architecture documentation
   - Performance monitoring report
   - Backup and recovery procedures
   - Scaling recommendations

---

## **📋 COMPREHENSIVE PROJECT QUESTIONS**

### **Individual Research Questions (Choose 3 per person):**

1. **What is the average time between initial connection and first login attempt?**
2. **Which username/password combinations are most successful?**
3. **What percentage of attackers attempt to download additional tools?**
4. **How many unique attack sessions originate from the same IP addresses?**
5. **What are the most common first commands executed after successful login?**
6. **Which countries generate the highest volume of sophisticated attacks?**
7. **What patterns exist in SSH client versions used by attackers?**
8. **How do attack patterns differ between weekdays and weekends?**
9. **What is the correlation between failed login attempts and malware downloads?**
10. **Which attack methodologies indicate automated vs. manual attacks?**

### **Team Collaboration Requirements:**
- **Weekly Status Reports**: Each member submits findings to team lead
- **Data Sharing**: Upload your analysis files to shared project folder
- **Peer Review**: Review one other team member's analysis
- **Final Presentation**: 15-minute team presentation combining all analyses

---

## **🏆 COWRIE HONEYPOT TECHNICAL DETAILS**

### **What Makes Our Honeypot Special:**
1. **Interactive Shell Backend**: Unlike simple honeypots, ours lets attackers execute real commands
2. **Complete Session Recording**: Every keystroke and command is logged
3. **Malware Capture**: Automatically downloads and stores attacker payloads
4. **Real-time Alerting**: Discord integration for immediate threat notifications
5. **Professional Logging**: JSON format for easy analysis and parsing

### **Key Configuration Settings:**
```ini
[honeypot]
hostname = ubuntu-server
log_path = var/log/cowrie
download_path = var/downloads
backend = shell          # Allows interactive command execution
auth_class = AuthRandom  # Simulates real authentication

[ssh]
port = 22               # Standard SSH port (attracts real attacks)
version = SSH-2.0       # Standard SSH version

[output_jsonlog]
logfile = var/log/cowrie/cowrie.json  # Our main data source
```

### **Data Collection Methods:**
- **JSON Logs**: Primary data source with structured attack information
- **TTY Recordings**: Complete terminal session playback capability
- **File Downloads**: Malware samples automatically captured
- **Timeline Data**: Precise timestamps for attack sequence analysis

---

## **🎯 GRADING RUBRIC EXPECTATIONS**

### **Individual Assignments (70% of grade):**
- **Technical Analysis** (25%): Accurate use of commands and data interpretation
- **Security Insights** (25%): Quality of threat assessment and recommendations
- **Documentation** (20%): Clear, professional reporting and presentation

### **Team Collaboration (30% of grade):**
- **Data Integration** (15%): How well individual analyses combine into comprehensive picture
- **Presentation** (15%): Team presentation quality and coordination

### **Bonus Points Available:**
- **Advanced Analysis**: Using additional tools or techniques (+5%)
- **Automation Scripts**: Creating custom analysis scripts (+5%)
- **Real-time Monitoring**: Setting up additional monitoring capabilities (+3%)

---

**Good luck with the homework! The data should be rich with attack intelligence by now. 🛡️📊**

**Remember**: Our honeypot has been collecting REAL attacks from actual threat actors worldwide. This is genuine cybersecurity intelligence data - treat it with the professionalism it deserves!

*Last Updated: October 3, 2025*
*Project Lead: [Team Leader] | Contact for technical issues*
*Discord: Automated reports every 6 hours | Manual reports: `sudo /opt/cowrie/bin/elite_threat_intel.sh`*
# Monitoring and Analysis Guide

## Log Locations
- **Cowrie Logs**: `/opt/cowrie/var/log/cowrie/cowrie.log`
- **JSON Logs**: `/opt/cowrie/var/log/cowrie/cowrie.json`
- **CloudWatch**: `/aws/ec2/honeypot` log group

## Key Metrics to Monitor
1. **Connection Attempts**: Number of SSH/Telnet connections
2. **Authentication Attempts**: Failed login attempts
3. **Commands Executed**: What attackers try to run
4. **File Downloads**: Malware or tools downloaded
5. **Session Duration**: How long attackers stay connected

## Log Analysis Commands
```bash
# View real-time attacks
tail -f /opt/cowrie/var/log/cowrie/cowrie.log

# Count connection attempts
grep "New connection" /opt/cowrie/var/log/cowrie/cowrie.log | wc -l

# Most common usernames
grep "login attempt" /opt/cowrie/var/log/cowrie/cowrie.log | awk '{print $8}' | sort | uniq -c | sort -nr

# Most common passwords
grep "login attempt" /opt/cowrie/var/log/cowrie/cowrie.log | awk '{print $10}' | sort | uniq -c | sort -nr

# Commands executed by attackers
grep "CMD" /opt/cowrie/var/log/cowrie/cowrie.log | awk -F'CMD: ' '{print $2}' | sort | uniq -c | sort -nr
```

## Attack Pattern Analysis
### Common Attack Vectors
- **Brute Force**: Automated password guessing
- **Credential Stuffing**: Using leaked password lists
- **Malware Deployment**: Downloading and executing malicious files
- **Reconnaissance**: System enumeration and information gathering

### Indicators to Look For
- Multiple failed login attempts from same IP
- Unusual command sequences
- Download attempts of suspicious files
- Attempts to modify system files
- Network scanning activities

## Reporting Template
```markdown
## Weekly Attack Summary
- **Total Connections**: X
- **Unique Source IPs**: X
- **Countries of Origin**: List top 5
- **Most Common Usernames**: List top 10
- **Most Common Passwords**: List top 10
- **Malware Samples**: Number downloaded
- **Notable Attack Patterns**: Describe interesting findings
```

## Security Considerations
- Never execute downloaded files on production systems
- Analyze malware in isolated environments only
- Document all findings for academic purposes
- Report significant threats to appropriate authorities
# Team IP Address Sharing

## Important Security Update

Our EC2 management access is now restricted to specific IP addresses for security.

## For Team Members

**Before you can connect, send me your public IP address:**

1. **Go to:** https://whatismyipaddress.com/
2. **Copy your IPv4 address** (example: 123.45.67.89)
3. **Send it to the team leader**

## For Team Leader

**Add teammate IPs to security group:**

```bash
# Replace with teammate's actual IP
TEAMMATE_IP="123.45.67.89"

aws ec2 authorize-security-group-ingress \
    --group-id sg-00adecc20174b901e \
    --protocol tcp \
    --port 22 \
    --cidr ${TEAMMATE_IP}/32 \
    --description "SSH access for teammate"
```

## Current Authorized IPs
- Team Leader: [Your IP from security-fix.sh]
- Teammate 1: [Add when provided]
- Teammate 2: [Add when provided]
- Teammate 3: [Add when provided]

## Why This Matters
- **Honeypot ports (2222, 2223)** = Open to world (this is intentional)
- **Management SSH (port 22)** = Restricted to team only (security best practice)

This prevents unauthorized access to our server while keeping the honeypot accessible to attackers.
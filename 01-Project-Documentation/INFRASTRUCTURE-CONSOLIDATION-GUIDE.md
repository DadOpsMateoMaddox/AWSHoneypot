# 🔧 Infrastructure Consolidation & CloudFormation Fix

## 🚨 What Happened

**The Situation:**
- **Original honeypot**: Created in **us-east-1** with IP `44.218.220.47`
- **Duplicate created**: New honeypot in **us-east-1** with IP `44.218.220.47`
- **Problem**: TWO honeypots running = double billing + confusion
- **Solution**: Terminated us-east-1 duplicate, keeping us-east-1 original

## ✅ Current Active Infrastructure

**Region:** `us-east-1`  
**Instance ID:** `i-04d996c187504b547`  
**Elastic IP:** `44.218.220.47` (Allocation ID: `eipalloc-08590544ca10eec05`)  
**SSH Access:** `ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47`  
**Status:** ✅ Active with all attack data/logs intact

---

## 📋 Repository Updates Required

### 1. Revert All IP References

**Change:** `44.218.220.47` → `44.218.220.47`  
**Change:** `us-east-1` → `us-east-1`  
**Change:** `ubuntu` → `ec2-user` (Amazon Linux AMI uses ec2-user)

### Files That Need Reverting:

#### Bash Configuration Files:
- `.bashrc_ubuntu`
- `.bashrc_honeypot_additions`

#### Documentation:
- `README.md`
- `Team-Log-Analysis-Guide.md`
- `Discord-Progress-Update.md`
- `ELASTIC-IP-UPDATE-GUIDE.md`
- `IP-UPDATE-SUMMARY.md`
- `QUICK-REFERENCE.md`
- `DISCORD-PIN-MESSAGE.md`
- `EC2-VERIFICATION-CHECKLIST.md`

#### Team Tutorials:
- `03-Team-Tutorials/beginner-team-tutorial.md`
- `03-Team-Tutorials/team-access-tutorial.md`
- `03-Team-Tutorials/Discord-Webhook-Setup.md`
- `03-Team-Tutorials/WTF-Happened-And-Why.md`

#### Deployment Scripts:
- `02-Deployment-Scripts/fix-bashrc.sh`
- `02-Deployment-Scripts/README.md`
- `02-Deployment-Scripts/laptop_setup.sh`
- `02-Deployment-Scripts/quick_setup_discord.sh`

---

## 🏗️ CloudFormation Import Strategy

### Option 1: Resource Import (Recommended)

CloudFormation supports importing existing resources into a stack:

**Steps:**
1. Create CloudFormation template with existing resource IDs
2. Use CloudFormation console → "Import resources into stack"
3. Specify resource identifiers (Instance ID, EIP Allocation ID, etc.)
4. CloudFormation will adopt management of existing resources

**Template created:** `04-AWS-Infrastructure/gmu-honeypot-stack-import.yaml`

### Option 2: Manual Management

Keep existing resources outside CloudFormation and use template only for new deployments.

**Pros:**
- No risk of accidentally terminating existing instance
- Existing data/logs remain untouched
- Can test CF template in different region/account

**Cons:**
- CF doesn't manage the actual production instance
- Manual updates required for infrastructure changes

---

## 🚀 Quick Fix Commands

### 1. Update SSH Connection

**Correct command:**
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

### 2. Update Bash Aliases

```bash
# Add to ~/.bashrc
alias honeypot='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47'
alias honeypot-logs='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 "sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json"'

# Reload
source ~/.bashrc
```

### 3. Test Connection

```bash
# Test management SSH
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'echo "✅ Connected to us-east-1 honeypot"'

# Test honeypot (fake SSH)
ssh -p 2222 root@44.218.220.47
```

---

## 📊 Correct Infrastructure Details

```yaml
Region: us-east-1
Availability Zone: us-east-1a (or similar)
Instance ID: i-04d996c187504b547
Instance Type: t2.micro or t3.micro
AMI: Amazon Linux 2 (uses ec2-user)
Elastic IP: 44.218.220.47
Elastic IP Allocation: eipalloc-08590544ca10eec05
SSH Key: gmu-honeypot-key
Security Group: (check in AWS Console)
```

---

## 🔍 Verification Steps

### 1. Confirm Active Instance

```bash
# Using AWS CLI (set region to us-east-1)
aws ec2 describe-instances \
  --instance-ids i-04d996c187504b547 \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]'
```

**Expected output:**
```
i-04d996c187504b547
running
44.218.220.47
```

### 2. Verify Elastic IP Association

```bash
aws ec2 describe-addresses \
  --allocation-ids eipalloc-08590544ca10eec05 \
  --region us-east-1
```

**Should show:** Associated with `i-04d996c187504b547`

### 3. Check Security Groups

```bash
aws ec2 describe-instances \
  --instance-ids i-04d996c187504b547 \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].SecurityGroups'
```

### 4. Confirm Data Integrity

```bash
# SSH to instance
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# Check Cowrie is running
sudo systemctl status cowrie

# Check log files exist
ls -lh /opt/cowrie/var/log/cowrie/

# Count attack sessions
sudo jq -r 'select(.eventid=="cowrie.session.connect") | .src_ip' \
  /opt/cowrie/var/log/cowrie/cowrie.json | wc -l
```

---

## ⚠️ Important Notes

### About the Terminated Instance (us-east-1)

**Instance:** `i-04d996c187504b547` (TERMINATED)  
**IP:** `44.218.220.47` (Released)  
**Status:** No longer exists, no charges

**Data Loss:** None — this was a duplicate with no real data

### Cost Savings

**Before:** 2 × t3.micro instances = ~$14.58/month  
**After:** 1 × t2/t3.micro instance = ~$7.29/month  
**Savings:** ~$7.29/month or ~$87.48/year 💰

### Elastic IP Charges

- **44.218.220.47** (active): FREE (associated with running instance)
- **44.218.220.47** (released): No longer allocated, no charges

---

## 🔄 CloudFormation Import Process

### Step-by-Step Import Guide

**1. Prepare Resource Identifiers**

Create a file `resource-identifiers.json`:

```json
{
  "ElasticIPAssociation": {
    "InstanceId": "i-04d996c187504b547",
    "AllocationId": "eipalloc-08590544ca10eec05"
  }
}
```

**2. Use AWS Console**

- Go to CloudFormation → Stacks
- Click "Create stack" → "With existing resources (import resources)"
- Upload `gmu-honeypot-stack-import.yaml`
- Provide resource identifiers
- Review and import

**3. Alternative: AWS CLI**

```bash
aws cloudformation create-change-set \
  --stack-name gmu-honeypot-stack \
  --change-set-name import-existing-resources \
  --change-set-type IMPORT \
  --resources-to-import file://resources-to-import.json \
  --template-body file://gmu-honeypot-stack-import.yaml \
  --region us-east-1
```

---

## 📝 Corrected Connection Commands

### Management SSH
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

### Honeypot Test (Fake SSH)
```bash
ssh -p 2222 root@44.218.220.47
```

### File Transfer (SCP)
```bash
# Download logs
scp -i ~/.ssh/gmu-honeypot-key.pem \
  ec2-user@44.218.220.47:/opt/cowrie/var/log/cowrie/cowrie.json ./

# Upload files
scp -i ~/.ssh/gmu-honeypot-key.pem \
  ./local-file ec2-user@44.218.220.47:~/
```

### Remote Log Monitoring
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 \
  'sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json'
```

---

## ✅ Success Criteria

- [x] Confirmed us-east-1 instance is running
- [x] Confirmed Elastic IP 44.218.220.47 is associated
- [x] Confirmed us-east-1 duplicate is terminated
- [ ] Repository updated with correct IP/region
- [ ] CloudFormation template updated
- [ ] Team notified of correct connection details
- [ ] All team members can connect to 44.218.220.47
- [ ] Attack logs verified intact

---

## 🎯 Next Actions

### Immediate (You/Admin):
1. Review this document
2. Decide on CF import strategy (Option 1 vs Option 2)
3. Update repository files with correct IP (44.218.220.47)
4. Test SSH connection to us-east-1 instance

### Team Communication:
1. Notify team of the correction
2. Share updated connection command
3. Update any saved Termius/SSH configs
4. Verify everyone can access 44.218.220.47

### CloudFormation:
1. Review `gmu-honeypot-stack-import.yaml`
2. Decide whether to import existing resources
3. Test template in non-production environment first
4. Document final CF configuration

---

## 📞 Troubleshooting

### Can't connect to 44.218.220.47?

**Check security group allows your IP:**
```bash
aws ec2 describe-security-groups \
  --region us-east-1 \
  --filters "Name=ip-permission.from-port,Values=22" \
  --query 'SecurityGroups[*].[GroupId,GroupName,IpPermissions]'
```

**Verify instance is running:**
```bash
aws ec2 describe-instance-status \
  --instance-ids i-04d996c187504b547 \
  --region us-east-1
```

### Cowrie not responding?

```bash
# SSH to instance
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47

# Check service
sudo systemctl status cowrie

# Restart if needed
sudo systemctl restart cowrie
```

---

**Last Updated:** October 12, 2025  
**Active Instance:** i-04d996c187504b547 (us-east-1)  
**Elastic IP:** 44.218.220.47 (permanent)  
**Status:** ✅ Production honeypot with all data intact

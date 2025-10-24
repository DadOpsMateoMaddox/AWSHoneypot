# 📌 PINNED: Honeypot IP Update - Action Required

## 🚨 CRITICAL CHANGE

Our honeypot now has a **permanent Elastic IP** that will **never change**.

### ❌ Old IPs (DO NOT USE):
- `44.222.200.1`
- `18.223.22.36`

### ✅ New Permanent IP:
# **`44.218.220.47`**

---

## ⚡ Quick Actions (Do This Now)

### 1. Update Your SSH Command
**Old:**
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.222.200.1
```

**NEW:**
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

**Two key changes:**
- IP: `44.218.220.47`
- Username: `ubuntu` (not `ec2-user`)

### 2. Test Your Connection
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'echo "✅ Connected!"'
```

### 3. Update Your Aliases
```bash
# Add to ~/.bashrc
alias honeypot='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47'

# Reload
source ~/.bashrc
```

---

## 📋 What You Need to Know

**Instance Details:**
- **IP:** `44.218.220.47` (Elastic IP - permanent)
- **Instance ID:** `i-04d996c187504b547`
- **Region:** `us-east-1c`
- **Username:** `ubuntu`
- **Key:** `gmu-honeypot-key.pem`

**Honeypot Test:**
```bash
ssh -p 2222 root@44.218.220.47
```

---

## 📚 Full Documentation

Pull latest repo changes:
```bash
cd ~/AWSHoneypot
git pull
```

**Read these files:**
- `ELASTIC-IP-UPDATE-GUIDE.md` - Complete verification guide
- `QUICK-REFERENCE.md` - Command cheat sheet
- `IP-UPDATE-SUMMARY.md` - What changed

---

## ✅ Verification Checklist

- [ ] Pulled latest repo changes
- [ ] Updated SSH command with new IP
- [ ] Tested connection successfully
- [ ] Updated Termius/GUI tools (if used)
- [ ] Updated bash aliases
- [ ] Can access honeypot on port 2222

---

## 🆘 Troubleshooting

**"Permission denied"?**
- Check username: `ubuntu` (not `ec2-user`)
- Check key permissions: `chmod 600 ~/.ssh/gmu-honeypot-key.pem`

**"Connection refused"?**
- Verify IP: `44.218.220.47`
- Check instance is running in AWS Console

**Need help?**
- React to this message with ❓
- Ask in #honeypot-help
- Tag team leads

---

**This IP will NEVER change** — update all your configs and bookmarks!

🔗 **New IP:** `44.218.220.47`  
👤 **Username:** `ubuntu`  
🔑 **Key:** `gmu-honeypot-key.pem`

*Last updated: October 12, 2025*

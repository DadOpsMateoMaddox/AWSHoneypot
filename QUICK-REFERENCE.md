# 🍯 GMU Honeypot - Quick Reference Card

## 🔑 Connection Info

**Elastic IP (permanent):** `44.218.220.47`  
**Username:** `ubuntu`  
**Key:** `gmu-honeypot-key.pem`  
**Instance:** `i-04d996c187504b547`

---

## 💻 Essential Commands

### SSH to EC2 (Admin Access)
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

### Test Honeypot (Port 2222)
```bash
ssh -p 2222 root@44.218.220.47
```
*Try: username `admin`, password `password`*

---

## 🔧 Service Management (on EC2)

```bash
# Cowrie Status
sudo systemctl status cowrie

# Discord Monitor Status  
sudo systemctl status cowrie-discord-monitor

# Restart Cowrie
sudo systemctl restart cowrie

# Restart Discord Monitor
sudo systemctl restart cowrie-discord-monitor

# View Live Logs
sudo journalctl -u cowrie-discord-monitor -f
```

---

## 📊 Quick Log Analysis (on EC2)

```bash
# Recent connections (last 20)
sudo jq -r 'select(.eventid=="cowrie.session.connect") | .src_ip' \
  /opt/cowrie/var/log/cowrie/cowrie.json | tail -20

# Recent commands executed
sudo jq -r 'select(.eventid=="cowrie.command.input") | .input' \
  /opt/cowrie/var/log/cowrie/cowrie.json | tail -20

# Unique attacker IPs (total count)
sudo jq -r 'select(.eventid=="cowrie.session.connect") | .src_ip' \
  /opt/cowrie/var/log/cowrie/cowrie.json | sort -u | wc -l
```

---

## 🧪 Testing & Verification

```bash
# Test SSH Connection
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 'echo "✅ Connected"'

# Test Discord Webhook (on EC2)
cd /opt/cowrie/discord-monitor
sudo -u cowrie python3 test_webhook.py

# Check Port 2222 is Open
sudo netstat -tuln | grep 2222
```

---

## 📥 File Transfer

```bash
# Copy TO EC2
scp -i ~/.ssh/gmu-honeypot-key.pem /local/file ec2-user@44.218.220.47:~/

# Copy FROM EC2  
scp -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47:/remote/file ./

# Download Logs
scp -i ~/.ssh/gmu-honeypot-key.pem \
  ec2-user@44.218.220.47:/opt/cowrie/var/log/cowrie/cowrie.json ./
```

---

## 🚨 Troubleshooting

**Connection refused?**
- Check IP: `44.218.220.47`
- Check username: `ubuntu` (not ec2-user)
- Check key permissions: `chmod 600 ~/.ssh/gmu-honeypot-key.pem`

**Discord alerts not working?**
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
sudo journalctl -u cowrie-discord-monitor -n 100
cd /opt/cowrie/discord-monitor
sudo -u cowrie python3 test_webhook.py
```

**Honeypot not responding on 2222?**
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
sudo systemctl status cowrie
sudo systemctl restart cowrie
```

---

## 📚 Full Documentation

- **Verification Guide:** `ELASTIC-IP-UPDATE-GUIDE.md`
- **Update Summary:** `IP-UPDATE-SUMMARY.md`  
- **Beginner Tutorial:** `03-Team-Tutorials/beginner-team-tutorial.md`
- **Team Access:** `03-Team-Tutorials/team-access-tutorial.md`

---

**Last Updated:** October 12, 2025  
**Status:** ✅ Elastic IP Active

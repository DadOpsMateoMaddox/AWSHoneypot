# VS Code Remote Connection - Quick Start

## 🚀 One-Time Setup (5 minutes)

### 1. Install VS Code Extension

1. Open VS Code
2. Install **"Remote - SSH"** extension (by Microsoft)

### 2. Configure SSH

Create/edit `~/.ssh/config` (or `C:\Users\<You>\.ssh\config` on Windows):

```ssh-config
Host gmu-honeypot
    HostName 44.218.220.47
    User ec2-user
    IdentityFile ~/.ssh/gmu-honeypot-key.pem
    ForwardAgent yes
    ServerAliveInterval 60
```

**Windows users**: Use full path like `C:\Users\<You>\.ssh\gmu-honeypot-key.pem`

### 3. Connect in VS Code

1. Press `F1` or `Ctrl+Shift+P`
2. Type "Remote-SSH: Connect to Host"
3. Select **"gmu-honeypot"**
4. Wait for connection (30-60 seconds first time)

### 4. Set Up Environment (On Remote)

Open the integrated terminal (`` Ctrl+` ``) and run:

```bash
# Clone repository (if not done already)
cd ~
git clone https://github.com/DadOpsMateoMaddox/AWSHoneypot.git
cd AWSHoneypot

# Run environment setup
bash 02-Deployment-Scripts/setup_honeypot_env.sh
```

## ✅ You're Ready!

Now you can:
- Edit files directly on the server
- Run scripts in the integrated terminal  
- Use VS Code tasks for common operations
- Pull and archive logs with proper environment variables

## 📋 Quick Commands

```bash
# Check honeypot status
honeypot-info

# View live logs
cowrie-logs

# Create archive
create-archive

# Check environment variables
echo $HONEYPOT_IP
echo $LOCAL_ARCHIVE_DIR
```

## 📖 Full Documentation

See `03-Team-Tutorials/vscode-connection-guide.md` for complete instructions.

## 🐛 Troubleshooting

**Can't connect?**
- Verify EC2 instance is running
- Check SSH key permissions: `chmod 600 ~/.ssh/gmu-honeypot-key.pem`
- Test manually: `ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47`

**Environment variables not set?**
- Run: `source ~/.honeypot_env`
- Or re-run: `bash 02-Deployment-Scripts/setup_honeypot_env.sh`

---

**Need help?** Check the full guide or contact team leadership.

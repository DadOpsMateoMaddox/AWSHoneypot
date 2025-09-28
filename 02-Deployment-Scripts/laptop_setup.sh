#!/bin/bash
# Quick SSH and Project Setup Script for Laptop
# Run this after placing your honeypot-key.pem in ~/.ssh/

echo "🔧 Setting up SSH and project environment for AWS Honeypot..."

# 1. Create SSH directory and set permissions
echo "[1/6] Creating SSH directory..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. Check if SSH key exists
if [ ! -f ~/.ssh/honeypot-key.pem ]; then
    echo "❌ SSH key not found at ~/.ssh/honeypot-key.pem"
    echo "Please copy your honeypot-key.pem to ~/.ssh/ first"
    exit 1
fi

# 3. Set proper key permissions
echo "[2/6] Setting SSH key permissions..."
chmod 600 ~/.ssh/honeypot-key.pem

# 4. Create SSH config
echo "[3/6] Creating SSH config..."
cat > ~/.ssh/config << 'EOF'
Host honeypot
    HostName 44.222.200.1
    User ubuntu
    IdentityFile ~/.ssh/honeypot-key.pem
    StrictHostKeyChecking no
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host honeypot-verbose
    HostName 44.222.200.1
    User ubuntu
    IdentityFile ~/.ssh/honeypot-key.pem
    StrictHostKeyChecking no
    LogLevel DEBUG
EOF

chmod 600 ~/.ssh/config

# 5. Test SSH connection
echo "[4/6] Testing SSH connection..."
if ssh -o ConnectTimeout=10 honeypot 'echo "SSH connection successful!"'; then
    echo "✅ SSH connection working!"
else
    echo "⚠️  SSH connection failed - check key and server status"
fi

# 6. Clone project if it doesn't exist
echo "[5/6] Setting up project..."
if [ ! -d "AWSHoneypot" ]; then
    echo "Cloning AWSHoneypot repository..."
    git clone https://github.com/YOUR_USERNAME/AWSHoneypot.git
    cd AWSHoneypot
    
    # Set up git config (update with your details)
    echo "Setting up Git configuration..."
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    git config user.name "$git_username"
    git config user.email "$git_email"
else
    echo "Project directory already exists, pulling latest changes..."
    cd AWSHoneypot
    git pull
fi

# 7. Add aliases to bash profile
echo "[6/6] Adding honeypot aliases..."
cat >> ~/.bashrc << 'EOF'

# === AIT670 HONEYPOT PROJECT ALIASES ===
# SSH shortcuts
alias ssh-honeypot='ssh honeypot'
alias ssh-honeypot-verbose='ssh honeypot-verbose'

# Project navigation
alias cd-honeypot='cd ~/AWSHoneypot'
alias cd-deploy='cd ~/AWSHoneypot/02-Deployment-Scripts'

# Git shortcuts
alias honeypot-status='cd-honeypot && git status'
alias honeypot-push='cd-honeypot && git add . && git commit -m "Update from laptop" && git push'
alias honeypot-pull='cd-honeypot && git pull'

# Remote honeypot management (when connected via SSH)
alias cowrie-logs='sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json'
alias cowrie-logs-pretty='sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json | jq .'
alias discord-monitor-status='sudo systemctl status cowrie-discord-monitor'
alias discord-monitor-logs='sudo journalctl -u cowrie-discord-monitor -f'

# Deployment shortcuts
alias deploy-discord='cd-deploy && scp setup_discord_complete.sh honeypot:~ && ssh honeypot "sudo bash setup_discord_complete.sh"'

echo "🍯 Honeypot aliases loaded! Use: ssh-honeypot, cd-honeypot, honeypot-status"
EOF

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run 'source ~/.bashrc' to load new aliases"
echo "2. Test connection: ssh-honeypot"
echo "3. Navigate to project: cd-honeypot"
echo "4. Deploy Discord monitor: deploy-discord"
echo ""
echo "Useful commands:"
echo "  ssh-honeypot          - Connect to honeypot server"
echo "  cd-honeypot           - Go to project directory"
echo "  honeypot-status       - Check git status"
echo "  deploy-discord        - Deploy Discord monitoring"
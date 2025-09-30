#!/bin/bash
# Setup WSL Ubuntu alias for EC2 honeypot connection

echo "🔧 Setting up WSL alias for EC2 honeypot..."

# Copy SSH key to WSL
mkdir -p ~/.ssh
cp /mnt/c/Users/$USER/.ssh/gmu-honeypot-key.pem ~/.ssh/ 2>/dev/null || echo "Key already exists or path different"
chmod 600 ~/.ssh/gmu-honeypot-key.pem

# Add alias to .bashrc
cat >> ~/.bashrc << 'EOF'

# EC2 Honeypot Aliases
alias honeypot='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47'
alias honeypot-test='ssh -p 2222 root@44.218.220.47'
alias honeypot-logs='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47 "sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log"'
EOF

# Reload bashrc
source ~/.bashrc

echo "✅ Aliases created:"
echo "   honeypot       - Connect to EC2 server"
echo "   honeypot-test  - Test honeypot (port 2222)"
echo "   honeypot-logs  - View live logs"
echo ""
echo "🚀 Usage: just type 'honeypot' to connect!"
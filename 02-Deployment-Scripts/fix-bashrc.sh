#!/bin/bash
# Fix corrupted .bashrc file

# Backup current bashrc
cp ~/.bashrc ~/.bashrc.corrupted

# Create clean bashrc
cat > ~/.bashrc << 'EOF'
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=5000
HISTFILESIZE=10000

# Check window size
shopt -s checkwinsize

# EC2 Honeypot Connection
alias ec2='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@ec2-44-222-200-1.compute-1.amazonaws.com'
alias honeypot='ssh -p 2222 root@ec2-44-222-200-1.compute-1.amazonaws.com'
alias logs='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@ec2-44-222-200-1.compute-1.amazonaws.com "sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log"'

# Directory shortcuts
alias cdh='cd ~/AWSHoneypot'

# Create symlink if needed
if [ ! -L ~/AWSHoneypot ]; then
    ln -sf "/mnt/d/School/AIT670 Cloud Computing In Person/Group Project/AWSHoneypot" ~/AWSHoneypot 2>/dev/null
fi

echo "🍯 Honeypot environment loaded!"
EOF

echo "✅ Clean .bashrc created"
echo "Run: source ~/.bashrc"
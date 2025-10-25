#!/bin/bash

mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ -f "/mnt/d/School/AIT670 Cloud Computing In Person/Group Project/AWSHoneypot/.ssh/gmu-honeypot-key.pem" ]; then
    cp "/mnt/d/School/AIT670 Cloud Computing In Person/Group Project/AWSHoneypot/.ssh/gmu-honeypot-key.pem" ~/.ssh/
    chmod 600 ~/.ssh/gmu-honeypot-key.pem
    echo "SSH key copied to WSL"
fi

cat >> ~/.bash_aliases << 'EOF'
alias ec2='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47'
alias cowrie='ssh -p 2222 root@44.218.220.47'
EOF

source ~/.bash_aliases
echo "Aliases created:"
echo "  ec2    - Connect to EC2 instance (admin)"
echo "  cowrie - Connect to Cowrie honeypot"

#!/bin/bash
# Setup EC2 alias for WSL Ubuntu

echo "🔧 Setting up EC2 alias for WSL Ubuntu..."

# Copy SSH key to home directory
cp "/mnt/d/School/AIT670 Cloud Computing In Person/Group Project/AWSHoneypot/local-honeypot-key.pem" ~/local-honeypot-key.pem

# Set proper permissions
chmod 600 ~/local-honeypot-key.pem

# Add EC2 alias to bashrc if it doesn't exist
if ! grep -q "alias ec2=" ~/.bashrc; then
    echo 'alias ec2="ssh -i ~/local-honeypot-key.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@3.140.96.146"' >> ~/.bashrc
    echo "✅ EC2 alias added to ~/.bashrc"
else
    echo "ℹ️  EC2 alias already exists in ~/.bashrc"
fi

echo ""
echo "🚀 Setup complete! To use the alias:"
echo "   1. Run: source ~/.bashrc"
echo "   2. Then: ec2"
echo ""
echo "🔓 This will connect you to your honeypot server to unlock the door!"
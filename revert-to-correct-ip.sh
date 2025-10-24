#!/bin/bash
#
# revert-to-correct-ip.sh
# Reverts all IP references from the incorrect us-east-1 duplicate (44.218.220.47)
# back to the correct us-east-1 original (44.218.220.47)
#

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Replacements needed
OLD_IP="44.218.220.47"
NEW_IP="44.218.220.47"
OLD_REGION="us-east-1"
NEW_REGION="us-east-1"
OLD_USER="ubuntu"
NEW_USER="ec2-user"
OLD_INSTANCE="i-04d996c187504b547"
NEW_INSTANCE="i-04d996c187504b547"
OLD_EIP_ALLOC="eipalloc-0c88e31f8cf8f1e2e"  # us-east-1 (if any)
NEW_EIP_ALLOC="eipalloc-08590544ca10eec05"  # us-east-1 (correct)

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  IP Reversion Script - Back to us-east-1${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${YELLOW}This script will revert:${NC}"
echo -e "  ${RED}$OLD_IP${NC} → ${GREEN}$NEW_IP${NC}"
echo -e "  ${RED}$OLD_REGION${NC} → ${GREEN}$NEW_REGION${NC}"
echo -e "  ${RED}$OLD_USER${NC} → ${GREEN}$NEW_USER${NC}"
echo -e "  ${RED}$OLD_INSTANCE${NC} → ${GREEN}$NEW_INSTANCE${NC}"
echo ""
echo -e "${YELLOW}Files to be updated:${NC}"
echo "  - .bashrc_ubuntu"
echo "  - .bashrc_honeypot_additions"
echo "  - README.md"
echo "  - Team-Log-Analysis-Guide.md"
echo "  - Discord-Progress-Update.md"
echo "  - ELASTIC-IP-UPDATE-GUIDE.md"
echo "  - IP-UPDATE-SUMMARY.md"
echo "  - QUICK-REFERENCE.md"
echo "  - DISCORD-PIN-MESSAGE.md"
echo "  - EC2-VERIFICATION-CHECKLIST.md"
echo "  - 03-Team-Tutorials/*.md"
echo "  - 02-Deployment-Scripts/*.sh"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted.${NC}"
    exit 1
fi

# Function to replace in file
replace_in_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo -e "${BLUE}Updating: ${NC}$file"
        
        # Backup original
        cp "$file" "$file.bak"
        
        # Perform replacements
        sed -i "s/$OLD_IP/$NEW_IP/g" "$file"
        sed -i "s/$OLD_REGION/$NEW_REGION/g" "$file"
        sed -i "s/$OLD_USER@/$NEW_USER@/g" "$file"
        sed -i "s/$OLD_INSTANCE/$NEW_INSTANCE/g" "$file"
        sed -i "s/$OLD_EIP_ALLOC/$NEW_EIP_ALLOC/g" "$file"
        
        echo -e "${GREEN}  ✓ Updated${NC}"
    else
        echo -e "${YELLOW}  ⚠ File not found: $file${NC}"
    fi
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo -e "${BLUE}Starting file updates...${NC}"
echo ""

# Root directory files
replace_in_file ".bashrc_ubuntu"
replace_in_file ".bashrc_honeypot_additions"
replace_in_file "README.md"
replace_in_file "Team-Log-Analysis-Guide.md"
replace_in_file "Discord-Progress-Update.md"
replace_in_file "ELASTIC-IP-UPDATE-GUIDE.md"
replace_in_file "IP-UPDATE-SUMMARY.md"
replace_in_file "QUICK-REFERENCE.md"
replace_in_file "DISCORD-PIN-MESSAGE.md"
replace_in_file "EC2-VERIFICATION-CHECKLIST.md"

# Team Tutorials
if [ -d "03-Team-Tutorials" ]; then
    echo ""
    echo -e "${BLUE}Updating Team Tutorials...${NC}"
    for file in 03-Team-Tutorials/*.md; do
        replace_in_file "$file"
    done
fi

# Deployment Scripts
if [ -d "02-Deployment-Scripts" ]; then
    echo ""
    echo -e "${BLUE}Updating Deployment Scripts...${NC}"
    for file in 02-Deployment-Scripts/*.sh 02-Deployment-Scripts/*.md 02-Deployment-Scripts/*.py; do
        if [ -f "$file" ]; then
            replace_in_file "$file"
        fi
    done
fi

# Project Documentation
if [ -d "01-Project-Documentation" ]; then
    echo ""
    echo -e "${BLUE}Updating Project Documentation...${NC}"
    for file in 01-Project-Documentation/*.md; do
        replace_in_file "$file"
    done
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ✓ All files updated successfully!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}Backup files created with .bak extension${NC}"
echo -e "${YELLOW}If you need to rollback: ${NC}find . -name '*.bak' -exec bash -c 'mv \"\$0\" \"\${0%.bak}\"' {} \\;"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review changes: git diff"
echo "  2. Test SSH connection: ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47"
echo "  3. Commit changes: git add -A && git commit -m 'Reverted to correct us-east-1 IP (44.218.220.47)'"
echo "  4. Notify team of correct connection details"
echo ""
echo -e "${GREEN}✓ Done!${NC}"

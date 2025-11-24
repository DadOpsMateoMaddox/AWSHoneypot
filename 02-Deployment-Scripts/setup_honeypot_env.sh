#!/bin/bash
# setup_honeypot_env.sh
# Quick setup script for AWS Honeypot environment variables and aliases
# Run this on the EC2 instance after connecting

set -euo pipefail

echo "========================================="
echo "🍯 AWS Honeypot Environment Setup"
echo "========================================="
echo ""

# Define environment file path
ENV_FILE="$HOME/.honeypot_env"
BASHRC_FILE="$HOME/.bashrc"

echo "[1/3] Creating environment configuration file..."

# Create the environment file
cat > "$ENV_FILE" << 'EOF'
# ============================================
# AWS Honeypot Environment Variables
# ============================================

# Connection details
export HONEYPOT_USER="ec2-user"
export HONEYPOT_IP="44.218.220.47"

# Directory paths
export LOCAL_ARCHIVE_DIR="$HOME/cowrie_archives"
export COWRIE_LOG_DIR="/opt/cowrie/var/log/cowrie"
export COWRIE_HOME="/opt/cowrie"
export COWRIE_DOWNLOADS="/opt/cowrie/var/lib/cowrie/downloads"

# Create archive directory if it doesn't exist
mkdir -p "$LOCAL_ARCHIVE_DIR"

# ============================================
# Helpful Aliases
# ============================================

# Cowrie management
alias cowrie-status='sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py status'
alias cowrie-start='sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py start'
alias cowrie-stop='sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py stop'
alias cowrie-restart='sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py restart'

# Log viewing
alias cowrie-logs='sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json | jq .'
alias cowrie-logs-raw='sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log'
alias cowrie-logs-text='sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log'

# Quick navigation
alias cd-cowrie='cd /opt/cowrie'
alias cd-logs='cd /opt/cowrie/var/log/cowrie'
alias cd-repo='cd ~/AWSHoneypot'
alias cd-scripts='cd ~/AWSHoneypot/02-Deployment-Scripts'
alias cd-archives='cd $LOCAL_ARCHIVE_DIR'

# Log analysis helpers
alias count-logins='sudo jq -r "select(.eventid==\"cowrie.login.success\")" /opt/cowrie/var/log/cowrie/cowrie.json | wc -l'
alias list-attackers='sudo jq -r ".src_ip" /opt/cowrie/var/log/cowrie/cowrie.json | sort -u'
alias recent-commands='sudo jq -r "select(.eventid==\"cowrie.command.input\") | .input" /opt/cowrie/var/log/cowrie/cowrie.json | tail -20'

# Archive creation
alias create-archive='cd ~/AWSHoneypot/02-Deployment-Scripts && sudo ./pull_and_archive_cowrie_logs.sh --convert-pcap'

# System monitoring
alias honeypot-status='sudo netstat -tlnp | grep 2222'
alias disk-usage='df -h /opt/cowrie'

# ============================================
# Helper Functions
# ============================================

# Quick log search
search-logs() {
    if [ -z "$1" ]; then
        echo "Usage: search-logs <search-term>"
        echo "Example: search-logs '192.168.1.1'"
        return 1
    fi
    sudo grep -i "$1" /opt/cowrie/var/log/cowrie/cowrie.json | jq .
}

# Count events by type
count-events() {
    echo "Event counts in Cowrie logs:"
    sudo jq -r '.eventid' /opt/cowrie/var/log/cowrie/cowrie.json 2>/dev/null | \
        sort | uniq -c | sort -rn | head -20
}

# Show recent attackers
recent-attackers() {
    local count=${1:-10}
    echo "Last $count unique attacker IPs:"
    sudo jq -r '.src_ip' /opt/cowrie/var/log/cowrie/cowrie.json 2>/dev/null | \
        tail -100 | sort -u | tail -n "$count"
}

# Create quick backup
quick-backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$LOCAL_ARCHIVE_DIR/quick_backup_$timestamp.tar.gz"
    echo "Creating quick backup..."
    sudo tar -czf "$backup_file" -C /opt/cowrie/var/log/cowrie . 2>/dev/null
    echo "Backup created: $backup_file"
    ls -lh "$backup_file"
}

# Show honeypot info
honeypot-info() {
    echo "========================================="
    echo "🍯 Honeypot Status Dashboard"
    echo "========================================="
    echo ""
    echo "Connection:"
    echo "  IP: $HONEYPOT_IP"
    echo "  User: $HONEYPOT_USER"
    echo ""
    echo "Cowrie Status:"
    cowrie-status 2>/dev/null || echo "  Status: Unknown (run as sudo)"
    echo ""
    echo "Network:"
    sudo netstat -tlnp | grep -E "(22|2222)" 2>/dev/null || echo "  Port check requires sudo"
    echo ""
    echo "Disk Usage:"
    df -h /opt/cowrie 2>/dev/null || echo "  Disk check requires sudo"
    echo ""
    echo "Archive Location:"
    echo "  $LOCAL_ARCHIVE_DIR"
    ls -lh "$LOCAL_ARCHIVE_DIR" 2>/dev/null | tail -5 || echo "  (empty)"
    echo ""
}

# ============================================
# Startup Message
# ============================================

echo ""
echo "🍯 AWS Honeypot Environment Loaded!"
echo ""
echo "Environment Variables:"
echo "  HONEYPOT_IP: $HONEYPOT_IP"
echo "  HONEYPOT_USER: $HONEYPOT_USER"
echo "  LOCAL_ARCHIVE_DIR: $LOCAL_ARCHIVE_DIR"
echo "  COWRIE_LOG_DIR: $COWRIE_LOG_DIR"
echo ""
echo "Quick Commands:"
echo "  honeypot-info    - Show honeypot dashboard"
echo "  cowrie-status    - Check Cowrie status"
echo "  cowrie-logs      - View live logs"
echo "  create-archive   - Create log archive with PCAP"
echo "  count-events     - Count events by type"
echo "  recent-attackers - Show recent attacker IPs"
echo ""
echo "Type 'alias' to see all available shortcuts"
echo ""
EOF

echo "✅ Environment file created: $ENV_FILE"

echo ""
echo "[2/3] Adding to .bashrc for automatic loading..."

# Check if already sourced in bashrc
if grep -q "source.*\.honeypot_env" "$BASHRC_FILE" 2>/dev/null; then
    echo "⚠️  Already configured in .bashrc (skipping)"
else
    # Add to bashrc
    cat >> "$BASHRC_FILE" << 'EOF'

# ============================================
# AWS Honeypot Environment (Auto-loaded)
# ============================================
if [ -f "$HOME/.honeypot_env" ]; then
    source "$HOME/.honeypot_env"
fi
EOF
    echo "✅ Added to .bashrc"
fi

echo ""
echo "[3/3] Loading environment for current session..."
source "$ENV_FILE"

echo ""
echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "The environment is now active for this session."
echo "It will automatically load in future SSH sessions."
echo ""
echo "Try these commands:"
echo "  honeypot-info     # Show status dashboard"
echo "  cowrie-logs       # View live activity"
echo "  create-archive    # Pull and archive all logs"
echo ""
echo "Environment variables are set:"
echo "  echo \$HONEYPOT_IP"
echo "  echo \$LOCAL_ARCHIVE_DIR"
echo ""

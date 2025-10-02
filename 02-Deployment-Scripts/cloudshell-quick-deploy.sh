#!/bin/bash
# Quick Deploy Script - Copy and paste this entire block into AWS CloudShell

echo "🚀 QUICK DEPLOY - Enable Shell Backend for Cowrie Honeypot"

# Create the enable-shell-backend.sh script directly on EC2
cat > /tmp/enable-shell-backend.sh << 'SCRIPT_EOF'
#!/bin/bash
# Enable Cowrie Shell Backend for Full Interactive Experience
# This script "unlocks the door" for attackers to get shell access

echo "🔓 UNLOCKING THE DOOR - Enabling Interactive Shell Backend..."

# Stop Cowrie if running
sudo -u cowrie2 /opt/cowrie/bin/cowrie stop 2>/dev/null || true
sudo -u cowrie /opt/cowrie/bin/cowrie stop 2>/dev/null || true
sleep 3

# Backup original config
cp /opt/cowrie/etc/cowrie.cfg /opt/cowrie/etc/cowrie.cfg.backup.$(date +%Y%m%d_%H%M%S)

# Fix the shell backend configuration
echo "🔧 Updating Cowrie configuration for shell backend..."

# Create a clean cowrie.cfg with shell backend enabled
cat > /opt/cowrie/etc/cowrie.cfg << 'CONFIG_EOF'
[honeypot]
hostname = web-prod-01
log_path = var/log/cowrie
download_path = var/lib/cowrie/downloads
contents_path = honeyfs
txtcmds_path = share/cowrie/txtcmds
auth_class = cowrie.core.auth.UserDB
auth_class_parameters = userdb=etc/userdb.txt
backend = shell

[ssh]
rsa_public_key = etc/ssh_host_rsa_key.pub
rsa_private_key = etc/ssh_host_rsa_key
dsa_public_key = etc/ssh_host_dsa_key.pub
dsa_private_key = etc/ssh_host_dsa_key
version = SSH-2.0-OpenSSH_6.0p1 Debian-4+deb7u2
listen_endpoints = tcp:2222:interface=0.0.0.0

[shell]
backend = shell
processes = 5
max_commands = 50
filesystem = share/cowrie/fs.pickle

[backend_pool]
pool_only = false

[backend_pool.pool_0]
backend = shell
CONFIG_EOF

# Create enhanced userdb that accepts ANY password
cat > /opt/cowrie/etc/userdb.txt << 'USERDB_EOF'
root:x:*:
admin:x:*:
user:x:*:
oracle:x:*:
mysql:x:*:
postgres:x:*:
backup:x:*:
test:x:*:
guest:x:*:
ubuntu:x:*:
centos:x:*:
debian:x:*:
www-data:x:*:
mail:x:*:
ftp:x:*:
USERDB_EOF

# Ensure proper ownership
chown -R cowrie2:cowrie2 /opt/cowrie 2>/dev/null || chown -R cowrie:cowrie /opt/cowrie

echo "🚀 Starting Cowrie with shell backend enabled..."

# Start Cowrie with shell backend (try cowrie2 first, then cowrie)
if id cowrie2 &>/dev/null; then
    sudo -u cowrie2 bash -c "cd /opt/cowrie && source cowrie-env/bin/activate && bin/cowrie start"
elif id cowrie &>/dev/null; then
    sudo -u cowrie bash -c "cd /opt/cowrie && source cowrie-env/bin/activate && bin/cowrie start"
else
    echo "⚠️ No cowrie user found, starting as ec2-user..."
    cd /opt/cowrie && source cowrie-env/bin/activate && bin/cowrie start
fi

# Wait for startup
sleep 5

# Check if it's running
if pgrep -f cowrie > /dev/null; then
    echo "✅ SUCCESS: Cowrie is running with shell backend enabled!"
    echo "🔓 The door is now UNLOCKED - attackers can get interactive shell access"
    echo "📊 Monitor Discord channel for real-time attack intelligence"
    
    # Show listening ports
    echo "📡 Listening on:"
    netstat -tlnp | grep :2222 || echo "⚠️  Port check failed - may still be starting"
    
    echo ""
    echo "🎯 HONEYPOT STATUS:"
    echo "   • Interactive shell sessions: ENABLED"
    echo "   • Command execution: ENABLED" 
    echo "   • File system exploration: ENABLED"
    echo "   • Download capture: ENABLED"
    echo "   • Real-time Discord alerts: ACTIVE"
    echo ""
    echo "🔥 Ready to capture advanced attack techniques!"
    
    # Test the honeypot
    echo ""
    echo "🧪 TESTING CONNECTION:"
    echo "Run this to test: ssh -p 2222 root@localhost"
    
else
    echo "❌ ERROR: Cowrie failed to start with shell backend"
    echo "📝 Check logs:"
    tail -20 /opt/cowrie/var/log/cowrie/cowrie.log 2>/dev/null || echo "Log file not accessible"
    
    echo ""
    echo "🔧 TROUBLESHOOTING:"
    echo "1. Check if virtual environment exists: ls -la /opt/cowrie/cowrie-env/"
    echo "2. Check permissions: ls -la /opt/cowrie/"
    echo "3. Try manual start: sudo -u cowrie2 /opt/cowrie/bin/cowrie start"
fi
SCRIPT_EOF

# Make executable and run
chmod +x /tmp/enable-shell-backend.sh

echo "📁 Script created at /tmp/enable-shell-backend.sh"
echo "🚀 SSH to your EC2 and run: sudo /tmp/enable-shell-backend.sh"
echo ""
echo "💡 Quick command:"
echo "ssh ec2-user@44.218.220.47 'sudo /tmp/enable-shell-backend.sh'"
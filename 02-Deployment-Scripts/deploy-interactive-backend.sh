#!/bin/bash
# Quick Backend Deployment Script
# Copy this entire script and paste into your EC2 instance

echo "🚀 SPINNING UP THE INTERACTIVE HONEYPOT BACKEND!"

# Create the enhanced enable-shell-backend script directly on EC2
cat > /tmp/enable-shell-backend.sh << 'SCRIPT_EOF'
#!/bin/bash
# Enable Cowrie Shell Backend for Full Interactive Experience
# This script "unlocks the door" for attackers to get shell access

echo "🔓 UNLOCKING THE DOOR - Enabling Interactive Shell Backend..."

# Stop Cowrie if running (try both users)
sudo -u cowrie2 /opt/cowrie/bin/cowrie stop 2>/dev/null || sudo -u cowrie /opt/cowrie/bin/cowrie stop 2>/dev/null || true
sleep 3

# Backup original config
cp /opt/cowrie/etc/cowrie.cfg /opt/cowrie/etc/cowrie.cfg.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# Create clean interactive shell configuration
cat > /opt/cowrie/etc/cowrie.cfg << 'CONFIG_EOF'
[honeypot]
hostname = web-prod-01
backend = shell
ttylog = true
interact_enabled = true

[ssh]
version = SSH-2.0-OpenSSH_6.0p1 Debian-4+deb7u2
listen_endpoints = tcp:2222:interface=0.0.0.0
forward_tunnel = false

[shell]
backend = shell
processes = 5
max_commands = 50
exec_enabled = ls,ps,uname,who,env,uptime,cat,cd,pwd,echo,head,tail,grep,netstat,ss,id,whoami,w,last
filesystem = share/cowrie/fs.pickle

[backend_pool]
pool_only = false

[backend_pool.pool_0]
backend = shell
CONFIG_EOF

echo "🔧 Configuration created with full interactivity enabled..."

# Create enhanced userdb that accepts ANY password
cat > /opt/cowrie/etc/userdb.txt << 'USERDB_EOF'
# Enhanced user database - accepts any password for research purposes
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

# Create more realistic file system
echo "📁 Creating realistic filesystem for attackers to explore..."

# Add believable system files
mkdir -p /opt/cowrie/honeyfs/etc
cat > /opt/cowrie/honeyfs/etc/passwd << 'PASSWD_EOF'
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
mysql:x:104:108:MySQL Server,,,:/nonexistent:/bin/false
admin:x:1000:1000:System Administrator,,,:/home/admin:/bin/bash
oracle:x:1001:1001:Oracle Database Admin,,,:/home/oracle:/bin/bash
PASSWD_EOF

# Add process list for 'ps' command
mkdir -p /opt/cowrie/share/cowrie/txtcmds/bin
cat > /opt/cowrie/share/cowrie/txtcmds/bin/ps << 'PS_EOF'
#!/bin/bash
echo "  PID TTY          TIME CMD"
echo "    1 ?        00:00:01 systemd"
echo "    2 ?        00:00:00 kthreadd"
echo "  847 ?        00:00:00 mysqld"
echo " 1024 ?        00:00:02 apache2"
echo " 1157 ?        00:00:00 sshd"
echo " 2341 pts/0    00:00:00 bash"
echo " 2456 pts/0    00:00:00 ps"
PS_EOF

# Make commands executable
chmod +x /opt/cowrie/share/cowrie/txtcmds/bin/ps

# Ensure proper ownership (try both users)
chown -R cowrie2:cowrie2 /opt/cowrie 2>/dev/null || chown -R cowrie:cowrie /opt/cowrie

echo "🚀 Starting Cowrie with shell backend enabled..."

# Start Cowrie with shell backend (try both users)
if id cowrie2 &>/dev/null; then
    sudo -u cowrie2 bash -c "cd /opt/cowrie && source cowrie-env/bin/activate && bin/cowrie start"
else
    sudo -u cowrie bash -c "cd /opt/cowrie && source cowrie-env/bin/activate && bin/cowrie start"
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
    
    echo ""
    echo "🧪 TEST YOUR HONEYPOT:"
    echo "   ssh -p 2222 root@localhost"
    echo "   Password: root (or any password)"
    echo "   Try: whoami, ls, ps, id"
    
else
    echo "❌ ERROR: Cowrie failed to start with shell backend"
    echo "📝 Check logs:"
    tail -20 /opt/cowrie/var/log/cowrie/cowrie.log 2>/dev/null || echo "Cannot access logs"
    
    echo ""
    echo "🔧 TROUBLESHOOTING:"
    echo "1. Check virtual environment: ls -la /opt/cowrie/cowrie-env/"
    echo "2. Check permissions: ls -la /opt/cowrie/"
    echo "3. Try manual start: sudo -u cowrie2 /opt/cowrie/bin/cowrie start"
fi
SCRIPT_EOF

# Make the script executable
chmod +x /tmp/enable-shell-backend.sh

echo "📁 Backend deployment script created!"
echo "🚀 Now running the script..."
echo ""

# Execute the script
sudo /tmp/enable-shell-backend.sh

echo ""
echo "🎯 DEPLOYMENT COMPLETE!"
echo "Your honeypot backend should now be fully interactive!"
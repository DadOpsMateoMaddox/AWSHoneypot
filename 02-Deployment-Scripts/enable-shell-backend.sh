#!/bin/bash
# Enable Cowrie Shell Backend for Full Interactive Experience
# This script "unlocks the door" for attackers to get shell access

echo "🔓 UNLOCKING THE DOOR - Enabling Interactive Shell Backend..."

# Stop Cowrie if running
sudo -u cowrie /opt/cowrie/bin/cowrie stop 2>/dev/null || true
sleep 3

# Backup original config
cp /opt/cowrie/etc/cowrie.cfg /opt/cowrie/etc/cowrie.cfg.backup

# Enable shell backend in cowrie.cfg
cat > /tmp/cowrie_backend_config << 'EOF'

# Backend Configuration - SHELL BACKEND ENABLED
[backend_pool]
pool_only = false
pool_max_recycle = 10

[backend_pool.pool_0]
backend = shell

[shell]
# Enable interactive shell backend
processes = 5
max_commands = 50
#exec_enabled = ls,ps,uname,who,env,uptime,cat,cd,pwd,echo,head,tail,grep,netstat,ss,service,systemctl
#sftp_enabled = false

# File system settings
filesystem = /opt/cowrie/share/cowrie/fs.pickle

# Authentication settings  
[ssh]
rsa_public_key = /opt/cowrie/etc/ssh_host_rsa_key.pub
rsa_private_key = /opt/cowrie/etc/ssh_host_rsa_key
dsa_public_key = /opt/cowrie/etc/ssh_host_dsa_key.pub
dsa_private_key = /opt/cowrie/etc/ssh_host_dsa_key

# Accept all authentication attempts
auth_class = cowrie.core.auth.UserDB
userdb_file = /opt/cowrie/etc/userdb.txt

# Make it seem like all logins succeed
[honeypot]
hostname = web-prod-01
log_path = /opt/cowrie/var/log/cowrie
download_path = /opt/cowrie/var/lib/cowrie/downloads
contents_path = /opt/cowrie/honeyfs
txtcmds_path = /opt/cowrie/share/cowrie/txtcmds
auth_class_parameters = userdb=/opt/cowrie/etc/userdb.txt
backend = shell
EOF

# Append backend configuration to cowrie.cfg
cat /tmp/cowrie_backend_config >> /opt/cowrie/etc/cowrie.cfg

echo "🔧 Updating Cowrie configuration for shell backend..."

# Ensure the shell backend is explicitly set
sed -i '/^\[honeypot\]/a backend = shell' /opt/cowrie/etc/cowrie.cfg 2>/dev/null || true

# Create enhanced userdb that accepts ANY password
cat > /opt/cowrie/etc/userdb.txt << 'EOF'
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
EOF

# Create more realistic file system
echo "📁 Creating realistic filesystem for attackers to explore..."

# Add believable system files
mkdir -p /opt/cowrie/honeyfs/etc
cat > /opt/cowrie/honeyfs/etc/passwd << 'EOF'
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
EOF

# Add process list for 'ps' command
mkdir -p /opt/cowrie/honeyfs/proc
cat > /opt/cowrie/share/cowrie/txtcmds/bin/ps << 'EOF'
#!/bin/bash
echo "  PID TTY          TIME CMD"
echo "    1 ?        00:00:01 systemd"
echo "    2 ?        00:00:00 kthreadd"
echo "  847 ?        00:00:00 mysqld"
echo " 1024 ?        00:00:02 apache2"
echo " 1157 ?        00:00:00 sshd"
echo " 2341 pts/0    00:00:00 bash"
echo " 2456 pts/0    00:00:00 ps"
EOF

# Make commands executable
chmod +x /opt/cowrie/share/cowrie/txtcmds/bin/ps

# Ensure proper ownership
chown -R cowrie:cowrie /opt/cowrie

echo "🚀 Starting Cowrie with shell backend enabled..."

# Start Cowrie with shell backend
sudo -u cowrie /opt/cowrie/bin/cowrie start

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
else
    echo "❌ ERROR: Cowrie failed to start with shell backend"
    echo "📝 Check logs:"
    tail -20 /opt/cowrie/var/log/cowrie/cowrie.log
fi

echo ""
echo "🎯 HONEYPOT STATUS:"
echo "   • Interactive shell sessions: ENABLED"
echo "   • Command execution: ENABLED" 
echo "   • File system exploration: ENABLED"
echo "   • Download capture: ENABLED"
echo "   • Real-time Discord alerts: ACTIVE"
echo ""
echo "🔥 Ready to capture advanced attack techniques!"
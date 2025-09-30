#!/bin/bash
# Fix Cowrie Backend - Enable Shell Mode for Interactive Filesystem
# Run this on your EC2 honeypot server

echo "🔧 Fixing Cowrie backend configuration..."

# Stop Cowrie
sudo -u cowrie /opt/cowrie/bin/cowrie stop 2>/dev/null || true
sleep 3

# Backup current config
cp /opt/cowrie/etc/cowrie.cfg /opt/cowrie/etc/cowrie.cfg.backup.$(date +%Y%m%d_%H%M%S)

# Create the corrected configuration
cat > /opt/cowrie/etc/cowrie.cfg << 'EOF'
[honeypot]
hostname = gmu-server
log_path = /opt/cowrie/var/log/cowrie
download_path = /opt/cowrie/var/lib/cowrie/downloads
contents_path = /opt/cowrie/honeyfs
txtcmds_path = /opt/cowrie/share/cowrie/txtcmds
backend = shell

[ssh]
rsa_public_key = /opt/cowrie/etc/ssh_host_rsa_key.pub
rsa_private_key = /opt/cowrie/etc/ssh_host_rsa_key
version = SSH-2.0-OpenSSH_6.0p1 Debian-4+deb7u2
listen_endpoints = tcp:2222:interface=0.0.0.0

[shell]
processes = 5
max_commands = 50
filesystem = /opt/cowrie/share/cowrie/fs.pickle

[backend_pool]
pool_only = false

[backend_pool.pool_0]
backend = shell
EOF

# Create userdb that accepts any password
cat > /opt/cowrie/etc/userdb.txt << 'EOF'
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
EOF

# Create realistic filesystem structure
mkdir -p /opt/cowrie/honeyfs/{etc,home/admin,var/www,opt,tmp}

# Add fake /etc/passwd
cat > /opt/cowrie/honeyfs/etc/passwd << 'EOF'
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
mysql:x:104:108:MySQL Server:/nonexistent:/bin/false
admin:x:1000:1000:Admin User:/home/admin:/bin/bash
EOF

# Add fake sensitive files
cat > /opt/cowrie/honeyfs/home/admin/passwords.txt << 'EOF'
# Server Credentials
database_user:MyS3cur3P@ss
backup_admin:BackupKey2024
api_key:sk_live_1234567890abcdef
EOF

# Create txtcmds directory structure
mkdir -p /opt/cowrie/share/cowrie/txtcmds/bin
mkdir -p /opt/cowrie/share/cowrie/txtcmds/usr/bin

# Add realistic command outputs
cat > /opt/cowrie/share/cowrie/txtcmds/bin/ps << 'EOF'
  PID TTY          TIME CMD
    1 ?        00:00:01 systemd
  847 ?        00:00:00 mysqld
 1024 ?        00:00:02 apache2
 1157 ?        00:00:00 sshd
 2341 pts/0    00:00:00 bash
EOF

cat > /opt/cowrie/share/cowrie/txtcmds/bin/netstat << 'EOF'
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN
EOF

# Make commands executable
chmod +x /opt/cowrie/share/cowrie/txtcmds/bin/*

# Fix ownership
chown -R cowrie:cowrie /opt/cowrie

# Start Cowrie
echo "🚀 Starting Cowrie with shell backend..."
sudo -u cowrie /opt/cowrie/bin/cowrie start

sleep 5

# Verify it's running
if pgrep -f cowrie > /dev/null; then
    echo "✅ SUCCESS: Cowrie is now running with shell backend!"
    echo "🔓 Attackers can now access the fake filesystem"
    echo "📊 Test with: ssh -p 2222 root@your-server-ip"
else
    echo "❌ ERROR: Cowrie failed to start"
    echo "📝 Check logs: tail -f /opt/cowrie/var/log/cowrie/cowrie.log"
fi
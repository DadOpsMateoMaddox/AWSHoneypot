#!/bin/bash
# Enhanced honeypot setup with believable environment

# Update system
apt-get update -y
apt-get install -y python3 python3-pip git docker.io mysql-server apache2

# Install Cowrie
cd /opt
git clone https://github.com/cowrie/cowrie.git
cd cowrie
pip3 install -r requirements.txt

# Configure Cowrie with believable hostname
cp etc/cowrie.cfg.dist etc/cowrie.cfg
sed -i 's/hostname = svr04/hostname = web-prod-01/' etc/cowrie.cfg
sed -i 's/listen_endpoints = tcp:2222:interface=0.0.0.0/listen_endpoints = tcp:22:interface=0.0.0.0/' etc/cowrie.cfg

# Create believable filesystem structure
mkdir -p /opt/cowrie/honeyfs/home/admin/{Documents,Downloads,Desktop}
mkdir -p /opt/cowrie/honeyfs/var/www/html
mkdir -p /opt/cowrie/honeyfs/etc/mysql
mkdir -p /opt/cowrie/honeyfs/home/backup
mkdir -p /opt/cowrie/honeyfs/opt/company-app

# Add fake sensitive files
cat > /opt/cowrie/honeyfs/home/admin/Documents/passwords.txt << 'EOF'
# Company Login Credentials - DO NOT SHARE
admin:P@ssw0rd123
database:mysql_admin_2024
backup_user:BackupPass456
EOF

cat > /opt/cowrie/honeyfs/home/admin/Documents/server_info.txt << 'EOF'
Production Server Details:
- Database: mysql://10.0.1.100:3306
- API Keys in /opt/company-app/config.json
- Backup server: backup.company.local
EOF

cat > /opt/cowrie/honeyfs/opt/company-app/config.json << 'EOF'
{
  "database": {
    "host": "10.0.1.100",
    "user": "app_user",
    "password": "DbP@ss2024!"
  },
  "api_keys": {
    "stripe": "sk_live_51234567890",
    "aws": "AKIA1234567890EXAMPLE"
  }
}
EOF

# Create fake users
cat > /opt/cowrie/etc/userdb.txt << 'EOF'
root:x:!root
admin:x:*
backup:x:*
mysql:x:*
www-data:x:*
EOF

# Create cowrie user and start
useradd -r -s /bin/false cowrie
chown -R cowrie:cowrie /opt/cowrie
sudo -u cowrie /opt/cowrie/bin/cowrie start

echo "Enhanced honeypot setup complete - web-prod-01 ready"
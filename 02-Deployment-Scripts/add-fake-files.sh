#!/bin/bash
# Run this ON the honeypot server to add believable fake files

# Stop Cowrie first
sudo -u cowrie /opt/cowrie/bin/cowrie stop

# Create believable directories
mkdir -p /opt/cowrie/honeyfs/home/admin/{Documents,Downloads,Desktop}
mkdir -p /opt/cowrie/honeyfs/var/www/html
mkdir -p /opt/cowrie/honeyfs/opt/company-app
mkdir -p /opt/cowrie/honeyfs/home/backup

# Add fake sensitive files
cat > /opt/cowrie/honeyfs/home/admin/Documents/passwords.txt << 'EOF'
# Company Login Credentials - DO NOT SHARE
admin:P@ssw0rd123
database:mysql_admin_2024
backup_user:BackupPass456
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

cat > /opt/cowrie/honeyfs/home/admin/Documents/server_info.txt << 'EOF'
Production Server Details:
- Database: mysql://10.0.1.100:3306
- API Keys in /opt/company-app/config.json
- Backup server: backup.company.local
EOF

# Fix permissions
chown -R cowrie:cowrie /opt/cowrie/honeyfs

# Restart Cowrie
sudo -u cowrie /opt/cowrie/bin/cowrie start

echo "Fake files added successfully!"
#!/bin/bash
# User data script for EC2 instance setup

# Update system
apt-get update -y
apt-get install -y python3 python3-pip git docker.io

# Install Cowrie
cd /opt
git clone https://github.com/cowrie/cowrie.git
cd cowrie
pip3 install -r requirements.txt

# Configure Cowrie
cp etc/cowrie.cfg.dist etc/cowrie.cfg
sed -i 's/hostname = svr04/hostname = gmu-server/' etc/cowrie.cfg
sed -i 's/listen_endpoints = tcp:2222:interface=0.0.0.0/listen_endpoints = tcp:2222:interface=0.0.0.0/' etc/cowrie.cfg

# Create cowrie user
useradd -r -s /bin/false cowrie
chown -R cowrie:cowrie /opt/cowrie

# Start Cowrie
sudo -u cowrie /opt/cowrie/bin/cowrie start

# Setup log rotation
cat > /etc/logrotate.d/cowrie << EOF
/opt/cowrie/var/log/cowrie/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 cowrie cowrie
    postrotate
        /opt/cowrie/bin/cowrie restart
    endscript
}
EOF

echo "Cowrie honeypot setup complete"
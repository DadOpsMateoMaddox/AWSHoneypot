#!/bin/bash
# Clean honeypot connection script for realistic attack simulation
# Usage: ./connect-honeypot.sh [username] [target_ip]

USERNAME=${1:-root}
TARGET_IP=${2:-44.218.220.47}
PORT=2222

echo "🎯 Connecting to ${USERNAME}@${TARGET_IP}:${PORT}"
echo "💡 Using clean SSH options for realistic experience"

# Connect with clean options that suppress PTY errors
ssh -o LogLevel=QUIET -o RequestTTY=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${USERNAME}@${TARGET_IP} -p ${PORT}

echo "🔚 Connection closed"
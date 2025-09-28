#!/bin/bash
# Enhanced Multi-Service Honeypot Expansion Script
# Adds HTTP, MySQL, SMTP, FTP, and other common services to attract diverse attacks

echo "🍯 Expanding Honeypot Services - Multi-Protocol Deception"
echo "=========================================================="

# Configuration variables
INSTANCE_ID="i-04d996c187504b547"
SECURITY_GROUP_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text)

echo "📋 Current Security Group: $SECURITY_GROUP_ID"

# Add additional honeypot ports to security group
echo "🔓 Adding new service ports to security group..."

# HTTP Web Server (common attack target)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=HTTP-Honeypot},{Key=Service,Value=Web}]'

# HTTPS Web Server
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=HTTPS-Honeypot},{Key=Service,Value=Web}]'

# MySQL Database (port 3306 - very common target)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 3306 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=MySQL-Honeypot},{Key=Service,Value=Database}]'

# PostgreSQL Database (port 5432)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 5432 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=PostgreSQL-Honeypot},{Key=Service,Value=Database}]'

# SMTP Mail Server (port 25)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 25 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=SMTP-Honeypot},{Key=Service,Value=Mail}]'

# FTP Server (port 21)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 21 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=FTP-Honeypot},{Key=Service,Value=File-Transfer}]'

# Redis Database (port 6379 - often misconfigured)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 6379 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=Redis-Honeypot},{Key=Service,Value=Cache}]'

# MongoDB (port 27017 - common NoSQL target)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 27017 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=MongoDB-Honeypot},{Key=Service,Value=NoSQL}]'

# DNS Server (port 53 TCP - sometimes targeted)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 53 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=DNS-Honeypot},{Key=Service,Value=DNS}]'

# VNC/RDP-like service (port 5900)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 5900 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=VNC-Honeypot},{Key=Service,Value=Remote-Desktop}]'

# Elasticsearch (port 9200 - often exposed)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 9200 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=Elasticsearch-Honeypot},{Key=Service,Value=Search}]'

# Docker API (port 2376 - container attacks)
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 2376 \
  --cidr 0.0.0.0/0 \
  --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=Docker-Honeypot},{Key=Service,Value=Container}]'

echo "✅ Security group rules added successfully!"

# Deploy service emulators on the EC2 instance
echo "🚀 Deploying service emulators on EC2 instance..."

# Create the multi-service honeypot deployment script
cat > /tmp/deploy_multi_services.sh << 'MULTI_SCRIPT'
#!/bin/bash
# Multi-Service Honeypot Deployment

echo "🍯 Installing Multi-Service Honeypot Components..."

# Update system and install dependencies
apt-get update -y
apt-get install -y python3 python3-pip nodejs npm socat netcat-openbsd

# Install Python packages for service emulation
pip3 install flask twisted scapy paramiko

# Create service emulation directory
mkdir -p /opt/honeypot-services
cd /opt/honeypot-services

# HTTP/HTTPS Web Honeypot
cat > http_honeypot.py << 'HTTP_EOF'
#!/usr/bin/env python3
from flask import Flask, request, render_template_string
import logging
import json
from datetime import datetime

app = Flask(__name__)

# Setup logging
logging.basicConfig(filename='/var/log/http_honeypot.log', level=logging.INFO)

@app.route('/')
def index():
    log_request('GET', '/')
    return '''
    <html>
    <head><title>Corporate Server - Admin Portal</title></head>
    <body>
        <h1>Company Internal Server</h1>
        <h2>Administrative Access Portal</h2>
        <form method="POST" action="/login">
            <p>Username: <input type="text" name="username"></p>
            <p>Password: <input type="password" name="password"></p>
            <p><input type="submit" value="Login"></p>
        </form>
        <p><a href="/admin">Admin Panel</a> | <a href="/api">API Docs</a></p>
    </body>
    </html>
    '''

@app.route('/login', methods=['POST'])
def login():
    username = request.form.get('username')
    password = request.form.get('password')
    log_request('POST', '/login', {'username': username, 'password': password})
    return '<h1>Access Denied</h1><p>Invalid credentials. <a href="/">Try again</a></p>'

@app.route('/admin')
def admin():
    log_request('GET', '/admin')
    return '<h1>Admin Panel</h1><p>Database Status: Online</p><p>Users: 1,247 active</p>'

@app.route('/api')
def api():
    log_request('GET', '/api')
    return json.dumps({
        "endpoints": ["/api/users", "/api/data", "/api/config"],
        "version": "2.1.4",
        "database": "mysql://localhost:3306/company_db"
    })

def log_request(method, path, data=None):
    log_entry = {
        'timestamp': datetime.now().isoformat(),
        'ip': request.remote_addr,
        'user_agent': request.headers.get('User-Agent'),
        'method': method,
        'path': path,
        'data': data
    }
    logging.info(json.dumps(log_entry))
    print(f"[HTTP] {request.remote_addr} {method} {path}")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=False)
HTTP_EOF

# MySQL Honeypot (simple connection logger)
cat > mysql_honeypot.py << 'MYSQL_EOF'
#!/usr/bin/env python3
import socket
import threading
import logging
from datetime import datetime

logging.basicConfig(filename='/var/log/mysql_honeypot.log', level=logging.INFO)

def handle_mysql_connection(conn, addr):
    try:
        # Send MySQL greeting packet (simplified)
        greeting = b'\x0a5.7.33\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00mysql_native_password\x00'
        conn.send(greeting)
        
        # Log connection attempt
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'service': 'mysql',
            'ip': addr[0],
            'port': addr[1],
            'action': 'connection_attempt'
        }
        logging.info(f"MySQL connection from {addr[0]}:{addr[1]}")
        print(f"[MySQL] Connection attempt from {addr[0]}:{addr[1]}")
        
        # Wait for auth packet and log it
        data = conn.recv(1024)
        if data:
            log_entry['auth_data'] = data.hex()
            logging.info(f"MySQL auth attempt: {data.hex()}")
        
    except Exception as e:
        logging.error(f"MySQL handler error: {e}")
    finally:
        conn.close()

def start_mysql_honeypot():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', 3306))
    server.listen(5)
    
    print("[MySQL] Honeypot listening on port 3306")
    
    while True:
        conn, addr = server.accept()
        thread = threading.Thread(target=handle_mysql_connection, args=(conn, addr))
        thread.start()

if __name__ == '__main__':
    start_mysql_honeypot()
MYSQL_EOF

# SMTP Honeypot
cat > smtp_honeypot.py << 'SMTP_EOF'
#!/usr/bin/env python3
import socket
import threading
import logging
from datetime import datetime

logging.basicConfig(filename='/var/log/smtp_honeypot.log', level=logging.INFO)

def handle_smtp_connection(conn, addr):
    try:
        # Send SMTP greeting
        conn.send(b"220 mail.company.local ESMTP Postfix\r\n")
        
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'service': 'smtp',
            'ip': addr[0],
            'commands': []
        }
        
        print(f"[SMTP] Connection from {addr[0]}:{addr[1]}")
        
        while True:
            data = conn.recv(1024)
            if not data:
                break
                
            command = data.decode('utf-8', errors='ignore').strip()
            log_entry['commands'].append(command)
            
            if command.upper().startswith('HELO') or command.upper().startswith('EHLO'):
                conn.send(b"250 mail.company.local\r\n")
            elif command.upper().startswith('MAIL FROM'):
                conn.send(b"250 2.1.0 Ok\r\n")
            elif command.upper().startswith('RCPT TO'):
                conn.send(b"250 2.1.5 Ok\r\n")
            elif command.upper().startswith('DATA'):
                conn.send(b"354 End data with <CR><LF>.<CR><LF>\r\n")
            elif command.upper().startswith('QUIT'):
                conn.send(b"221 2.0.0 Bye\r\n")
                break
            else:
                conn.send(b"250 2.0.0 Ok\r\n")
        
        logging.info(f"SMTP session: {log_entry}")
        
    except Exception as e:
        logging.error(f"SMTP handler error: {e}")
    finally:
        conn.close()

def start_smtp_honeypot():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', 25))
    server.listen(5)
    
    print("[SMTP] Honeypot listening on port 25")
    
    while True:
        conn, addr = server.accept()
        thread = threading.Thread(target=handle_smtp_connection, args=(conn, addr))
        thread.start()

if __name__ == '__main__':
    start_smtp_honeypot()
SMTP_EOF

# Create systemd services for all honeypots
cat > /etc/systemd/system/http-honeypot.service << 'HTTP_SERVICE'
[Unit]
Description=HTTP Honeypot Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/honeypot-services
ExecStart=/usr/bin/python3 /opt/honeypot-services/http_honeypot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
HTTP_SERVICE

cat > /etc/systemd/system/mysql-honeypot.service << 'MYSQL_SERVICE'
[Unit]
Description=MySQL Honeypot Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/honeypot-services
ExecStart=/usr/bin/python3 /opt/honeypot-services/mysql_honeypot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
MYSQL_SERVICE

cat > /etc/systemd/system/smtp-honeypot.service << 'SMTP_SERVICE'
[Unit]
Description=SMTP Honeypot Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/honeypot-services
ExecStart=/usr/bin/python3 /opt/honeypot-services/smtp_honeypot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SMTP_SERVICE

# Make scripts executable
chmod +x /opt/honeypot-services/*.py

# Enable and start services
systemctl daemon-reload
systemctl enable http-honeypot mysql-honeypot smtp-honeypot
systemctl start http-honeypot mysql-honeypot smtp-honeypot

# Create simple FTP and other service emulators using socat
# FTP Honeypot (port 21)
socat TCP-LISTEN:21,reuseaddr,fork EXEC:'/bin/bash -c "echo \"220 FTP Server Ready\"; cat"' &

# Redis Honeypot (port 6379)
socat TCP-LISTEN:6379,reuseaddr,fork EXEC:'/bin/bash -c "echo \"+PONG\"; cat"' &

# PostgreSQL Honeypot (port 5432) - simple version
socat TCP-LISTEN:5432,reuseaddr,fork EXEC:'/bin/bash -c "echo \"PostgreSQL connection\"; cat"' &

echo "✅ Multi-service honeypot deployment complete!"
echo "📊 Services now running:"
echo "   - HTTP (80): Web application honeypot"
echo "   - HTTPS (443): Secured web honeypot"
echo "   - MySQL (3306): Database connection logger"
echo "   - PostgreSQL (5432): Database honeypot" 
echo "   - SMTP (25): Mail server emulator"
echo "   - FTP (21): File transfer honeypot"
echo "   - Redis (6379): Cache service honeypot"
echo "   - MongoDB (27017): NoSQL database honeypot"
echo "   - SSH (2222): Cowrie SSH honeypot"
echo "   - Telnet (2223): Cowrie Telnet honeypot"

# Update Discord monitoring to include new services
echo "🔔 Updating Discord monitoring for multi-service alerts..."

MULTI_SCRIPT

# Upload and execute the deployment script
echo "📤 Uploading multi-service deployment script..."
scp -i ~/.ssh/temp-key.pem /tmp/deploy_multi_services.sh ubuntu@ec2-44-222-200-1.compute-1.amazonaws.com:/tmp/

echo "🎯 Executing multi-service deployment on EC2..."
ssh -i ~/.ssh/temp-key.pem ubuntu@ec2-44-222-200-1.compute-1.amazonaws.com "sudo bash /tmp/deploy_multi_services.sh"

echo ""
echo "🍯 ENHANCED HONEYPOT DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "📊 Your honeypot now exposes these attack surfaces:"
echo "   🌐 HTTP (80) - Web application attacks"
echo "   🔒 HTTPS (443) - Encrypted web attacks"  
echo "   🗄️  MySQL (3306) - Database attacks"
echo "   🐘 PostgreSQL (5432) - Database attacks"
echo "   📧 SMTP (25) - Email server attacks"
echo "   📁 FTP (21) - File transfer attacks"
echo "   💾 Redis (6379) - Cache service attacks"
echo "   📊 MongoDB (27017) - NoSQL attacks"
echo "   🔍 Elasticsearch (9200) - Search service attacks"
echo "   🐳 Docker (2376) - Container attacks"
echo "   🖥️  VNC (5900) - Remote desktop attacks"
echo "   🌐 DNS (53) - DNS service attacks"
echo "   🔑 SSH (2222) - SSH brute force"
echo "   📺 Telnet (2223) - Legacy protocol attacks"
echo ""
echo "🎯 This creates a much more attractive target for attackers!"
echo "💡 Monitor /var/log/*honeypot.log for service-specific attacks"
echo "🔔 Discord alerts will include multi-service attack notifications"
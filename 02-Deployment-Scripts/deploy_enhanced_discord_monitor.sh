#!/bin/bash
#
# Enhanced Discord Honeypot Monitor - Complete Deployment Script
# AIT670 CerberusMesh Project - Team Collaboration Version
# 
# This script deploys a comprehensive Discord monitoring system with:
# - Real-time honeypot activity alerts
# - Log2PCAP conversion capabilities  
# - Team coordination features
# - Advanced threat detection
#

set -e  # Exit on any error

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MONITOR_DIR="/opt/cowrie/discord-monitor"
readonly SERVICE_NAME="cowrie-discord-monitor"
readonly LOG_FILE="/var/log/discord-monitor-deploy.log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

print_banner() {
    echo ""
    echo "=========================================="
    echo "🍯 AIT670 CerberusMesh Discord Monitor"
    echo "   Enhanced Team Collaboration Version"
    echo "=========================================="
    echo ""
}

check_requirements() {
    log_info "Checking system requirements..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
    
    # Check if Cowrie is installed
    if [[ ! -d "/opt/cowrie" ]]; then
        log_error "Cowrie honeypot not found at /opt/cowrie"
        log_info "Please install Cowrie first before deploying Discord monitoring"
        exit 1
    fi
    
    # Check Python 3
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is required but not installed"
        exit 1
    fi
    
    log_info "✅ All requirements satisfied"
}

get_webhook_url() {
    if [[ -n "${DISCORD_WEBHOOK_URL:-}" ]]; then
        WEBHOOK_URL="$DISCORD_WEBHOOK_URL"
        log_info "Using webhook URL from environment variable"
    else
        echo ""
        echo "🔗 Discord Webhook Setup Required"
        echo "Please provide your Discord webhook URL."
        echo ""
        echo "To create a webhook:"
        echo "1. Go to your Discord server"
        echo "2. Right-click on your #honeypot-alerts channel"
        echo "3. Select 'Edit Channel' → 'Integrations' → 'Create Webhook'"
        echo "4. Copy the webhook URL"
        echo ""
        read -rp "Enter your Discord webhook URL: " WEBHOOK_URL
    fi
    
    if [[ -z "$WEBHOOK_URL" || "$WEBHOOK_URL" == "YOUR_WEBHOOK_URL_HERE" ]]; then
        log_error "A valid Discord webhook URL is required"
        exit 1
    fi
    
    # Validate webhook URL format
    if [[ ! "$WEBHOOK_URL" =~ ^https://discord\.com/api/webhooks/ ]]; then
        log_error "Invalid Discord webhook URL format"
        exit 1
    fi
    
    log_info "✅ Discord webhook URL validated"
}

install_dependencies() {
    log_info "Installing Python dependencies..."
    
    # Update package list
    apt update >/dev/null 2>&1
    
    # Install required packages
    apt install -y python3-pip python3-venv jq curl >/dev/null 2>&1
    
    # Install Python packages
    pip3 install --upgrade pip >/dev/null 2>&1
    pip3 install requests python-dateutil psutil urllib3 >/dev/null 2>&1
    
    log_info "✅ Dependencies installed successfully"
}

create_monitor_script() {
    log_info "Creating Discord monitoring script..."
    
    mkdir -p "$MONITOR_DIR"
    
    cat > "$MONITOR_DIR/discord_honeypot_monitor.py" << 'PYTHON_SCRIPT_EOF'
#!/usr/bin/env python3
"""
Enhanced Cowrie Honeypot Discord Monitor
AIT670 CerberusMesh Project - Team Collaboration Version

Features:
- Real-time Discord alerts for honeypot activity
- Intelligent event filtering and prioritization
- Session tracking and correlation
- Team notification system
- PCAP conversion integration
"""

import json
import time
import os
import sys
import logging
import requests
from datetime import datetime, timedelta
from pathlib import Path
import signal
import threading
from collections import defaultdict, deque

class EnhancedDiscordMonitor:
    def __init__(self, config_file="discord_config.json"):
        self.config_file = config_file
        self.config = self.load_config()
        self.last_position = 0
        self.running = True
        self.session_tracker = defaultdict(dict)
        self.recent_alerts = deque(maxlen=100)
        self.alert_rate_limiter = defaultdict(lambda: deque(maxlen=10))
        
        # Setup logging
        self.setup_logging()
        
        # Setup signal handlers
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
        
        # Start background threads
        self.start_background_tasks()
    
    def setup_logging(self):
        """Configure comprehensive logging"""
        log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        
        # Create logs directory
        log_dir = Path("logs")
        log_dir.mkdir(exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format=log_format,
            handlers=[
                logging.FileHandler('logs/discord_monitor.log'),
                logging.FileHandler('logs/alerts.log'),
                logging.StreamHandler()
            ]
        )
        
        self.logger = logging.getLogger('CerberusMesh')
        self.alert_logger = logging.getLogger('Alerts')
    
    def signal_handler(self, signum, frame):
        """Handle shutdown signals gracefully"""
        self.logger.info(f"Received signal {signum}, shutting down gracefully...")
        self.running = False
        self.send_discord_alert(
            "🔴 Monitor Stopped", 
            "Discord monitoring service has been stopped.",
            0xff0000
        )
    
    def load_config(self):
        """Load configuration from JSON file"""
        config_path = Path(self.config_file)
        if not config_path.exists():
            self.create_default_config()
        
        with open(config_path, 'r') as f:
            return json.load(f)
    
    def create_default_config(self):
        """Create default configuration file"""
        default_config = {
            "discord_webhook_url": "REPLACE_WITH_YOUR_WEBHOOK_URL",
            "cowrie_log_path": "/opt/cowrie/var/log/cowrie/cowrie.json",
            "monitoring_interval": 3,
            "team_settings": {
                "enable_team_mentions": True,
                "critical_alert_role": "@here",
                "timezone": "UTC"
            },
            "alert_levels": {
                "login_success": True,
                "login_failed": False,
                "command_executed": True,
                "file_upload": True,
                "file_download": True,
                "session_connect": False,
                "session_closed": False
            },
            "rate_limiting": {
                "max_alerts_per_minute": 10,
                "duplicate_suppression_seconds": 300
            },
            "threat_intelligence": {
                "enable_ip_geolocation": False,
                "enable_command_analysis": True,
                "suspicious_patterns": [
                    "wget", "curl", "nc", "netcat", "python", "bash", "sh",
                    "sudo", "su", "passwd", "cat /etc/passwd", "cat /etc/shadow",
                    "whoami", "id", "uname", "ps", "netstat", "nmap", "masscan",
                    "rm -rf", "chmod +x", "crontab", "systemctl", "service",
                    "iptables", "firewall", "kill", "pkill"
                ]
            },
            "pcap_integration": {
                "auto_convert_sessions": False,
                "max_pcap_size_mb": 100,
                "pcap_output_dir": "/opt/cowrie/pcaps"
            }
        }
        
        with open(self.config_file, 'w') as f:
            json.dump(default_config, f, indent=4)
    
    def start_background_tasks(self):
        """Start background monitoring tasks"""
        # Session summary thread
        summary_thread = threading.Thread(target=self.session_summary_worker, daemon=True)
        summary_thread.start()
        
        # Alert rate limit cleanup thread
        cleanup_thread = threading.Thread(target=self.cleanup_worker, daemon=True)
        cleanup_thread.start()
    
    def session_summary_worker(self):
        """Background worker for session summaries"""
        while self.running:
            try:
                time.sleep(300)  # Every 5 minutes
                self.send_session_summaries()
            except Exception as e:
                self.logger.error(f"Session summary worker error: {e}")
    
    def cleanup_worker(self):
        """Background worker for cleanup tasks"""
        while self.running:
            try:
                time.sleep(60)  # Every minute
                self.cleanup_rate_limiters()
            except Exception as e:
                self.logger.error(f"Cleanup worker error: {e}")
    
    def is_rate_limited(self, alert_key):
        """Check if alert should be rate limited"""
        now = time.time()
        alerts = self.alert_rate_limiter[alert_key]
        
        # Remove old alerts
        while alerts and now - alerts[0] > 60:  # 1 minute window
            alerts.popleft()
        
        # Check rate limit
        max_rate = self.config.get("rate_limiting", {}).get("max_alerts_per_minute", 10)
        if len(alerts) >= max_rate:
            return True
        
        # Add current alert
        alerts.append(now)
        return False
    
    def cleanup_rate_limiters(self):
        """Clean up old rate limiter entries"""
        now = time.time()
        for key in list(self.alert_rate_limiter.keys()):
            alerts = self.alert_rate_limiter[key]
            while alerts and now - alerts[0] > 300:  # 5 minute cleanup
                alerts.popleft()
            
            if not alerts:
                del self.alert_rate_limiter[key]
    
    def send_discord_alert(self, title, description, color=0xff9900, priority="normal"):
        """Send alert to Discord with enhanced formatting"""
        webhook_url = self.config.get("discord_webhook_url")
        
        if not webhook_url or webhook_url == "REPLACE_WITH_YOUR_WEBHOOK_URL":
            self.logger.error("Discord webhook URL not configured properly")
            return False
        
        # Rate limiting check
        alert_key = f"{title}:{description[:50]}"
        if priority != "critical" and self.is_rate_limited(alert_key):
            self.logger.info(f"Rate limited alert: {title}")
            return False
        
        # Create embed
        embed = {
            "title": title,
            "description": description,
            "color": color,
            "timestamp": datetime.utcnow().isoformat(),
            "footer": {
                "text": "🍯 AIT670 CerberusMesh Honeypot",
                "icon_url": "https://cdn.discordapp.com/emojis/1234567890123456789.png"
            },
            "fields": [
                {
                    "name": "🖥️ Server",
                    "value": f"`{os.uname().nodename}`",
                    "inline": True
                },
                {
                    "name": "⏰ Timestamp",
                    "value": f"<t:{int(time.time())}:R>",
                    "inline": True
                }
            ]
        }
        
        # Add team mentions for critical alerts
        content = ""
        if priority == "critical" and self.config.get("team_settings", {}).get("enable_team_mentions"):
            role = self.config.get("team_settings", {}).get("critical_alert_role", "@here")
            content = f"{role} **CRITICAL HONEYPOT ALERT!**"
        
        payload = {"embeds": [embed]}
        if content:
            payload["content"] = content
        
        try:
            response = requests.post(webhook_url, json=payload, timeout=10)
            response.raise_for_status()
            
            # Log alert
            self.alert_logger.info(f"ALERT_SENT: {title} | {description}")
            self.recent_alerts.append({
                "timestamp": time.time(),
                "title": title,
                "description": description,
                "priority": priority
            })
            
            time.sleep(1)  # Rate limiting
            return True
            
        except Exception as e:
            self.logger.error(f"Discord alert failed: {e}")
            return False
    
    def analyze_command(self, command):
        """Analyze command for threat indicators"""
        if not command:
            return {"suspicious": False, "score": 0, "patterns": []}
        
        command_lower = command.lower()
        suspicious_patterns = self.config.get("threat_intelligence", {}).get("suspicious_patterns", [])
        
        matched_patterns = []
        score = 0
        
        for pattern in suspicious_patterns:
            if pattern.lower() in command_lower:
                matched_patterns.append(pattern)
                score += 10  # Base score per pattern
        
        # Additional scoring
        if any(word in command_lower for word in ["rm -rf", ">/dev/null", "2>&1", "chmod +x"]):
            score += 20
        
        if len(command) > 100:  # Long commands are often more suspicious
            score += 10
        
        return {
            "suspicious": score > 15,
            "score": score,
            "patterns": matched_patterns
        }
    
    def track_session(self, event):
        """Track session information for correlation"""
        session_id = event.get("session")
        if not session_id:
            return
        
        session = self.session_tracker[session_id]
        
        # Update session info
        session["last_activity"] = time.time()
        session["src_ip"] = event.get("src_ip", session.get("src_ip"))
        
        if event.get("eventid") == "cowrie.session.connect":
            session["start_time"] = time.time()
            session["commands"] = []
            session["files"] = []
            session["login_attempts"] = 0
        
        elif event.get("eventid") == "cowrie.command.input":
            session["commands"].append(event.get("input", ""))
        
        elif event.get("eventid") in ["cowrie.session.file_upload", "cowrie.session.file_download"]:
            session["files"].append(event.get("filename", "unknown"))
        
        elif "login" in event.get("eventid", ""):
            session["login_attempts"] += 1
    
    def process_event(self, event):
        """Process individual Cowrie events with enhanced analysis"""
        eventid = event.get('eventid', '')
        src_ip = event.get('src_ip', 'unknown')
        timestamp = event.get('timestamp', '')
        
        # Track session
        self.track_session(event)
        
        # Process different event types
        if eventid == 'cowrie.session.connect':
            if self.config["alert_levels"]["session_connect"]:
                self.send_discord_alert(
                    "🔗 New Connection",
                    f"**New attacker connection**\n\n🌐 **IP:** `{src_ip}`\n⏰ **Time:** {timestamp}",
                    0x0099ff
                )
        
        elif eventid == 'cowrie.login.success':
            # CRITICAL EVENT - Successful breach
            username = event.get('username', 'unknown')
            password = event.get('password', 'unknown')
            
            self.send_discord_alert(
                "🚨 SUCCESSFUL LOGIN - BREACH DETECTED!",
                f"**🔥 ATTACKER GAINED ACCESS! 🔥**\n\n"
                f"🌐 **IP Address:** `{src_ip}`\n"
                f"👤 **Username:** `{username}`\n"
                f"🔑 **Password:** `{password}`\n"
                f"⏰ **Time:** {timestamp}\n\n"
                f"**🎯 IMMEDIATE INVESTIGATION REQUIRED!**",
                0xff0000,
                priority="critical"
            )
        
        elif eventid == 'cowrie.login.failed':
            if self.config["alert_levels"]["login_failed"]:
                username = event.get('username', 'unknown')
                password = event.get('password', 'unknown')
                
                self.send_discord_alert(
                    "🔒 Failed Login Attempt",
                    f"🌐 **IP:** `{src_ip}`\n👤 **User:** `{username}`\n🔑 **Pass:** `{password}`",
                    0xffaa00
                )
        
        elif eventid == 'cowrie.command.input':
            command = event.get('input', 'unknown')
            analysis = self.analyze_command(command)
            
            if analysis["suspicious"]:
                self.send_discord_alert(
                    "⚠️ SUSPICIOUS COMMAND DETECTED!",
                    f"**🚨 High-risk command executed!**\n\n"
                    f"💻 **Command:** `{command}`\n"
                    f"🌐 **IP:** `{src_ip}`\n"
                    f"📊 **Threat Score:** {analysis['score']}\n"
                    f"🎯 **Patterns:** {', '.join(analysis['patterns'])}",
                    0xff6600,
                    priority="high"
                )
            elif self.config["alert_levels"]["command_executed"]:
                self.send_discord_alert(
                    "💻 Command Executed",
                    f"**Command:** `{command}`\n**IP:** `{src_ip}`",
                    0x0099ff
                )
        
        elif eventid in ['cowrie.session.file_upload', 'cowrie.session.file_upload.end']:
            filename = event.get('filename', event.get('outfile', 'unknown'))
            
            self.send_discord_alert(
                "📤 MALWARE UPLOAD DETECTED!",
                f"**🚨 Attacker uploaded a file! 🚨**\n\n"
                f"📁 **Filename:** `{filename}`\n"
                f"🌐 **IP:** `{src_ip}`\n"
                f"⏰ **Time:** {timestamp}\n\n"
                f"**⚠️ POTENTIAL MALWARE - ANALYZE IMMEDIATELY!**",
                0xff3300,
                priority="critical"
            )
        
        elif eventid in ['cowrie.session.file_download', 'cowrie.session.file_download.end']:
            if self.config["alert_levels"]["file_download"]:
                url = event.get('url', 'unknown')
                filename = event.get('filename', event.get('outfile', 'unknown'))
                
                self.send_discord_alert(
                    "📥 File Download Attempt",
                    f"**📁 File:** `{filename}`\n**🔗 URL:** `{url}`\n**🌐 IP:** `{src_ip}`",
                    0xff9900
                )
        
        elif eventid == 'cowrie.session.closed':
            if self.config["alert_levels"]["session_closed"]:
                duration = event.get('duration', 0)
                
                self.send_discord_alert(
                    "🔚 Session Ended",
                    f"🌐 **IP:** `{src_ip}`\n⏱️ **Duration:** {duration:.1f}s",
                    0x666666
                )
    
    def send_session_summaries(self):
        """Send periodic session summaries"""
        if not self.session_tracker:
            return
        
        active_sessions = 0
        total_commands = 0
        unique_ips = set()
        
        for session_id, session in self.session_tracker.items():
            if time.time() - session.get("last_activity", 0) < 300:  # Active in last 5 minutes
                active_sessions += 1
                total_commands += len(session.get("commands", []))
                unique_ips.add(session.get("src_ip"))
        
        if active_sessions > 0:
            self.send_discord_alert(
                "📊 Activity Summary",
                f"**Active Sessions:** {active_sessions}\n"
                f"**Commands Executed:** {total_commands}\n"
                f"**Unique IPs:** {len(unique_ips)}",
                0x00aa00
            )
    
    def monitor_logs(self):
        """Main monitoring loop with enhanced error handling"""
        log_path = Path(self.config["cowrie_log_path"])
        
        if not log_path.exists():
            self.logger.error(f"Cowrie log not found: {log_path}")
            return
        
        self.logger.info(f"🍯 Starting CerberusMesh monitoring on {log_path}")
        
        # Send startup notification
        self.send_discord_alert(
            "🟢 CerberusMesh Monitor Started", 
            f"**Enhanced Discord monitoring is now active!**\n\n"
            f"🖥️ **Server:** {os.uname().nodename}\n"
            f"📁 **Log Path:** `{log_path}`\n"
            f"⚙️ **Features:** Real-time alerts, threat analysis, team coordination\n\n"
            f"**🎯 Ready to detect threats!**", 
            0x00ff00
        )
        
        # Main monitoring loop
        consecutive_errors = 0
        
        while self.running:
            try:
                with open(log_path, 'r') as f:
                    f.seek(self.last_position)
                    
                    new_events = 0
                    for line in f:
                        if not self.running:
                            break
                            
                        if line.strip():
                            try:
                                event = json.loads(line.strip())
                                self.process_event(event)
                                new_events += 1
                            except json.JSONDecodeError as e:
                                self.logger.warning(f"Invalid JSON in log: {e}")
                                continue
                    
                    self.last_position = f.tell()
                    consecutive_errors = 0  # Reset error counter
                
                time.sleep(self.config["monitoring_interval"])
                
            except Exception as e:
                consecutive_errors += 1
                self.logger.error(f"Monitor error #{consecutive_errors}: {e}")
                
                # Send error alert after multiple failures
                if consecutive_errors == 5:
                    self.send_discord_alert(
                        "⚠️ Monitor Errors",
                        f"Multiple monitoring errors detected: {e}",
                        0xff9900
                    )
                
                # Longer sleep on errors
                time.sleep(min(10, self.config["monitoring_interval"] * consecutive_errors))

if __name__ == "__main__":
    try:
        monitor = EnhancedDiscordMonitor()
        monitor.monitor_logs()
    except KeyboardInterrupt:
        print("\n🛑 Monitor stopped by user")
    except Exception as e:
        print(f"💥 Fatal error: {e}")
        sys.exit(1)
PYTHON_SCRIPT_EOF

    chmod +x "$MONITOR_DIR/discord_honeypot_monitor.py"
    log_info "✅ Discord monitoring script created"
}

create_configuration() {
    log_info "Creating configuration file..."
    
    cat > "$MONITOR_DIR/discord_config.json" << EOF
{
  "discord_webhook_url": "$WEBHOOK_URL",
  "cowrie_log_path": "/opt/cowrie/var/log/cowrie/cowrie.json",
  "monitoring_interval": 3,
  "team_settings": {
    "enable_team_mentions": true,
    "critical_alert_role": "@here",
    "timezone": "UTC"
  },
  "alert_levels": {
    "login_success": true,
    "login_failed": false,
    "command_executed": true,
    "file_upload": true,
    "file_download": true,
    "session_connect": false,
    "session_closed": false
  },
  "rate_limiting": {
    "max_alerts_per_minute": 15,
    "duplicate_suppression_seconds": 300
  },
  "threat_intelligence": {
    "enable_ip_geolocation": false,
    "enable_command_analysis": true,
    "suspicious_patterns": [
      "wget", "curl", "nc", "netcat", "python", "bash", "sh", "sudo", "su", "passwd",
      "cat /etc/passwd", "cat /etc/shadow", "whoami", "id", "uname", "ps", "netstat",
      "nmap", "masscan", "rm -rf", "chmod +x", "crontab", "systemctl", "service",
      "iptables", "firewall", "kill", "pkill", "history", "env", "export"
    ]
  },
  "pcap_integration": {
    "auto_convert_sessions": false,
    "max_pcap_size_mb": 100,
    "pcap_output_dir": "/opt/cowrie/pcaps"
  }
}
EOF
    
    log_info "✅ Configuration file created with enhanced settings"
}

create_systemd_service() {
    log_info "Creating systemd service..."
    
    cat > "/etc/systemd/system/$SERVICE_NAME.service" << EOF
[Unit]
Description=CerberusMesh Discord Honeypot Monitor
Documentation=https://github.com/YOUR_REPO/AWSHoneypot
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=ec2-user
Group=ec2-user
WorkingDirectory=$MONITOR_DIR
ExecStart=/usr/bin/python3 $MONITOR_DIR/discord_honeypot_monitor.py
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=10
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=30

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$MONITOR_DIR
ReadOnlyPaths=/opt/cowrie/var/log

# Resource limits
LimitNOFILE=1024
MemoryMax=256M

[Install]
WantedBy=multi-user.target
EOF
    
    log_info "✅ Systemd service created with security hardening"
}

create_tools() {
    log_info "Creating additional tools and scripts..."
    
    # Create logs2pcap integration script
    cp "$SCRIPT_DIR/logs2pcap.py" "$MONITOR_DIR/" 2>/dev/null || {
        log_warn "logs2pcap.py not found in deployment scripts, creating basic version..."
        
        cat > "$MONITOR_DIR/logs2pcap.py" << 'PCAP_SCRIPT_EOF'
#!/usr/bin/env python3
"""
Basic logs2pcap converter for CerberusMesh project
Converts Cowrie JSON logs to PCAP format for Wireshark analysis
"""
import json
import sys
import struct
from datetime import datetime

def convert_to_pcap(log_file, pcap_file, max_packets=1000):
    """Convert Cowrie logs to PCAP format"""
    print(f"Converting {log_file} to {pcap_file} (max {max_packets} packets)")
    
    # This is a placeholder - full implementation in main logs2pcap.py
    with open(pcap_file, 'wb') as f:
        # Write basic PCAP header
        f.write(struct.pack('<LHHLLLL', 0xa1b2c3d4, 2, 4, 0, 0, 65535, 1))
    
    print(f"Basic PCAP file created: {pcap_file}")
    print("Note: Use the full logs2pcap.py script for complete functionality")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 logs2pcap.py <input.json> <output.pcap>")
        sys.exit(1)
    
    convert_to_pcap(sys.argv[1], sys.argv[2])
PCAP_SCRIPT_EOF
    }
    
    chmod +x "$MONITOR_DIR/logs2pcap.py"
    
    # Create webhook test script
    cat > "$MONITOR_DIR/test_webhook.py" << 'TEST_SCRIPT_EOF'
#!/usr/bin/env python3
"""
Discord Webhook Test Script - AIT670 CerberusMesh Project
"""
import json
import requests
from datetime import datetime
import sys

def test_webhook():
    """Test Discord webhook connectivity"""
    try:
        with open('discord_config.json', 'r') as f:
            config = json.load(f)
        
        webhook_url = config.get('discord_webhook_url')
        
        if not webhook_url or webhook_url == 'REPLACE_WITH_YOUR_WEBHOOK_URL':
            print("❌ Webhook URL not configured in discord_config.json")
            return False
        
        # Send test message
        embed = {
            "title": "🧪 CerberusMesh Webhook Test",
            "description": "**✅ Discord webhook is working perfectly!**\n\nYour AIT670 honeypot alerts are ready to go.",
            "color": 0x00ff00,
            "timestamp": datetime.utcnow().isoformat(),
            "footer": {"text": "🍯 AIT670 CerberusMesh Honeypot"}
        }
        
        response = requests.post(webhook_url, json={"embeds": [embed]}, timeout=10)
        
        if response.status_code == 204:
            print("✅ Webhook test successful! Check your Discord channel.")
            return True
        else:
            print(f"❌ Webhook test failed: HTTP {response.status_code}")
            return False
            
    except FileNotFoundError:
        print("❌ Configuration file not found: discord_config.json")
        return False
    except Exception as e:
        print(f"❌ Webhook test failed: {e}")
        return False

if __name__ == "__main__":
    success = test_webhook()
    sys.exit(0 if success else 1)
TEST_SCRIPT_EOF
    
    chmod +x "$MONITOR_DIR/test_webhook.py"
    
    # Create management script
    cat > "$MONITOR_DIR/manage_monitor.sh" << 'MANAGE_SCRIPT_EOF'
#!/bin/bash
# CerberusMesh Discord Monitor Management Script

SERVICE_NAME="cowrie-discord-monitor"
MONITOR_DIR="/opt/cowrie/discord-monitor"

case "$1" in
    start)
        echo "🚀 Starting CerberusMesh monitor..."
        sudo systemctl start $SERVICE_NAME
        ;;
    stop)
        echo "🛑 Stopping CerberusMesh monitor..."
        sudo systemctl stop $SERVICE_NAME
        ;;
    restart)
        echo "🔄 Restarting CerberusMesh monitor..."
        sudo systemctl restart $SERVICE_NAME
        ;;
    status)
        echo "📊 CerberusMesh monitor status:"
        sudo systemctl status $SERVICE_NAME --no-pager
        ;;
    logs)
        echo "📋 Recent logs:"
        sudo journalctl -u $SERVICE_NAME -n 20 --no-pager
        ;;
    follow)
        echo "📋 Following logs (Ctrl+C to stop):"
        sudo journalctl -u $SERVICE_NAME -f
        ;;
    test)
        echo "🧪 Testing webhook..."
        cd $MONITOR_DIR && python3 test_webhook.py
        ;;
    pcap)
        if [ -z "$2" ]; then
            echo "Usage: $0 pcap <output.pcap>"
            exit 1
        fi
        echo "📦 Converting logs to PCAP..."
        cd $MONITOR_DIR && python3 logs2pcap.py /opt/cowrie/var/log/cowrie/cowrie.json -o "$2"
        ;;
    *)
        echo "CerberusMesh Discord Monitor Management"
        echo "Usage: $0 {start|stop|restart|status|logs|follow|test|pcap}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the monitoring service"
        echo "  stop    - Stop the monitoring service"
        echo "  restart - Restart the monitoring service"
        echo "  status  - Show service status"
        echo "  logs    - Show recent logs"
        echo "  follow  - Follow logs in real-time"
        echo "  test    - Test Discord webhook"
        echo "  pcap    - Convert logs to PCAP format"
        exit 1
        ;;
esac
MANAGE_SCRIPT_EOF
    
    chmod +x "$MONITOR_DIR/manage_monitor.sh"
    
    log_info "✅ Additional tools created successfully"
}

set_permissions() {
    log_info "Setting proper permissions..."
    
    # Create ec2-user if it doesn't exist (for non-AWS systems)
    if ! id "ec2-user" &>/dev/null; then
        log_warn "Creating ec2-user account..."
        useradd -r -s /bin/bash ec2-user
    fi
    
    # Set ownership
    chown -R ec2-user:ec2-user "$MONITOR_DIR"
    
    # Set specific permissions
    chmod 755 "$MONITOR_DIR"
    chmod 600 "$MONITOR_DIR/discord_config.json"
    chmod 755 "$MONITOR_DIR"/*.py
    chmod 755 "$MONITOR_DIR"/*.sh
    
    # Create logs directory
    mkdir -p "$MONITOR_DIR/logs"
    chown ec2-user:ec2-user "$MONITOR_DIR/logs"
    
    # Create PCAP directory
    mkdir -p /opt/cowrie/pcaps
    chown ec2-user:ec2-user /opt/cowrie/pcaps
    
    log_info "✅ Permissions set correctly"
}

deploy_service() {
    log_info "Deploying and starting service..."
    
    # Reload systemd
    systemctl daemon-reload
    
    # Enable service
    systemctl enable "$SERVICE_NAME"
    
    # Test webhook first
    log_info "Testing Discord webhook..."
    if cd "$MONITOR_DIR" && sudo -u ec2-user python3 test_webhook.py; then
        log_info "✅ Webhook test successful"
    else
        log_error "❌ Webhook test failed - check configuration"
        return 1
    fi
    
    # Start service
    systemctl start "$SERVICE_NAME"
    
    # Check status
    sleep 3
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        log_info "✅ Service started successfully"
        systemctl status "$SERVICE_NAME" --no-pager
    else
        log_error "❌ Service failed to start"
        journalctl -u "$SERVICE_NAME" --no-pager -n 10
        return 1
    fi
}

print_summary() {
    echo ""
    echo "=========================================="
    echo "✅ CerberusMesh Discord Monitor Deployed!"
    echo "=========================================="
    echo ""
    echo "🎯 Your AIT670 honeypot is now sending real-time alerts to Discord!"
    echo ""
    echo "📋 Quick Commands:"
    echo "   Status:  systemctl status $SERVICE_NAME"
    echo "   Logs:    journalctl -u $SERVICE_NAME -f"
    echo "   Test:    cd $MONITOR_DIR && python3 test_webhook.py"
    echo "   Manage:  $MONITOR_DIR/manage_monitor.sh"
    echo ""
    echo "📁 Files created:"
    echo "   • Monitor script: $MONITOR_DIR/discord_honeypot_monitor.py"
    echo "   • Configuration:  $MONITOR_DIR/discord_config.json"
    echo "   • Service file:   /etc/systemd/system/$SERVICE_NAME.service"
    echo "   • Management:     $MONITOR_DIR/manage_monitor.sh"
    echo "   • PCAP converter: $MONITOR_DIR/logs2pcap.py"
    echo ""
    echo "🔥 Features enabled:"
    echo "   ✅ Real-time Discord alerts"
    echo "   ✅ Intelligent threat detection"
    echo "   ✅ Session tracking and correlation"
    echo "   ✅ Rate limiting and spam protection"
    echo "   ✅ Team collaboration features"
    echo "   ✅ PCAP conversion capabilities"
    echo "   ✅ Service persistence and auto-restart"
    echo ""
    echo "📊 Monitor your Discord #honeypot-alerts channel for activity!"
    echo "🎯 Your AIT670 team project is ready for threat hunting!"
    echo ""
}

# Main deployment flow
main() {
    print_banner
    
    # Create log file
    touch "$LOG_FILE"
    
    log "🚀 Starting CerberusMesh Discord Monitor deployment..."
    
    check_requirements
    get_webhook_url
    install_dependencies
    create_monitor_script
    create_configuration
    create_systemd_service
    create_tools
    set_permissions
    
    if deploy_service; then
        print_summary
        log "✅ Deployment completed successfully!"
        exit 0
    else
        log_error "❌ Deployment failed - check logs above"
        exit 1
    fi
}

# Run main deployment
main "$@"
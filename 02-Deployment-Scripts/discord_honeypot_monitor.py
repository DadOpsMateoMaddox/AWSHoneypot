#!/usr/bin/env python3
"""
Cowrie Honeypot Discord Webhook Monitor
Created for AIT670 Team Honeypot Project

This script monitors Cowrie honeypot logs and sends real-time alerts to Discord
when suspicious activity is detected.

Author: Team AIT670 (Mateo Maddox & Team)
Date: September 2025
"""

import json
import time
import os
import sys
import logging
import requests
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional
import subprocess
import signal

class DiscordHoneypotMonitor:
    def __init__(self, config_file: str = "discord_config.json"):
        """Initialize the Discord honeypot monitor."""
        self.config_file = config_file
        self.config = self.load_config()
        self.last_position = 0
        self.running = True
        
        # Set up logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('discord_monitor.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
        # Handle graceful shutdown
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
    
    def signal_handler(self, signum, frame):
        """Handle shutdown signals gracefully."""
        self.logger.info(f"Received signal {signum}, shutting down gracefully...")
        self.running = False
    
    def load_config(self) -> Dict[str, Any]:
        """Load configuration from JSON file."""
        config_path = Path(self.config_file)
        
        if not config_path.exists():
            self.create_default_config()
        
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
            return config
        except Exception as e:
            print(f"Error loading config: {e}")
            sys.exit(1)
    
    def create_default_config(self):
        """Create a default configuration file."""
        default_config = {
            "discord_webhook_url": "REPLACE_WITH_YOUR_WEBHOOK_URL",
            "cowrie_log_path": "/opt/cowrie/var/log/cowrie/cowrie.json",
            "monitoring_interval": 5,
            "alert_levels": {
                "login_success": True,
                "login_failed": False,
                "command_executed": True,
                "file_upload": True,
                "file_download": True,
                "session_start": False,
                "session_end": False
            },
            "interesting_commands": [
                "wget", "curl", "nc", "netcat", "python", "perl", "ruby",
                "bash", "sh", "powershell", "cmd", "sudo", "su", "passwd",
                "cat /etc/passwd", "cat /etc/shadow", "whoami", "id",
                "uname", "ps", "netstat", "ss", "lsof", "nmap", "masscan"
            ],
            "max_message_length": 1900,
            "rate_limit_delay": 1
        }
        
        with open(self.config_file, 'w') as f:
            json.dump(default_config, f, indent=4)
        
        print(f"Created default config file: {self.config_file}")
        print("Please edit the config file and add your Discord webhook URL!")
        sys.exit(0)
    
    def send_discord_alert(self, title: str, description: str, color: int = 0xff9900, fields: list = None):
        """Send an alert to Discord via webhook."""
        webhook_url = self.config.get("discord_webhook_url")
        
        if webhook_url == "REPLACE_WITH_YOUR_WEBHOOK_URL":
            self.logger.error("Discord webhook URL not configured!")
            return False
        
        # Truncate description if too long
        max_length = self.config.get("max_message_length", 1900)
        if len(description) > max_length:
            description = description[:max_length] + "... [truncated]"
        
        embed = {
            "title": title,
            "description": description,
            "color": color,
            "timestamp": datetime.utcnow().isoformat(),
            "footer": {
                "text": "Cowrie Honeypot Alert System"
            }
        }
        
        if fields:
            embed["fields"] = fields
        
        payload = {
            "embeds": [embed]
        }
        
        try:
            response = requests.post(webhook_url, json=payload, timeout=10)
            response.raise_for_status()
            
            # Rate limiting
            time.sleep(self.config.get("rate_limit_delay", 1))
            return True
            
        except requests.exceptions.RequestException as e:
            self.logger.error(f"Failed to send Discord alert: {e}")
            return False
    
    def format_login_event(self, event: Dict[str, Any]) -> tuple:
        """Format login event for Discord."""
        username = event.get('username', 'unknown')
        password = event.get('password', 'unknown')
        src_ip = event.get('src_ip', 'unknown')
        
        if event.get('eventid') == 'cowrie.login.success':
            title = "🚨 SUCCESSFUL LOGIN DETECTED!"
            color = 0xff0000  # Red for successful logins (bad!)
            description = f"**Attacker successfully logged in!**\n\n"
        else:
            title = "🔒 Failed Login Attempt"
            color = 0xffaa00  # Orange for failed logins
            description = f"**Login attempt failed**\n\n"
        
        description += f"**IP Address:** `{src_ip}`\n"
        description += f"**Username:** `{username}`\n"
        description += f"**Password:** `{password}`\n"
        
        fields = [
            {"name": "Source IP", "value": src_ip, "inline": True},
            {"name": "Credentials", "value": f"{username}:{password}", "inline": True}
        ]
        
        return title, description, color, fields
    
    def format_command_event(self, event: Dict[str, Any]) -> tuple:
        """Format command execution event for Discord."""
        command = event.get('input', 'unknown')
        src_ip = event.get('src_ip', 'unknown')
        session = event.get('session', 'unknown')
        
        # Check if it's an interesting command
        interesting_commands = self.config.get("interesting_commands", [])
        is_interesting = any(cmd in command.lower() for cmd in interesting_commands)
        
        if is_interesting:
            title = "⚠️ SUSPICIOUS COMMAND EXECUTED!"
            color = 0xff6600  # Dark orange for interesting commands
        else:
            title = "💻 Command Executed"
            color = 0x0099ff  # Blue for normal commands
        
        description = f"**Command:** `{command}`\n"
        description += f"**Source IP:** `{src_ip}`\n"
        description += f"**Session:** `{session[:8]}...`\n"
        
        fields = [
            {"name": "Command", "value": f"```bash\n{command}\n```", "inline": False},
            {"name": "Source IP", "value": src_ip, "inline": True},
            {"name": "Session ID", "value": session[:8], "inline": True}
        ]
        
        return title, description, color, fields
    
    def format_file_event(self, event: Dict[str, Any]) -> tuple:
        """Format file upload/download event for Discord."""
        filename = event.get('filename', 'unknown')
        src_ip = event.get('src_ip', 'unknown')
        eventid = event.get('eventid', '')
        
        if 'upload' in eventid:
            title = "📤 FILE UPLOAD DETECTED!"
            color = 0xff3300  # Red for uploads (very suspicious!)
            action = "uploaded"
        else:
            title = "📥 File Download Attempt"
            color = 0xff9900  # Orange for downloads
            action = "downloaded"
        
        description = f"**Attacker {action} a file!**\n\n"
        description += f"**Filename:** `{filename}`\n"
        description += f"**Source IP:** `{src_ip}`\n"
        
        fields = [
            {"name": "Filename", "value": filename, "inline": True},
            {"name": "Source IP", "value": src_ip, "inline": True},
            {"name": "Action", "value": action.title(), "inline": True}
        ]
        
        return title, description, color, fields
    
    def process_event(self, event: Dict[str, Any]):
        """Process a single Cowrie log event."""
        eventid = event.get('eventid', '')
        alert_levels = self.config.get("alert_levels", {})
        
        try:
            # Login events
            if eventid in ['cowrie.login.success', 'cowrie.login.failed']:
                if (eventid == 'cowrie.login.success' and alert_levels.get('login_success', True)) or \
                   (eventid == 'cowrie.login.failed' and alert_levels.get('login_failed', False)):
                    title, description, color, fields = self.format_login_event(event)
                    self.send_discord_alert(title, description, color, fields)
            
            # Command execution
            elif eventid == 'cowrie.command.input' and alert_levels.get('command_executed', True):
                title, description, color, fields = self.format_command_event(event)
                self.send_discord_alert(title, description, color, fields)
            
            # File events
            elif eventid in ['cowrie.session.file_upload', 'cowrie.session.file_download']:
                if (('upload' in eventid and alert_levels.get('file_upload', True)) or 
                    ('download' in eventid and alert_levels.get('file_download', True))):
                    title, description, color, fields = self.format_file_event(event)
                    self.send_discord_alert(title, description, color, fields)
            
            # Session events (optional)
            elif eventid == 'cowrie.session.connect' and alert_levels.get('session_start', False):
                src_ip = event.get('src_ip', 'unknown')
                self.send_discord_alert(
                    "🔗 New Connection",
                    f"New session started from `{src_ip}`",
                    0x00ff00  # Green
                )
            
        except Exception as e:
            self.logger.error(f"Error processing event: {e}")
    
    def monitor_logs(self):
        """Monitor Cowrie logs for new events."""
        log_path = Path(self.config.get("cowrie_log_path", "/opt/cowrie/var/log/cowrie/cowrie.json"))
        
        if not log_path.exists():
            self.logger.error(f"Cowrie log file not found: {log_path}")
            return
        
        self.logger.info(f"Starting to monitor {log_path}")
        
        # Send startup notification
        self.send_discord_alert(
            "🟢 Honeypot Monitor Started",
            f"Discord webhook monitor is now active!\n\n**Monitoring:** `{log_path}`\n**Interval:** {self.config.get('monitoring_interval', 5)}s",
            0x00ff00  # Green
        )
        
        while self.running:
            try:
                with open(log_path, 'r') as f:
                    f.seek(self.last_position)
                    
                    for line in f:
                        line = line.strip()
                        if line:
                            try:
                                event = json.loads(line)
                                self.process_event(event)
                            except json.JSONDecodeError:
                                continue
                    
                    self.last_position = f.tell()
                
                time.sleep(self.config.get("monitoring_interval", 5))
                
            except FileNotFoundError:
                self.logger.warning(f"Log file not found, waiting...")
                time.sleep(10)
            except Exception as e:
                self.logger.error(f"Error monitoring logs: {e}")
                time.sleep(10)
        
        # Send shutdown notification
        self.send_discord_alert(
            "🔴 Honeypot Monitor Stopped",
            "Discord webhook monitor has been stopped.",
            0xff0000  # Red
        )

def main():
    """Main function."""
    if len(sys.argv) > 1:
        config_file = sys.argv[1]
    else:
        config_file = "discord_config.json"
    
    monitor = DiscordHoneypotMonitor(config_file)
    
    try:
        monitor.monitor_logs()
    except KeyboardInterrupt:
        monitor.logger.info("Received keyboard interrupt, shutting down...")
    except Exception as e:
        monitor.logger.error(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
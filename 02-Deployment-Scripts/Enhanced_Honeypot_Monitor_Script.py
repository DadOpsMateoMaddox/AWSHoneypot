#!/usr/bin/env python3
"""
Advanced Honeypot Monitor for Educational Cybersecurity Research
Integrates with Cowrie honeypot and Discord for real-time threat intelligence
"""

import json
import asyncio
import aiohttp
import socket
import struct
import time
import hashlib
import re
import platform
import os
from datetime import datetime
from pathlib import Path
from collections import defaultdict
import subprocess
try:
    import geoip2.database
    import geoip2.errors
except ImportError:
    print("📦 Installing geoip2 library...")
    subprocess.run(["pip", "install", "geoip2"], capture_output=True)
    import geoip2.database
    import geoip2.errors

# Threat Intelligence Integration
from threat_enrichment import get_enrichment
THREAT_INTEL_ENABLED = True
print("✅ Initializing threat intelligence...")
enricher = get_enrichment()
print(f"✅ Threat intel ready ({len([k for k,v in enricher.apis_available.items() if v])}/6 APIs)") 
class AdvancedHoneypotMonitor:
    def __init__(self, discord_webhook_url, cowrie_log_path="/opt/cowrie/var/log/cowrie/cowrie.json"):
        self.webhook_url = discord_webhook_url
        self.cowrie_log = cowrie_log_path
        self.session_data = {}
        self.ip_fingerprints = {}
        self.command_sequences = defaultdict(list)
        self.attack_patterns = defaultdict(int)
        
        # Initialize GeoIP database
        self.geoip_db = self._init_geoip()
        
    def _init_geoip(self):
        """Initialize GeoIP database for location tracking"""
        try:
            # Download GeoLite2 database if not exists
            db_path = "/opt/GeoLite2-City.mmdb"
            if not Path(db_path).exists():
                print("📍 Downloading GeoIP database...")
                subprocess.run([
                    "wget", "-O", db_path,
                    "https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-City.mmdb"
                ], capture_output=True)
            return geoip2.database.Reader(db_path)
        except Exception as e:
            print(f"⚠️  GeoIP initialization failed: {e}")
            return None
        
    async def parse_cowrie_logs(self):
        """Parse Cowrie JSON logs for enhanced analysis"""
        try:
            with open(self.cowrie_log, 'r') as f:
                for line in f:
                    try:
                        log_entry = json.loads(line.strip())
                        await self.process_log_entry(log_entry)
                    except json.JSONDecodeError:
                        continue
        except FileNotFoundError:
            print(f"Cowrie log file not found: {self.cowrie_log}")
    
    def fingerprint_os(self, ip_address):
        """Advanced OS fingerprinting using multiple techniques"""
        fingerprint = {
            "ip": ip_address,
            "timestamp": datetime.now().isoformat(),
            "methods": {}
        }
        
        # Method 1: TTL-based OS detection
        try:
            ping_result = subprocess.run([
                "ping", "-n", "1", ip_address  # Windows ping
            ], capture_output=True, text=True, timeout=10)
            
            ttl_match = re.search(r'TTL=(\d+)', ping_result.stdout)
            if ttl_match:
                ttl = int(ttl_match.group(1))
                fingerprint["methods"]["ttl"] = ttl
                fingerprint["methods"]["os_guess_ttl"] = self._guess_os_from_ttl(ttl)
        except Exception as e:
            fingerprint["methods"]["ping_error"] = str(e)
        
        # Store fingerprint
        self.ip_fingerprints[ip_address] = fingerprint
        return fingerprint
    
    def _guess_os_from_ttl(self, ttl):
        """Guess OS based on TTL values"""
        ttl_signatures = {
            64: "Linux/Unix/MacOS",
            128: "Windows",
            255: "Cisco/Network Device",
            32: "Windows 95/98",
            60: "MacOS",
            254: "Solaris"
        }
        
        # Find closest TTL match
        closest_ttl = min(ttl_signatures.keys(), key=lambda x: abs(x - ttl))
        if abs(closest_ttl - ttl) <= 10:  # Allow some variation
            return ttl_signatures[closest_ttl]
        return f"Unknown (TTL: {ttl})"
    
    async def get_geolocation(self, ip_address):
        """Get geographical location of IP address"""
        if not self.geoip_db:
            return None
            
        try:
            response = self.geoip_db.city(ip_address)
            return {
                "country": response.country.name,
                "city": response.city.name,
                "latitude": float(response.location.latitude) if response.location.latitude else None,
                "longitude": float(response.location.longitude) if response.location.longitude else None
            }
        except geoip2.errors.AddressNotFoundError:
            return {"country": "Unknown", "city": "Unknown"}
        except Exception as e:
            print(f"GeoIP error: {e}")
            return None
    
    async def process_log_entry(self, entry):
        """Process individual log entries for interesting events"""
        event_type = entry.get('eventid', '')
        session_id = entry.get('session', '')
        
        # Track session data with enhanced fingerprinting
        if session_id not in self.session_data:
            src_ip = entry.get('src_ip', '')
            
            # Perform OS fingerprinting for new sessions
            if event_type == 'cowrie.session.connect':
                fingerprint = self.fingerprint_os(src_ip)
                geolocation = await self.get_geolocation(src_ip)
                
                # Send new connection alert
                location_str = "Unknown"
                if geolocation and geolocation.get('country') != 'Unknown':
                    location_str = f"{geolocation.get('city', 'Unknown')}, {geolocation.get('country', 'Unknown')}"
                
                fields = [
                    {"name": "🌍 Location", "value": location_str, "inline": True},
                    {"name": "🔍 OS Fingerprint", "value": fingerprint.get('methods', {}).get('os_guess_ttl', 'Analyzing...'), "inline": True},
                    {"name": "📊 Session ID", "value": session_id[:8], "inline": True}
                ]
                
                await self.send_discord_alert(
                    f"🚨 New Attacker Connected",
                    f"**IP Address:** `{src_ip}`\n**Time:** {datetime.now().strftime('%H:%M:%S UTC')}",
                    color=0xff9500,
                    fields=fields
                )
            
            self.session_data[session_id] = {
                'commands': [],
                'downloads': [],
                'login_attempts': [],
                'start_time': entry.get('timestamp', ''),
                'src_ip': src_ip,
                'client_version': entry.get('version', ''),
                'fingerprint': self.ip_fingerprints.get(src_ip, {}),
                'geolocation': await self.get_geolocation(src_ip) if src_ip else None
            }
        
        # Process different event types
        if event_type == 'cowrie.command.input':
            await self.handle_command(entry, session_id)
        elif event_type == 'cowrie.login.success':
            await self.handle_successful_login(entry, session_id)
        elif event_type == 'cowrie.login.failed':
            await self.handle_failed_login(entry, session_id)
        elif event_type == 'cowrie.session.file_download':
            await self.handle_file_download(entry, session_id)
        elif event_type == 'cowrie.client.version':
            await self.handle_client_fingerprint(entry, session_id)
    
    async def handle_command(self, entry, session_id):
        """Process executed commands with advanced keylogging"""
        command = entry.get('input', '')
        command_parts = command.split()
        cmd = command_parts[0] if command_parts else ''
        args = command_parts[1:] if len(command_parts) > 1 else []
        
        # Enhanced command analysis
        analysis = await self.enhanced_keylogger(session_id, cmd, args, entry)
        
        self.session_data[session_id]['commands'].append({
            'command': command,
            'timestamp': entry.get('timestamp', ''),
            'ttylog': entry.get('ttylog', ''),
            'analysis': analysis
        })
        
        # Send Discord alert for high-risk commands
        if analysis['threat_level'] in ['HIGH', 'CRITICAL']:
            suspicious_text = '\n'.join([f"• {indicator}" for indicator in analysis['suspicious_indicators']])
            
            fields = [
                {"name": "⚡ Threat Level", "value": analysis['threat_level'], "inline": True},
                {"name": "🎯 Category", "value": analysis['attack_category'].title(), "inline": True},
                {"name": "📍 Source IP", "value": self.session_data[session_id]['src_ip'], "inline": True}
            ]
            
            if suspicious_text:
                fields.append({"name": "🚩 Suspicious Indicators", "value": suspicious_text, "inline": False})
            
            await self.send_discord_alert(
                f"⚠️ Suspicious Command Executed",
                f"**Command:** `{command}`\n**Session:** {session_id[:8]}",
                color=0xff0000,
                fields=fields
            )
    
    async def enhanced_keylogger(self, session_id, command, args, log_entry):
        """Enhanced command and keystroke analysis"""
        timestamp = datetime.now().isoformat()
        
        # Analyze command patterns
        command_analysis = {
            "session_id": session_id,
            "timestamp": timestamp,
            "command": command,
            "args": args or [],
            "threat_level": self._assess_threat_level(command, args),
            "attack_category": self._categorize_attack(command),
            "suspicious_indicators": self._find_suspicious_indicators(command, args)
        }
        
        # Store in command sequence for pattern analysis
        self.command_sequences[session_id].append(command_analysis)
        
        # Check for attack patterns
        pattern_detected = self._detect_attack_patterns(session_id)
        if pattern_detected:
            await self.send_discord_alert(
                "🚨 Attack Pattern Detected",
                f"**Session:** {session_id}\n**Pattern:** {pattern_detected['pattern']}\n**Commands:** {' → '.join(pattern_detected['commands'])}",
                color=0xff0000,
                fields=[
                    {"name": "Threat Level", "value": pattern_detected['threat_level'], "inline": True},
                    {"name": "Category", "value": pattern_detected['category'], "inline": True}
                ]
            )
        
        return command_analysis
    
    def _assess_threat_level(self, command, args):
        """Assess threat level of commands"""
        high_risk_commands = [
            "rm", "del", "format", "fdisk", "mkfs", "dd",
            "wget", "curl", "nc", "netcat", "ncat", "socat",
            "python", "perl", "php", "ruby", "bash", "sh",
            "chmod", "chown", "sudo", "su", "passwd",
            "iptables", "ufw", "firewall-cmd", "netsh",
            "crontab", "systemctl", "service", "sc"
        ]
        
        medium_risk_commands = [
            "ps", "netstat", "ss", "lsof", "who", "w", "last",
            "find", "locate", "grep", "awk", "sed",
            "tar", "zip", "unzip", "gzip", "gunzip"
        ]
        
        if command in high_risk_commands:
            return "HIGH"
        elif command in medium_risk_commands:
            return "MEDIUM"
        elif args and any(dangerous in ' '.join(args) for dangerous in ["-rf", "--force", "/etc/", "/root/", "/home/"]):
            return "HIGH"
        else:
            return "LOW"
    
    def _categorize_attack(self, command):
        """Categorize the type of attack based on command"""
        categories = {
            "reconnaissance": ["ps", "netstat", "ss", "lsof", "who", "w", "last", "uname", "id", "whoami"],
            "persistence": ["crontab", "systemctl", "service", "chmod", "chown"],
            "privilege_escalation": ["sudo", "su", "passwd", "/etc/sudoers"],
            "data_exfiltration": ["tar", "zip", "scp", "rsync", "base64"],
            "system_manipulation": ["rm", "mv", "cp", "ln", "mkdir", "rmdir"],
            "network_tools": ["wget", "curl", "nc", "netcat", "telnet", "ssh"],
            "malware_execution": ["python", "perl", "php", "ruby", "bash", "sh", "./"]
        }
        
        for category, commands in categories.items():
            if command in commands or any(cmd in command for cmd in commands):
                return category
        
        return "unknown"
    
    def _find_suspicious_indicators(self, command, args):
        """Find suspicious indicators in commands"""
        indicators = []
        full_command = f"{command} {' '.join(args or [])}"
        
        suspicious_patterns = [
            (r'(wget|curl).*\.(sh|py|pl|php)', "Downloading executable script"),
            (r'chmod.*\+x', "Making file executable"),
            (r'rm.*-rf.*/', "Recursive force deletion"),
            (r'nc.*-e.*sh', "Netcat shell"),
            (r'python.*-c.*import', "Inline Python execution"),
            (r'base64.*-d', "Base64 decoding (potential payload)"),
            (r'/tmp/\w+', "Temporary file usage"),
            (r'(127\.0\.0\.1|localhost):\d+', "Local port usage"),
            (r'\d+\.\d+\.\d+\.\d+:\d+', "External IP connection")
        ]
        
        for pattern, description in suspicious_patterns:
            if re.search(pattern, full_command, re.IGNORECASE):
                indicators.append(description)
        
        return indicators
    
    def _detect_attack_patterns(self, session_id):
        """Detect common attack patterns in command sequences"""
        commands = [entry['command'] for entry in self.command_sequences[session_id]]
        
        # Pattern 1: Reconnaissance -> Privilege Escalation -> Persistence
        recon_pattern = ["whoami", "id", "uname", "ps"]
        privesc_pattern = ["sudo", "su", "passwd"]
        persist_pattern = ["crontab", "systemctl", "service"]
        
        if (any(cmd in commands for cmd in recon_pattern) and
            any(cmd in commands for cmd in privesc_pattern) and
            any(cmd in commands for cmd in persist_pattern)):
            return {
                "pattern": "Advanced Persistent Threat (APT)",
                "commands": commands[-10:],  # Last 10 commands
                "threat_level": "CRITICAL",
                "category": "apt_behavior"
            }
        
        # Pattern 2: Download and Execute
        if any(cmd in ["wget", "curl"] for cmd in commands):
            exec_commands = ["chmod", "bash", "sh", "python", "./"]
            if any(cmd in commands for cmd in exec_commands):
                return {
                    "pattern": "Download and Execute",
                    "commands": commands[-5:],
                    "threat_level": "HIGH",
                    "category": "malware_deployment"
                }
        
        return None
    
    async def handle_successful_login(self, entry, session_id):
        """Process successful login attempts"""
        username = entry.get('username', '')
        password = entry.get('password', '')
        
        await self.send_discord_alert("✅ Successful Login", {
            "Session": session_id[:8],
            "Source IP": self.session_data[session_id]['src_ip'],
            "Username": username,
            "Password": password,
            "Client": self.session_data[session_id].get('client_version', 'Unknown')
        })
    
    async def handle_failed_login(self, entry, session_id):
        """Track failed login attempts with threat intelligence"""
        username = entry.get('username', '')
        password = entry.get('password', '')
        src_ip = entry.get('src_ip', '')
        
        self.session_data[session_id]['login_attempts'].append({
            'username': username,
            'password': password,
            'timestamp': entry.get('timestamp', '')
        })
        
        # Build alert description
        description = f"**IP:** `{src_ip}`\n**Username:** `{username}`\n**Password:** `{password}`"
        
        # Add threat intelligence enrichment
        if THREAT_INTEL_ENABLED and enricher:
            try:
                print(f"🔍 Enriching IP: {src_ip}")
                intel_data = enricher.enrich_ip(src_ip)
                intel_text = enricher.format_for_discord(intel_data)
                description += f"\n\n{intel_text}"
            except Exception as e:
                print(f"⚠️ Threat intel error: {e}")
                description += f"\n\n⚠️ *Threat intel temporarily unavailable*"
        
        # Send Discord alert
        await self.send_discord_alert(
            f"🔐 Failed Login Attempt",
            description,
            color=0xff0000
        )
    
    async def handle_file_download(self, entry, session_id):
        """Process file downloads"""
        url = entry.get('url', '')
        filename = entry.get('outfile', '')
        
        await self.send_discord_alert("📥 File Download", {
            "Session": session_id[:8],
            "Source IP": self.session_data[session_id]['src_ip'],
            "URL": url,
            "Filename": filename,
            "Size": entry.get('size', 'Unknown')
        })
    
    async def handle_client_fingerprint(self, entry, session_id):
        """Process SSH client fingerprinting"""
        version = entry.get('version', '')
        self.session_data[session_id]['client_version'] = version
        
        # Analyze client patterns
        client_analysis = self.analyze_ssh_client(version)
        
        await self.send_discord_alert("🔍 Client Fingerprint", {
            "Session": session_id[:8],
            "Source IP": self.session_data[session_id]['src_ip'],
            "SSH Version": version,
            "Analysis": client_analysis
        })
    
    def analyze_ssh_client(self, version):
        """Analyze SSH client version for insights"""
        if 'libssh' in version.lower():
            return "🤖 Automated tool (libssh-based)"
        elif 'openssh' in version.lower():
            return "🐧 Standard OpenSSH client"
        elif 'putty' in version.lower():
            return "🪟 PuTTY Windows client"
        elif 'paramiko' in version.lower():
            return "🐍 Python Paramiko (scripted)"
        else:
            return "❓ Unknown/Custom client"
    
    async def send_discord_alert(self, title, description=None, color=0xff6b6b, fields=None, data=None):
        """Enhanced Discord webhook with rich embeds"""
        embed = {
            "title": title,
            "color": color,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "footer": {
                "text": f"🍯 GMU Honeypot • {platform.node()}",
                "icon_url": "https://cdn.discordapp.com/emojis/1234567890123456789.png"
            }
        }
        
        if description:
            embed["description"] = description
        
        if fields:
            embed["fields"] = fields
        elif data:  # Legacy support for old format
            embed["fields"] = []
            for key, value in data.items():
                embed["fields"].append({
                    "name": key,
                    "value": str(value),
                    "inline": True
                })
            
        payload = {
            "embeds": [embed],
            "username": "Honeypot Guardian",
            "avatar_url": "https://cdn.discordapp.com/emojis/🍯.png"
        }
        
        try:
            if not self.webhook_url:
                print(f"❌ Discord webhook not configured, skipping alert: {title}")
                return

            async with aiohttp.ClientSession() as session:
                async with session.post(self.webhook_url, json=payload) as response:
                    if response.status == 204:
                        print(f"✅ Discord alert sent: {title}")
                    else:
                        # Try to read response body for better diagnostics
                        try:
                            text = await response.text()
                        except Exception:
                            text = "<no response body>"
                        print(f"❌ Discord webhook failed: {response.status} - {text}")
        except Exception as e:
            print(f"🚨 Discord webhook error: {e}")
    
    async def generate_session_summary(self, session_id):
        """Generate comprehensive session summary"""
        if session_id not in self.session_data:
            return
        
        session = self.session_data[session_id]
        
        summary = {
            "Session ID": session_id[:8],
            "Source IP": session['src_ip'],
            "Duration": "Active",
            "Commands Executed": len(session['commands']),
            "Login Attempts": len(session['login_attempts']),
            "Files Downloaded": len(session['downloads']),
            "Client Version": session.get('client_version', 'Unknown')
        }
        
        await self.send_discord_alert("📊 Session Summary", summary)
    
    async def monitor_network_connections(self):
        """Monitor active network connections to honeypot"""
        try:
            result = subprocess.run(['netstat', '-tn'], capture_output=True, text=True)
            connections = []
            
            for line in result.stdout.split('\n'):
                if ':22 ' in line and 'ESTABLISHED' in line:
                    parts = line.split()
                    if len(parts) >= 5:
                        remote_addr = parts[4].split(':')[0]
                        connections.append(remote_addr)
            
            if connections:
                await self.send_discord_alert("🔗 Active SSH Connections", {
                    "Count": len(connections),
                    "IPs": ", ".join(set(connections))
                })
                
        except Exception as e:
            print(f"Network monitoring error: {e}")

    async def monitor_cowrie_logs(self):
        """Main monitoring loop for Cowrie logs with real-time parsing"""
        print("🍯 Starting Enhanced Honeypot Monitor...")
        print(f"📝 Monitoring: {self.cowrie_log}")
        print(f"🔔 Discord Webhook: {'Configured' if self.webhook_url else 'Not configured'}")
        
        # Send startup notification
        await self.send_discord_alert(
            "🟢 Honeypot Monitor Online",
            f"Enhanced monitoring system activated\n**Features:** OS Fingerprinting, GeoIP, Advanced Keylogging",
            color=0x00ff00,
            fields=[
                {"name": "🏠 Hostname", "value": platform.node(), "inline": True},
                {"name": "⏰ Started", "value": datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC'), "inline": True}
            ]
        )
        
        # Monitor log file for new entries
        last_position = 0
        if Path(self.cowrie_log).exists():
            last_position = Path(self.cowrie_log).stat().st_size
        
        while True:
            try:
                if Path(self.cowrie_log).exists():
                    current_size = Path(self.cowrie_log).stat().st_size
                    
                    if current_size > last_position:
                        with open(self.cowrie_log, 'r') as f:
                            f.seek(last_position)
                            new_lines = f.readlines()
                            
                        for line in new_lines:
                            try:
                                log_entry = json.loads(line.strip())
                                await self.process_log_entry(log_entry)
                            except json.JSONDecodeError:
                                continue
                        
                        last_position = current_size
                
                await asyncio.sleep(2)  # Check every 2 seconds
                
            except Exception as e:
                print(f"❌ Error in monitoring loop: {e}")
                await asyncio.sleep(10)

# Usage example
async def main():
    # Prefer webhook from environment, then from a standard config path
    webhook = os.environ.get('DISCORD_WEBHOOK_URL')
    config_path = Path('/opt/cowrie/discord-monitor/discord_config.json')

    if not webhook and config_path.exists():
        try:
            cfg = json.loads(config_path.read_text())
            webhook = cfg.get('discord_webhook_url')
        except Exception as e:
            print(f"Could not read config file {config_path}: {e}")

    if not webhook:
        print("Error: Discord webhook URL not configured. Set DISCORD_WEBHOOK_URL or update /opt/cowrie/discord-monitor/discord_config.json")
        return

    monitor = AdvancedHoneypotMonitor(webhook)
    await monitor.monitor_cowrie_logs()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n🛑 Monitor stopped by user")
    except Exception as e:
        print(f"💥 Fatal error: {e}")

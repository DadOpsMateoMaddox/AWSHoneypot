#!/usr/bin/env python3
"""
Final Project Statistics Generator
Generates comprehensive top 10 statistics from all 75 days and posts to Discord
"""

import json
import requests
import os
from datetime import datetime, timedelta
from collections import Counter, defaultdict

class FinalStatsGenerator:
    def __init__(self):
        self.discord_webhook = None
        self.load_discord_config()
        self.cowrie_log = '/opt/cowrie/var/log/cowrie/cowrie.json'
        
    def load_discord_config(self):
        """Load Discord webhook from config"""
        config_paths = [
            '/opt/cowrie/discord_config.json',
            '/home/ec2-user/discord_config.json',
            './discord_config.json'
        ]
        
        for path in config_paths:
            try:
                with open(path, 'r') as f:
                    config = json.load(f)
                    webhook = config.get('discord_webhook_url')
                    if webhook and webhook != "REPLACE_WITH_YOUR_WEBHOOK_URL":
                        self.discord_webhook = webhook
                        print(f"✅ Loaded Discord webhook from {path}")
                        return
            except:
                continue
        
        # Try environment variable
        self.discord_webhook = os.getenv('DISCORD_WEBHOOK_URL')
        if self.discord_webhook:
            print("✅ Loaded Discord webhook from environment")
    
    def analyze_all_logs(self):
        """Analyze all logs and generate comprehensive statistics"""
        stats = {
            'total_events': 0,
            'unique_ips': set(),
            'login_attempts': 0,
            'successful_logins': 0,
            'failed_logins': 0,
            'commands_executed': 0,
            'file_downloads': 0,
            'sessions': 0,
            'usernames': Counter(),
            'passwords': Counter(),
            'commands': Counter(),
            'source_ips': Counter(),
            'countries': Counter(),
            'first_event': None,
            'last_event': None,
            'top_attack_combos': Counter(),
            'ssh_versions': Counter(),
            'attack_methods': Counter()
        }
        
        print(f"📊 Analyzing logs from {self.cowrie_log}...")
        
        try:
            with open(self.cowrie_log, 'r') as f:
                for line_num, line in enumerate(f, 1):
                    try:
                        event = json.loads(line.strip())
                        stats['total_events'] += 1
                        
                        # Track timestamps
                        timestamp = event.get('timestamp', '')
                        if timestamp:
                            if not stats['first_event']:
                                stats['first_event'] = timestamp
                            stats['last_event'] = timestamp
                        
                        # Track IPs
                        src_ip = event.get('src_ip')
                        if src_ip:
                            stats['unique_ips'].add(src_ip)
                            stats['source_ips'][src_ip] += 1
                        
                        # Track event types
                        event_id = event.get('eventid', '')
                        
                        if event_id == 'cowrie.login.success':
                            stats['successful_logins'] += 1
                            username = event.get('username', 'unknown')
                            password = event.get('password', 'unknown')
                            stats['usernames'][username] += 1
                            stats['passwords'][password] += 1
                            stats['top_attack_combos'][f"{username}:{password}"] += 1
                        
                        elif event_id == 'cowrie.login.failed':
                            stats['failed_logins'] += 1
                            username = event.get('username', 'unknown')
                            password = event.get('password', 'unknown')
                            stats['usernames'][username] += 1
                            stats['passwords'][password] += 1
                        
                        elif event_id == 'cowrie.command.input':
                            stats['commands_executed'] += 1
                            command = event.get('input', 'unknown')
                            stats['commands'][command] += 1
                        
                        elif event_id == 'cowrie.session.file_download':
                            stats['file_downloads'] += 1
                        
                        elif event_id == 'cowrie.session.connect':
                            stats['sessions'] += 1
                        
                        elif event_id == 'cowrie.client.version':
                            ssh_version = event.get('version', 'unknown')
                            stats['ssh_versions'][ssh_version] += 1
                        
                        # Track country if available
                        country = event.get('country', event.get('geoip', {}).get('country_name'))
                        if country:
                            stats['countries'][country] += 1
                        
                    except json.JSONDecodeError:
                        continue
                    except Exception as e:
                        continue
        
        except FileNotFoundError:
            print(f"❌ Log file not found: {self.cowrie_log}")
            return None
        except Exception as e:
            print(f"❌ Error analyzing logs: {e}")
            return None
        
        stats['unique_ips'] = len(stats['unique_ips'])
        stats['login_attempts'] = stats['successful_logins'] + stats['failed_logins']
        
        print(f"✅ Analyzed {stats['total_events']:,} events")
        return stats
    
    def calculate_project_duration(self, first_event, last_event):
        """Calculate project duration in days"""
        try:
            first_dt = datetime.fromisoformat(first_event.replace('Z', '+00:00'))
            last_dt = datetime.fromisoformat(last_event.replace('Z', '+00:00'))
            duration = (last_dt - first_dt).days
            return duration, first_dt, last_dt
        except:
            return 75, None, None  # Default to 75 days
    
    def format_top10_message(self, stats):
        """Format comprehensive top 10 statistics for Discord"""
        if not stats:
            return "❌ No statistics available"
        
        duration_days, first_dt, last_dt = self.calculate_project_duration(
            stats['first_event'], stats['last_event']
        )
        
        # Format date range
        if first_dt and last_dt:
            date_range = f"{first_dt.strftime('%Y-%m-%d')} → {last_dt.strftime('%Y-%m-%d')}"
        else:
            date_range = "Project Duration"
        
        message = f"""
🍯 **PATRIOTPOT FINAL STATISTICS - PROJECT COMPLETE**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 **Project Duration:** {duration_days} days ({date_range})
🎯 **Status:** Cowrie Honeypot Shutdown - Data Collection Complete

**📊 OVERALL STATISTICS**
• Total Events Logged: **{stats['total_events']:,}**
• Unique Attacker IPs: **{stats['unique_ips']:,}**
• Total Sessions: **{stats['sessions']:,}**
• Login Attempts: **{stats['login_attempts']:,}**
  - Successful: {stats['successful_logins']:,}
  - Failed: {stats['failed_logins']:,}
• Commands Executed: **{stats['commands_executed']:,}**
• File Downloads: **{stats['file_downloads']:,}**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""
        return message
    
    def format_top10_lists(self, stats):
        """Format top 10 lists for Discord (separate messages)"""
        messages = []
        
        # Top 10 Attacker IPs
        if stats['source_ips']:
            msg = "**🔝 TOP 10 ATTACKER IPs**\n```\n"
            for i, (ip, count) in enumerate(stats['source_ips'].most_common(10), 1):
                msg += f"{i:2d}. {ip:15s} - {count:,} events\n"
            msg += "```"
            messages.append(msg)
        
        # Top 10 Usernames
        if stats['usernames']:
            msg = "**👤 TOP 10 USERNAMES TRIED**\n```\n"
            for i, (username, count) in enumerate(stats['usernames'].most_common(10), 1):
                msg += f"{i:2d}. {username:20s} - {count:,} attempts\n"
            msg += "```"
            messages.append(msg)
        
        # Top 10 Passwords
        if stats['passwords']:
            msg = "**🔑 TOP 10 PASSWORDS TRIED**\n```\n"
            for i, (password, count) in enumerate(stats['passwords'].most_common(10), 1):
                # Truncate long passwords for display
                display_pwd = password[:25] if len(password) <= 25 else password[:22] + "..."
                msg += f"{i:2d}. {display_pwd:25s} - {count:,} attempts\n"
            msg += "```"
            messages.append(msg)
        
        # Top 10 Commands
        if stats['commands']:
            msg = "**⚡ TOP 10 COMMANDS EXECUTED**\n```\n"
            for i, (command, count) in enumerate(stats['commands'].most_common(10), 1):
                display_cmd = command[:40] if len(command) <= 40 else command[:37] + "..."
                msg += f"{i:2d}. {display_cmd:40s} - {count:,}x\n"
            msg += "```"
            messages.append(msg)
        
        # Top 10 Attack Combinations
        if stats['top_attack_combos']:
            msg = "**🎯 TOP 10 USERNAME:PASSWORD COMBOS**\n```\n"
            for i, (combo, count) in enumerate(stats['top_attack_combos'].most_common(10), 1):
                display_combo = combo[:35] if len(combo) <= 35 else combo[:32] + "..."
                msg += f"{i:2d}. {display_combo:35s} - {count:,}x\n"
            msg += "```"
            messages.append(msg)
        
        # Top 10 SSH Client Versions
        if stats['ssh_versions']:
            msg = "**🔧 TOP 10 SSH CLIENT VERSIONS**\n```\n"
            for i, (version, count) in enumerate(stats['ssh_versions'].most_common(10), 1):
                display_ver = version[:40] if len(version) <= 40 else version[:37] + "..."
                msg += f"{i:2d}. {display_ver:40s} - {count:,}x\n"
            msg += "```"
            messages.append(msg)
        
        # Top 10 Countries (if available)
        if stats['countries']:
            msg = "**🌍 TOP 10 COUNTRIES**\n```\n"
            for i, (country, count) in enumerate(stats['countries'].most_common(10), 1):
                msg += f"{i:2d}. {country:30s} - {count:,} events\n"
            msg += "```"
            messages.append(msg)
        
        return messages
    
    def send_to_discord(self, message):
        """Send message to Discord webhook"""
        if not self.discord_webhook:
            print("⚠️  No Discord webhook configured. Message:")
            print(message)
            return False
        
        try:
            data = {"content": message}
            response = requests.post(
                self.discord_webhook,
                json=data,
                headers={"Content-Type": "application/json"},
                timeout=10
            )
            
            if response.status_code in [200, 204]:
                print(f"✅ Sent to Discord ({len(message)} chars)")
                return True
            else:
                print(f"⚠️  Discord returned status {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Error sending to Discord: {e}")
            return False
    
    def generate_and_post(self):
        """Generate statistics and post to Discord"""
        print("\n" + "="*60)
        print("🍯 PATRIOTPOT - FINAL PROJECT STATISTICS")
        print("="*60 + "\n")
        
        # Analyze logs
        stats = self.analyze_all_logs()
        if not stats:
            print("❌ Failed to analyze logs")
            return False
        
        # Format messages
        summary_msg = self.format_top10_message(stats)
        top10_msgs = self.format_top10_lists(stats)
        
        # Print to console
        print("\n" + summary_msg)
        for msg in top10_msgs:
            print("\n" + msg)
        
        # Send to Discord
        print("\n" + "="*60)
        print("📤 Posting to Discord...")
        print("="*60 + "\n")
        
        # Send summary
        self.send_to_discord(summary_msg)
        
        # Send each top 10 list with small delay
        import time
        for i, msg in enumerate(top10_msgs, 1):
            time.sleep(1)  # Rate limit
            print(f"Sending message {i}/{len(top10_msgs)}...")
            self.send_to_discord(msg)
        
        # Final message
        final_msg = """
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎓 **PROJECT COMPLETE - GMU AIT670 Fall 2025**
📚 **PatriotPot Deception Framework**
🏆 **Enterprise-Grade Threat Intelligence**

Thank you to the entire team for an amazing semester!
Log archives and PCAP files are being prepared for download.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""
        time.sleep(1)
        self.send_to_discord(final_msg)
        
        print("\n✅ Statistics generation and Discord posting complete!")
        return True

def main():
    generator = FinalStatsGenerator()
    generator.generate_and_post()

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Cowrie AI Integration - How to make attackers talk to your AI
This integrates with Cowrie's command processing to inject AI responses
"""

import json
import time
import random
from twisted.internet import reactor, defer
from cowrie.core.honeypot import HoneyPotCommand
from cowrie.shell.command import HoneyPotCommand as BaseCommand
from ai_honeypot_agent import process_attacker_command

class AIResponseCommand(BaseCommand):
    """
    Custom Cowrie command that intercepts attacker input and responds with AI
    This makes it look like the system is responding naturally
    """
    
    def start(self):
        """Called when attacker runs a command"""
        
        # Get attacker's command and session info
        command = ' '.join(self.args) if self.args else self.cmdname
        session_id = self.protocol.session.id
        src_ip = self.protocol.transport.getPeer().host
        
        # Get AI response
        ai_response = process_attacker_command(command, session_id, src_ip)
        
        if ai_response:
            # Make it look like someone is typing
            self.write("Someone is typing...\n")
            reactor.callLater(random.uniform(2, 5), self._send_ai_response, ai_response)
        
        # Continue with normal command execution (or fake it)
        self._execute_fake_command(command)
    
    def _send_ai_response(self, response):
        """Send AI response after a realistic delay"""
        self.write(f"\n[SYSTEM MESSAGE] {response}\n")
        self.write("$ ")  # Show prompt again
    
    def _execute_fake_command(self, command):
        """Execute fake version of command or show realistic output"""
        
        # Fake outputs for common commands
        fake_outputs = {
            'whoami': 'root',
            'id': 'uid=0(root) gid=0(root) groups=0(root)',
            'pwd': '/root',
            'ls': 'Desktop  Documents  Downloads  Pictures  Videos  secret_files',
            'ps': '''  PID TTY          TIME CMD
 1234 pts/0    00:00:01 bash
 5678 pts/0    00:00:00 ps''',
            'uname -a': 'Linux honeypot 5.4.0-42-generic #46-Ubuntu SMP Fri Jul 10 00:24:02 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux'
        }
        
        if command in fake_outputs:
            self.write(fake_outputs[command] + '\n')
        elif command.startswith('cat'):
            self._fake_cat_output(command)
        elif command.startswith('wget') or command.startswith('curl'):
            self._fake_download(command)
        else:
            # Generic fake output
            self.write(f"bash: {command}: command not found\n")
        
        self.exit()
    
    def _fake_cat_output(self, command):
        """Fake cat command outputs"""
        if '/etc/passwd' in command:
            self.write("""root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
admin:x:1000:1000:Admin User:/home/admin:/bin/bash
""")
        elif '/etc/shadow' in command:
            self.write("cat: /etc/shadow: Permission denied\n")
        else:
            self.write("This is a fake file with fake content!\n")
    
    def _fake_download(self, command):
        """Fake wget/curl downloads"""
        self.write("Connecting to malware.com... connected.\n")
        time.sleep(1)
        self.write("HTTP request sent, awaiting response... 200 OK\n")
        self.write("Length: 1337 (1.3K) [application/octet-stream]\n")
        self.write("Saving to: 'malware'\n")
        self.write("\nmalware              100%[===================>]   1.31K  --.-KB/s    in 0s\n")
        self.write("\n2024-01-01 12:00:00 (13.7 MB/s) - 'malware' saved [1337/1337]\n")


# Register AI responses for common hacking commands
HACKING_COMMANDS = [
    'wget', 'curl', 'nc', 'netcat', 'nmap', 'chmod', 'bash', 'sh',
    'python', 'perl', 'ruby', 'php', 'whoami', 'id', 'ps', 'kill',
    'rm', 'mv', 'cp', 'cat', 'echo', 'ls', 'cd', 'uname', 'passwd',
    'su', 'sudo', 'crontab', 'history', 'find', 'grep', 'awk', 'sed'
]

# This would be added to Cowrie's command registry
commands = {}
for cmd in HACKING_COMMANDS:
    commands[cmd] = AIResponseCommand
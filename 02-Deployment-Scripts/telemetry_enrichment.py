#!/usr/bin/env python3
"""
Telemetry Enrichment - Add fingerprinting data to every command
Helps distinguish automated scanners from human attackers
"""

import json
import time
from datetime import datetime

class TelemetryEnricher:
    def __init__(self):
        self.session_start_times = {}
    
    def enrich_event(self, event):
        """Add telemetry fingerprinting to events"""
        session_id = event.get('session', 'unknown')
        
        # Track session start time for latency calculation
        if session_id not in self.session_start_times:
            self.session_start_times[session_id] = time.time()
        
        # Calculate latency (time since session start)
        latency_ms = int((time.time() - self.session_start_times[session_id]) * 1000)
        
        # Add telemetry data
        event['telemetry'] = {
            'session_id': session_id,
            'timestamp': datetime.utcnow().isoformat(),
            'latency_ms': latency_ms,
            'tty_width': event.get('width', 80),
            'tty_height': event.get('height', 24),
            'fingerprint': self.calculate_fingerprint(event)
        }
        
        return event
    
    def calculate_fingerprint(self, event):
        """Calculate behavioral fingerprint"""
        # Fast commands with no think time = likely bot
        latency = event.get('telemetry', {}).get('latency_ms', 0)
        
        if latency < 100:
            return 'automated_scanner'
        elif latency < 1000:
            return 'scripted_attack'
        else:
            return 'human_operator'

if __name__ == "__main__":
    enricher = TelemetryEnricher()
    
    # Test event
    test_event = {
        'session': 'test123',
        'eventid': 'cowrie.command.input',
        'input': 'whoami',
        'width': 120,
        'height': 30
    }
    
    enriched = enricher.enrich_event(test_event)
    print(json.dumps(enriched, indent=2))

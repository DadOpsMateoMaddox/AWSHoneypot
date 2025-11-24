#!/usr/bin/env python3
"""
Cowrie JSON to PCAP Converter
Converts Cowrie honeypot JSON logs to PCAP format for Wireshark analysis
"""

import json
import sys
import argparse
from datetime import datetime
from scapy.all import *

def json_to_pcap(json_file, pcap_file):
    """Convert Cowrie JSON logs to PCAP format"""
    
    packets = []
    
    try:
        with open(json_file, 'r') as f:
            for line_num, line in enumerate(f, 1):
                try:
                    log_entry = json.loads(line.strip())
                    
                    # Extract basic info
                    src_ip = log_entry.get('src_ip', '0.0.0.0')
                    dst_ip = '44.218.220.47'  # Honeypot IP
                    src_port = log_entry.get('src_port', 0)
                    dst_port = log_entry.get('dst_port', 2222)
                    timestamp = log_entry.get('timestamp', '')
                    
                    # Convert timestamp
                    try:
                        ts = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                        epoch_time = ts.timestamp()
                    except:
                        epoch_time = time.time()
                    
                    # Create TCP packet based on event type
                    event_id = log_entry.get('eventid', '')
                    
                    if event_id == 'cowrie.session.connect':
                        # TCP SYN packet
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='S')
                        pkt.time = epoch_time
                        packets.append(pkt)
                        
                    elif event_id == 'cowrie.login.success':
                        # SSH authentication success
                        username = log_entry.get('username', '')
                        password = log_entry.get('password', '')
                        payload = f"SSH-2.0-OpenSSH_6.0p1 Login: {username}:{password}"
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='PA') / Raw(load=payload)
                        pkt.time = epoch_time
                        packets.append(pkt)
                        
                    elif event_id == 'cowrie.command.input':
                        # Command execution
                        command = log_entry.get('input', '')
                        payload = f"CMD: {command}"
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='PA') / Raw(load=payload)
                        pkt.time = epoch_time
                        packets.append(pkt)
                        
                    elif event_id == 'cowrie.session.file_download':
                        # File download
                        url = log_entry.get('url', '')
                        filename = log_entry.get('outfile', '')
                        payload = f"DOWNLOAD: {url} -> {filename}"
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='PA') / Raw(load=payload)
                        pkt.time = epoch_time
                        packets.append(pkt)
                        
                    elif event_id == 'cowrie.session.closed':
                        # TCP FIN packet
                        pkt = IP(src=src_ip, dst=dst_ip) / TCP(sport=src_port, dport=dst_port, flags='FA')
                        pkt.time = epoch_time
                        packets.append(pkt)
                        
                except json.JSONDecodeError:
                    print(f"Warning: Skipping invalid JSON on line {line_num}")
                    continue
                except Exception as e:
                    print(f"Warning: Error processing line {line_num}: {e}")
                    continue
        
        # Write packets to PCAP file
        if packets:
            wrpcap(pcap_file, packets)
            print(f"Successfully converted {len(packets)} packets to {pcap_file}")
        else:
            print("No valid packets found in JSON file")
            
    except FileNotFoundError:
        print(f"Error: JSON file '{json_file}' not found")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Convert Cowrie JSON logs to PCAP format')
    parser.add_argument('json_file', nargs='?', default='/opt/cowrie/var/log/cowrie/cowrie.json',
                       help='Input JSON log file (default: /opt/cowrie/var/log/cowrie/cowrie.json)')
    parser.add_argument('pcap_file', nargs='?', default='/tmp/cowrie_traffic.pcap',
                       help='Output PCAP file (default: /tmp/cowrie_traffic.pcap)')
    
    args = parser.parse_args()
    
    print(f"Converting {args.json_file} to {args.pcap_file}...")
    json_to_pcap(args.json_file, args.pcap_file)

if __name__ == '__main__':
    main()
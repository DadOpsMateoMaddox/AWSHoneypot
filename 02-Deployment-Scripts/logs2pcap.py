#!/usr/bin/env python3
"""
logs2pcap - Convert Cowrie honeypot JSON logs to PCAP format
Part of the AIT670 CerberusMesh Honeypot Project

This script converts Cowrie JSON log files into PCAP format for network analysis
with tools like Wireshark. It creates synthetic network packets that represent
the SSH sessions and commands executed by attackers.

Usage:
    python3 logs2pcap.py /opt/cowrie/var/log/cowrie/cowrie.json -o output.pcap
    python3 logs2pcap.py cowrie.log --max-packets 500 -o analysis.pcap

Features:
- Converts SSH connections, logins, commands, and file transfers to PCAP
- Creates realistic network packet structure for Wireshark analysis
- Supports filtering by event types and IP addresses
- Rate limiting and error handling for large log files
"""

import json
import sys
import struct
import time
from datetime import datetime
import argparse
import os
import ipaddress

class PCAPWriter:
    """Writes network packets in PCAP format for Wireshark analysis"""
    
    def __init__(self, filename):
        self.filename = filename
        self.file = open(filename, "wb")
        self.write_global_header()
    
    def write_global_header(self):
        """Write PCAP global header with magic number and metadata"""
        # PCAP Global Header Format:
        # Magic: 0xa1b2c3d4, Version: 2.4, Timezone: 0, Accuracy: 0, Max Length: 65535, Link Type: Ethernet
        header = struct.pack("<LHHLLLL", 
                           0xa1b2c3d4,  # magic number (little endian)
                           2,           # version major
                           4,           # version minor  
                           0,           # timezone offset (UTC)
                           0,           # timestamp accuracy
                           65535,       # max packet length
                           1)           # data link type (1 = Ethernet)
        self.file.write(header)
    
    def write_packet(self, timestamp, src_ip, dst_ip, src_port, dst_port, data, protocol="tcp"):
        """Write a network packet to the PCAP file"""
        try:
            # Convert timestamp to seconds and microseconds for PCAP format
            if isinstance(timestamp, str):
                # Handle ISO format timestamps from Cowrie logs
                dt = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
                ts = dt.timestamp()
            else:
                ts = timestamp
            
            ts_sec = int(ts)
            ts_usec = int((ts - ts_sec) * 1000000)
            
            # Create Ethernet header (14 bytes)
            # Destination MAC (6) + Source MAC (6) + EtherType (2) = 14 bytes
            eth_header = (b"\x00\x01\x02\x03\x04\x05"  # Dst MAC (fake)
                         + b"\x06\x07\x08\x09\x0a\x0b"  # Src MAC (fake)
                         + b"\x08\x00")                   # EtherType (IPv4)
            
            # Create IP header (20 bytes minimum)
            ip_src = self.ip_to_bytes(src_ip)
            ip_dst = self.ip_to_bytes(dst_ip)
            
            # Calculate total IP packet length (IP header + TCP header + data)
            total_length = 20 + 20 + len(data.encode("utf-8", errors="ignore"))
            
            ip_header = (b"\x45\x00"                              # Version (4) + IHL (5) + ToS (0)
                        + struct.pack(">H", total_length)          # Total Length
                        + b"\x00\x01"                             # Identification
                        + b"\x40\x00"                             # Flags (Don't Fragment) + Fragment Offset
                        + b"\x40\x06"                             # TTL (64) + Protocol (6 = TCP)
                        + b"\x00\x00"                             # Header Checksum (0 for simplicity)
                        + ip_src + ip_dst)                         # Source + Destination IP
            
            # Create TCP header (20 bytes minimum)
            tcp_header = (struct.pack(">HH", src_port, dst_port)   # Source + Destination Port
                         + b"\x00\x00\x00\x01"                    # Sequence Number
                         + b"\x00\x00\x00\x00"                    # Acknowledgment Number
                         + b"\x50\x18"                            # Header Length (5*4=20) + Flags (PSH+ACK)
                         + b"\x20\x00"                            # Window Size
                         + b"\x00\x00"                            # Checksum (0 for simplicity)
                         + b"\x00\x00")                           # Urgent Pointer
            
            # Combine all packet components
            payload = data.encode("utf-8", errors="ignore")
            packet_data = eth_header + ip_header + tcp_header + payload
            packet_len = len(packet_data)
            
            # Write PCAP packet header (timestamp + captured length + original length)
            packet_header = struct.pack("<LLLL", ts_sec, ts_usec, packet_len, packet_len)
            self.file.write(packet_header)
            self.file.write(packet_data)
            
        except Exception as e:
            print(f"⚠️  Error writing packet: {e}")
    
    def ip_to_bytes(self, ip_str):
        """Convert IP address string to 4-byte binary format"""
        try:
            # Validate and convert IP address
            ip = ipaddress.IPv4Address(ip_str)
            return ip.packed
        except:
            # Return localhost if invalid IP
            return b"\x7f\x00\x00\x01"
    
    def close(self):
        """Close the PCAP file"""
        if self.file:
            self.file.close()

def parse_cowrie_logs(log_file, pcap_file, max_packets=1000, event_filter=None, ip_filter=None, verbose=False):
    """
    Parse Cowrie JSON logs and convert interesting events to PCAP format
    
    Args:
        log_file: Path to Cowrie JSON log file
        pcap_file: Output PCAP file path
        max_packets: Maximum number of packets to convert
        event_filter: List of event types to include (None = all)
        ip_filter: IP address to focus on (None = all IPs)
        verbose: Enable detailed output
    """
    
    print(f"🔄 Converting Cowrie logs to PCAP format")
    print(f"📄 Input:  {log_file}")
    print(f"📦 Output: {pcap_file}")
    print(f"📊 Max packets: {max_packets}")
    
    # Initialize PCAP writer
    pcap = PCAPWriter(pcap_file)
    packet_count = 0
    line_count = 0
    honeypot_ip = "172.31.21.182"  # Default honeypot internal IP
    
    # Event type counters
    event_stats = {}
    
    try:
        with open(log_file, "r") as f:
            for line_num, line in enumerate(f, 1):
                line_count += 1
                
                # Stop if we've reached the packet limit
                if packet_count >= max_packets:
                    print(f"⚠️  Reached maximum packet limit ({max_packets})")
                    break
                
                # Show progress for large files
                if line_count % 1000 == 0 and verbose:
                    print(f"📖 Processed {line_count} log entries, created {packet_count} packets")
                
                try:
                    log_entry = json.loads(line.strip())
                    event_id = log_entry.get("eventid", "")
                    timestamp = log_entry.get("timestamp", "")
                    src_ip = log_entry.get("src_ip", "0.0.0.0")
                    
                    # Update statistics
                    event_stats[event_id] = event_stats.get(event_id, 0) + 1
                    
                    # Apply IP filter if specified
                    if ip_filter and src_ip != ip_filter:
                        continue
                    
                    # Apply event filter if specified
                    if event_filter and event_id not in event_filter:
                        continue
                    
                    # Convert different Cowrie events to network packets
                    if event_id == "cowrie.session.connect":
                        # New SSH connection
                        dst_ip = log_entry.get("dst_ip", honeypot_ip)
                        src_port = log_entry.get("src_port", 0)
                        dst_port = log_entry.get("dst_port", 2222)
                        protocol = log_entry.get("protocol", "ssh")
                        
                        data = f"SSH-2.0-OpenSSH_Connection_from_{src_ip}:{src_port}_to_{dst_ip}:{dst_port}_protocol_{protocol}"
                        pcap.write_packet(timestamp, src_ip, dst_ip, src_port, dst_port, data)
                        packet_count += 1
                        
                    elif event_id == "cowrie.login.success":
                        # Successful authentication - CRITICAL EVENT
                        username = log_entry.get("username", "unknown")
                        password = log_entry.get("password", "unknown")
                        data = f"LOGIN_SUCCESS:{username}:{password}"
                        pcap.write_packet(timestamp, src_ip, honeypot_ip, 12345, 2222, data)
                        packet_count += 1
                        
                    elif event_id == "cowrie.login.failed":
                        # Failed authentication attempt
                        username = log_entry.get("username", "unknown") 
                        password = log_entry.get("password", "unknown")
                        data = f"LOGIN_FAILED:{username}:{password}"
                        pcap.write_packet(timestamp, src_ip, honeypot_ip, 12345, 2222, data)
                        packet_count += 1
                        
                    elif event_id == "cowrie.command.input":
                        # Command execution - very important for analysis
                        command = log_entry.get("input", "")
                        session = log_entry.get("session", "unknown")
                        data = f"COMMAND_EXEC:{command}"
                        pcap.write_packet(timestamp, src_ip, honeypot_ip, 12346, 2222, data)
                        packet_count += 1
                        
                    elif event_id == "cowrie.session.file_download":
                        # File download attempt - potential data exfiltration
                        url = log_entry.get("url", "")
                        filename = log_entry.get("filename", log_entry.get("outfile", "unknown"))
                        data = f"FILE_DOWNLOAD:{filename}:{url}"
                        pcap.write_packet(timestamp, src_ip, honeypot_ip, 12347, 2222, data)
                        packet_count += 1
                        
                    elif event_id == "cowrie.session.file_upload":
                        # File upload - potential malware installation
                        filename = log_entry.get("filename", "unknown")
                        data = f"FILE_UPLOAD:{filename}"
                        pcap.write_packet(timestamp, src_ip, honeypot_ip, 12348, 2222, data)
                        packet_count += 1
                        
                    elif event_id == "cowrie.client.version":
                        # SSH client version information
                        version = log_entry.get("version", "unknown")
                        data = f"SSH_CLIENT_VERSION:{version}"
                        pcap.write_packet(timestamp, src_ip, honeypot_ip, 12349, 2222, data)
                        packet_count += 1
                        
                    elif event_id == "cowrie.session.closed":
                        # Session termination
                        duration = log_entry.get("duration", 0)
                        data = f"SESSION_CLOSED:duration_{duration}s"
                        pcap.write_packet(timestamp, src_ip, honeypot_ip, 12350, 2222, data)
                        packet_count += 1
                        
                except json.JSONDecodeError:
                    if verbose:
                        print(f"⚠️  Skipping invalid JSON on line {line_num}")
                    continue
                except Exception as e:
                    if verbose:
                        print(f"⚠️  Error processing line {line_num}: {e}")
                    continue
    
    except FileNotFoundError:
        print(f"❌ Log file not found: {log_file}")
        return False, {}
    except Exception as e:
        print(f"❌ Error reading log file: {e}")
        return False, {}
    
    finally:
        pcap.close()
    
    # Print conversion summary
    print(f"\n✅ Conversion completed successfully!")
    print(f"📊 Statistics:")
    print(f"   • Total log entries processed: {line_count}")
    print(f"   • Network packets created: {packet_count}")
    print(f"   • Output file: {pcap_file}")
    print(f"   • File size: {os.path.getsize(pcap_file) if os.path.exists(pcap_file) else 0} bytes")
    
    if verbose and event_stats:
        print(f"\n📈 Event type breakdown:")
        for event_type, count in sorted(event_stats.items(), key=lambda x: x[1], reverse=True):
            print(f"   • {event_type}: {count}")
    
    return True, event_stats

def main():
    parser = argparse.ArgumentParser(
        description="Convert Cowrie honeypot JSON logs to PCAP format for network analysis",
        epilog="""
Examples:
  python3 logs2pcap.py /opt/cowrie/var/log/cowrie/cowrie.json
  python3 logs2pcap.py cowrie.log -o analysis.pcap --max-packets 500
  python3 logs2pcap.py cowrie.log --ip-filter 192.168.1.100 --verbose
  python3 logs2pcap.py cowrie.log --events login.success,command.input
        """,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument("input", help="Input Cowrie JSON log file")
    parser.add_argument("-o", "--output", help="Output PCAP file", default="cowrie_converted.pcap")
    parser.add_argument("-m", "--max-packets", type=int, default=1000, 
                       help="Maximum number of packets to convert (default: 1000)")
    parser.add_argument("-e", "--events", help="Comma-separated list of event types to include")
    parser.add_argument("-i", "--ip-filter", help="Only process events from this IP address")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
    parser.add_argument("--version", action="version", version="logs2pcap 1.0 - AIT670 CerberusMesh Project")
    
    args = parser.parse_args()
    
    # Validate input file
    if not os.path.exists(args.input):
        print(f"❌ Input file does not exist: {args.input}")
        sys.exit(1)
    
    # Parse event filter
    event_filter = None
    if args.events:
        event_filter = ["cowrie." + e.strip() if not e.startswith("cowrie.") else e.strip() 
                       for e in args.events.split(",")]
        if args.verbose:
            print(f"🔍 Event filter: {event_filter}")
    
    # Validate IP filter
    if args.ip_filter:
        try:
            ipaddress.IPv4Address(args.ip_filter)
            if args.verbose:
                print(f"🔍 IP filter: {args.ip_filter}")
        except:
            print(f"❌ Invalid IP address: {args.ip_filter}")
            sys.exit(1)
    
    # Create output directory if needed
    output_dir = os.path.dirname(args.output)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
        if args.verbose:
            print(f"📁 Created output directory: {output_dir}")
    
    # Perform conversion
    success, stats = parse_cowrie_logs(
        args.input, 
        args.output, 
        args.max_packets,
        event_filter,
        args.ip_filter,
        args.verbose
    )
    
    if success:
        print(f"\n🎉 SUCCESS! PCAP file ready for analysis")
        print(f"🔬 Next steps:")
        print(f"   • Open in Wireshark: wireshark {args.output}")
        print(f"   • Command line analysis: tcpdump -r {args.output}")
        print(f"   • Network analysis: tshark -r {args.output}")
        sys.exit(0)
    else:
        print("❌ Conversion failed - check error messages above")
        sys.exit(1)

if __name__ == "__main__":
    main()
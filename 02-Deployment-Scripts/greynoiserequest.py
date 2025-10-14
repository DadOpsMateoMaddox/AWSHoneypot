#!/usr/bin/env python3
"""
greynoiserequest.py - GreyNoise IP lookup example

GreyNoise identifies IPs engaged in mass internet scanning vs. targeted attacks.
- classification: "benign" (research), "malicious", "unknown"
- seen: True if IP is actively scanning the internet
- noise: True if internet background noise (not targeting you specifically)
"""

import requests
import json
import sys

def query_greynoise(ip_address, api_key=None):
    """
    Query GreyNoise API for IP classification.
    
    Args:
        ip_address: IP to lookup
        api_key: GreyNoise API key (optional for community API)
    
    Returns:
        Dict with classification data
    """
    # Use multi-IP endpoint (better for integration)
    url = "https://api.greynoise.io/v3/ip"
    
    headers = {
        "accept": "application/json",
        "content-type": "application/json"
    }
    
    # Add API key if provided (for full API access)
    if api_key:
        headers["key"] = api_key
    
    # Request body with IP list (can check multiple IPs)
    payload = {
        "ips": [ip_address]
    }
    
    try:
        response = requests.post(
            url,
            headers=headers,
            json=payload,
            timeout=5
        )
        response.raise_for_status()
        
        data = response.json()
        
        # Extract first result
        if data and len(data) > 0:
            ip_data = data[0]
            
            print(f"\n{'='*60}")
            print(f"GreyNoise Report for {ip_address}")
            print(f"{'='*60}")
            
            # Check if IP found
            if ip_data.get("error") or ip_data.get("seen") == False:
                print("❌ IP not found in GreyNoise database")
                print("   (This IP is not engaged in mass internet scanning)")
                return None
            
            # Classification
            classification = ip_data.get("classification", "unknown")
            seen = ip_data.get("seen", False)
            
            print(f"\n🔍 Classification: {classification.upper()}")
            print(f"   Seen scanning: {'Yes' if seen else 'No'}")
            
            if classification == "malicious":
                print("   ⚠️  Known malicious scanner")
            elif classification == "benign":
                print("   ℹ️  Benign/research scanner")
            
            # Actor info
            actor = ip_data.get("actor")
            if actor:
                print(f"\n👤 Actor: {actor}")
            
            # Tags (what they're scanning for)
            tags = ip_data.get("tags", [])
            if tags:
                print(f"\n🏷️  Tags: {', '.join(tags)}")
            
            # Location
            metadata = ip_data.get("metadata", {})
            if metadata:
                country = metadata.get("country")
                city = metadata.get("city")
                asn = metadata.get("asn")
                org = metadata.get("organization")
                
                if country:
                    location = f"{city}, {country}" if city else country
                    print(f"\n🌍 Location: {location}")
                if org:
                    print(f"   Organization: {org} (AS{asn})")
            
            # Raw data (scanning activity)
            raw_data = ip_data.get("raw_data", {})
            if raw_data:
                scan_data = raw_data.get("scan", [])
                if scan_data:
                    print(f"\n🔎 Scanning Activity:")
                    for scan in scan_data[:5]:  # Show first 5
                        port = scan.get("port")
                        protocol = scan.get("protocol", "tcp")
                        print(f"   - Port {port}/{protocol}")
            
            # Last seen
            last_seen = ip_data.get("last_seen")
            if last_seen:
                print(f"\n⏰ Last seen: {last_seen}")
            
            print(f"\n{'='*60}\n")
            
            return ip_data
        
        return None
        
    except requests.RequestException as e:
        print(f"❌ API request failed: {e}")
        return None
    except json.JSONDecodeError:
        print(f"❌ Invalid JSON response")
        return None


def main():
    """Command-line interface"""
    if len(sys.argv) < 2:
        print("Usage: python3 greynoiserequest.py <ip_address> [api_key]")
        print("\nExample:")
        print("  python3 greynoiserequest.py 8.8.8.8")
        print("  python3 greynoiserequest.py 1.2.3.4 your_api_key_here")
        sys.exit(1)
    
    ip = sys.argv[1]
    api_key = sys.argv[2] if len(sys.argv) > 2 else None
    
    query_greynoise(ip, api_key)


if __name__ == "__main__":
    main()
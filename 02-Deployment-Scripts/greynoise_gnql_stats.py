#!/usr/bin/env python3
"""
greynoise_gnql_stats.py - GreyNoise GNQL Statistics Tool

Query GreyNoise for aggregate statistics about attackers hitting your honeypot.
Uses GNQL (GreyNoise Query Language) to get:
- Top attacking organizations
- Top threat actors
- Top tags (attack types)
- Top countries
- Top ASNs
- Operating systems
- Classifications (malicious/benign)

Perfect for honeypot analysis and threat intelligence reporting!
"""

import requests
import json
import sys
import os
from datetime import datetime, timedelta
from typing import Dict, Optional

def query_gnql_stats(gnql_query: str, api_key: str, count: int = 100) -> Optional[Dict]:
    """
    Query GreyNoise GNQL Stats API for aggregate statistics.
    
    Args:
        gnql_query: GNQL query string (e.g., "classification:malicious tags:SSH*")
        api_key: GreyNoise API key
        count: Number of top results per category (1-10000)
    
    Returns:
        Dict with aggregate statistics
    """
    url = "https://api.greynoise.io/v2/experimental/gnql/stats"
    
    headers = {
        "key": api_key,
        "accept": "application/json"
    }
    
    params = {
        "query": gnql_query,
        "count": min(count, 10000)  # Max 10,000
    }
    
    try:
        response = requests.get(
            url,
            headers=headers,
            params=params,
            timeout=10
        )
        response.raise_for_status()
        return response.json()
        
    except requests.RequestException as e:
        print(f"❌ API request failed: {e}")
        return None
    except json.JSONDecodeError:
        print(f"❌ Invalid JSON response")
        return None


def print_stats(stats: Dict):
    """Pretty print GNQL statistics"""
    
    print(f"\n{'='*80}")
    print(f"GreyNoise GNQL Statistics Report")
    print(f"{'='*80}")
    
    # Query info
    query = stats.get("query", "N/A")
    count = stats.get("count", 0)
    print(f"\n📊 Query: {query}")
    print(f"📈 Total Results: {count:,}")
    
    data = stats.get("stats", {})
    
    # Classifications
    print(f"\n{'─'*80}")
    print("🔍 CLASSIFICATIONS")
    print(f"{'─'*80}")
    classifications = data.get("classifications", [])
    for item in classifications[:10]:
        classification = item.get("classification", "unknown")
        count = item.get("count", 0)
        emoji = "🔴" if classification == "malicious" else "🟢" if classification == "benign" else "⚪"
        print(f"  {emoji} {classification.upper():20} {count:>8,} IPs")
    
    # Top Organizations
    print(f"\n{'─'*80}")
    print("🏢 TOP ORGANIZATIONS")
    print(f"{'─'*80}")
    orgs = data.get("organizations", [])
    for idx, item in enumerate(orgs[:10], 1):
        org = item.get("organization", "Unknown")
        count = item.get("count", 0)
        print(f"  {idx:2}. {org[:50]:50} {count:>8,} IPs")
    
    # Top Actors
    print(f"\n{'─'*80}")
    print("👤 TOP THREAT ACTORS")
    print(f"{'─'*80}")
    actors = data.get("actors", [])
    if actors:
        for idx, item in enumerate(actors[:10], 1):
            actor = item.get("actor", "Unknown")
            count = item.get("count", 0)
            print(f"  {idx:2}. {actor[:50]:50} {count:>8,} IPs")
    else:
        print("  No actor attribution available")
    
    # Top Tags (Attack Types)
    print(f"\n{'─'*80}")
    print("🏷️  TOP ATTACK TAGS")
    print(f"{'─'*80}")
    tags = data.get("tags", [])
    for idx, item in enumerate(tags[:15], 1):
        tag = item.get("tag", "Unknown")
        count = item.get("count", 0)
        print(f"  {idx:2}. {tag[:50]:50} {count:>8,} IPs")
    
    # Top Countries
    print(f"\n{'─'*80}")
    print("🌍 TOP COUNTRIES")
    print(f"{'─'*80}")
    countries = data.get("countries", [])
    for idx, item in enumerate(countries[:15], 1):
        country = item.get("country", "Unknown")
        count = item.get("count", 0)
        print(f"  {idx:2}. {country[:50]:50} {count:>8,} IPs")
    
    # Top ASNs
    print(f"\n{'─'*80}")
    print("📡 TOP ASNs")
    print(f"{'─'*80}")
    asns = data.get("asns", [])
    for idx, item in enumerate(asns[:10], 1):
        asn = item.get("asn", "Unknown")
        count = item.get("count", 0)
        print(f"  {idx:2}. AS{asn:20} {count:>8,} IPs")
    
    # Operating Systems
    print(f"\n{'─'*80}")
    print("💻 TOP OPERATING SYSTEMS")
    print(f"{'─'*80}")
    oses = data.get("operating_systems", [])
    for idx, item in enumerate(oses[:10], 1):
        os = item.get("operating_system", "Unknown")
        count = item.get("count", 0)
        print(f"  {idx:2}. {os[:50]:50} {count:>8,} IPs")
    
    print(f"\n{'='*80}\n")


def honeypot_analysis_queries():
    """Predefined GNQL queries for honeypot analysis"""
    return {
        "ssh_bruteforce": {
            "query": 'tags:"SSH Bruteforcer" classification:malicious',
            "description": "SSH Bruteforce Attackers (Last 30 days)"
        },
        "telnet_attacks": {
            "query": 'tags:"Telnet Scanner" OR tags:"Telnet Bruteforcer"',
            "description": "Telnet Attacks (Mirai, IoT botnets)"
        },
        "mirai_botnet": {
            "query": 'tags:Mirai classification:malicious',
            "description": "Mirai Botnet Activity"
        },
        "web_attacks": {
            "query": 'tags:"Web Crawler" OR tags:"Web Scanner" classification:malicious',
            "description": "Malicious Web Scanners"
        },
        "port_scanners": {
            "query": 'tags:"Port Scanner" OR tags:"Network Scanner"',
            "description": "Port/Network Scanners"
        },
        "recent_malicious": {
            "query": f'last_seen:>{(datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d")} classification:malicious',
            "description": "Malicious IPs Active in Last 7 Days"
        },
        "china_attacks": {
            "query": 'country:CN classification:malicious',
            "description": "Malicious Activity from China"
        },
        "russia_attacks": {
            "query": 'country:RU classification:malicious',
            "description": "Malicious Activity from Russia"
        },
        "vpn_proxies": {
            "query": 'tags:"VPN" OR tags:"Proxy" classification:malicious',
            "description": "Attacks via VPN/Proxy Services"
        },
        "tor_exit_nodes": {
            "query": 'tags:"Tor" classification:malicious',
            "description": "Malicious Tor Exit Node Activity"
        }
    }


def main():
    """Command-line interface"""
    
    # Check for API key
    api_key = os.getenv("GREYNOISE_KEY")
    if not api_key and len(sys.argv) < 2:
        print("GreyNoise GNQL Stats Tool\n")
        print("Usage:")
        print('  python3 greynoise_gnql_stats.py "GNQL_QUERY" [API_KEY]')
        print('  python3 greynoise_gnql_stats.py --preset PRESET_NAME [API_KEY]')
        print("\nEnvironment:")
        print("  Export GREYNOISE_KEY=your_key or pass as second argument")
        print("\nPreset Queries:")
        for name, info in honeypot_analysis_queries().items():
            print(f"  --preset {name:20} - {info['description']}")
        print("\nGNQL Examples:")
        print('  "classification:malicious tags:SSH*"')
        print('  "country:CN classification:malicious"')
        print('  "last_seen:>2025-10-01 tags:Mirai"')
        print('  "organization:DigitalOcean classification:malicious"')
        print("\nDocumentation: https://docs.greynoise.io/docs/using-gnql")
        sys.exit(1)
    
    # Parse arguments
    if sys.argv[1] == "--preset":
        if len(sys.argv) < 3:
            print("❌ Error: Preset name required")
            print("Available presets:", ", ".join(honeypot_analysis_queries().keys()))
            sys.exit(1)
        
        preset_name = sys.argv[2]
        presets = honeypot_analysis_queries()
        
        if preset_name not in presets:
            print(f"❌ Error: Unknown preset '{preset_name}'")
            print("Available presets:", ", ".join(presets.keys()))
            sys.exit(1)
        
        query_info = presets[preset_name]
        query = query_info["query"]
        print(f"\n🔍 Using preset: {query_info['description']}")
        print(f"📝 Query: {query}\n")
        
        # API key from env or arg
        if len(sys.argv) > 3:
            api_key = sys.argv[3]
    else:
        # Custom query
        query = sys.argv[1]
        
        if len(sys.argv) > 2:
            api_key = sys.argv[2]
    
    if not api_key:
        print("❌ Error: GREYNOISE_KEY not found in environment")
        print("Set: export GREYNOISE_KEY=your_key")
        print("Or pass as argument: python3 greynoise_gnql_stats.py 'query' your_key")
        sys.exit(1)
    
    # Query GNQL Stats
    print(f"🔄 Querying GreyNoise GNQL Stats API...")
    stats = query_gnql_stats(query, api_key, count=100)
    
    if stats:
        print_stats(stats)
        
        # Export option
        print("💾 Export to JSON:")
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"greynoise_stats_{timestamp}.json"
        print(f"   {filename}")
        
        with open(filename, 'w') as f:
            json.dump(stats, f, indent=2)
        
        print(f"\n✅ Report saved to {filename}")
    else:
        print("❌ Failed to retrieve statistics")
        sys.exit(1)


if __name__ == "__main__":
    main()

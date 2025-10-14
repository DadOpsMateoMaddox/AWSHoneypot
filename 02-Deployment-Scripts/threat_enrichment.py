#!/usr/bin/env python3
"""
threat_enrichment.py

Threat intelligence enrichment for Cowrie honeypot alerts.
Queries multiple threat intel APIs with caching and rate limiting.

APIs supported:
- AbuseIPDB: IP reputation and abuse reports
- AlienVault OTX: Open threat exchange indicators
- IPInfo: Geolocation and ISP data
- VirusTotal: IP/domain/hash reputation
- Shodan: Internet scan data

Features:
- 48-hour TTL cache to reduce API calls
- 3-second timeout per API request
- Safe error handling (continues if APIs fail)
- No enrichment mode if keys missing
"""

import os
import json
import time
import logging
from typing import Dict, Optional, Any
from datetime import datetime, timedelta
import hashlib

# Safe imports with fallbacks
try:
    import requests
except ImportError:
    requests = None
    logging.warning("requests library not installed. Install: pip install requests")

# Import our secrets loader
try:
    from secrets_loader import load_env, load_from_aws, get, validate_required, check_optional
except ImportError:
    logging.error("secrets_loader.py not found. Threat enrichment disabled.")
    def load_env(): return False
    def load_from_aws(s): return False
    def get(k, d=None): return d
    def validate_required(k): pass
    def check_optional(k): return {key: False for key in k}

logger = logging.getLogger(__name__)

# Cache configuration
CACHE_FILE = "/opt/cowrie/discord-monitor/intel_cache.json"
CACHE_TTL_HOURS = 48
API_TIMEOUT = 3  # seconds


class ThreatEnrichment:
    """Threat intelligence enrichment manager"""
    
    def __init__(self, cache_file: str = CACHE_FILE):
        self.cache_file = cache_file
        self.cache = self._load_cache()
        self.apis_available = {}
        
        # Load secrets
        load_env()
        aws_secret = os.getenv("HONEYBOMB_AWS_SECRET")
        if aws_secret:
            load_from_aws(aws_secret)
        
        # Check which APIs are available
        optional_keys = [
            "ABUSEIPDB_KEY",
            "OTX_KEY",
            "IPINFO_KEY",
            "VIRUSTOTAL_KEY",
            "SHODAN_KEY",
            "GREYNOISE_KEY"
        ]
        self.apis_available = check_optional(optional_keys)
        
        enabled = [k for k, v in self.apis_available.items() if v]
        logger.info(f"Threat enrichment initialized ({len(enabled)}/{len(optional_keys)} APIs available)")
        
        if not any(self.apis_available.values()):
            logger.warning("No threat intel API keys available. Enrichment disabled.")
    
    def _load_cache(self) -> Dict:
        """Load cached threat intel data"""
        if not os.path.exists(self.cache_file):
            return {}
        
        try:
            with open(self.cache_file, 'r') as f:
                cache = json.load(f)
            logger.debug(f"Loaded cache with {len(cache)} entries")
            return cache
        except Exception as e:
            logger.warning(f"Failed to load cache: {e}")
            return {}
    
    def _save_cache(self):
        """Save cache to disk"""
        try:
            os.makedirs(os.path.dirname(self.cache_file), exist_ok=True)
            with open(self.cache_file, 'w') as f:
                json.dump(self.cache, f, indent=2)
        except Exception as e:
            logger.error(f"Failed to save cache: {e}")
    
    def _get_from_cache(self, key: str) -> Optional[Dict]:
        """Get data from cache if not expired"""
        if key not in self.cache:
            return None
        
        entry = self.cache[key]
        cached_time = datetime.fromisoformat(entry['timestamp'])
        age = datetime.now() - cached_time
        
        if age > timedelta(hours=CACHE_TTL_HOURS):
            logger.debug(f"Cache expired for {key}")
            del self.cache[key]
            return None
        
        logger.debug(f"Cache hit for {key} (age: {age})")
        return entry['data']
    
    def _set_cache(self, key: str, data: Dict):
        """Store data in cache"""
        self.cache[key] = {
            'timestamp': datetime.now().isoformat(),
            'data': data
        }
        self._save_cache()
    
    def _safe_request(self, url: str, headers: Dict = None, params: Dict = None) -> Optional[Dict]:
        """Make HTTP request with timeout and error handling"""
        if not requests:
            return None
        
        try:
            response = requests.get(
                url,
                headers=headers or {},
                params=params or {},
                timeout=API_TIMEOUT
            )
            response.raise_for_status()
            return response.json()
        except requests.Timeout:
            logger.warning(f"API timeout: {url}")
            return None
        except requests.RequestException as e:
            logger.warning(f"API request failed: {type(e).__name__}")
            return None
        except json.JSONDecodeError:
            logger.warning(f"Invalid JSON response from {url}")
            return None
    
    def enrich_ip(self, ip_address: str) -> Dict[str, Any]:
        """
        Enrich IP address with threat intelligence from multiple sources.
        
        Args:
            ip_address: IPv4 or IPv6 address
        
        Returns:
            Dict containing enrichment data from available APIs
        """
        # Check cache first
        cache_key = f"ip:{ip_address}"
        cached = self._get_from_cache(cache_key)
        if cached:
            return cached
        
        enrichment = {
            'ip': ip_address,
            'timestamp': datetime.now().isoformat(),
            'sources': []
        }
        
        # Query each available API
        if self.apis_available.get('ABUSEIPDB_KEY'):
            abuseipdb_data = self._query_abuseipdb(ip_address)
            if abuseipdb_data:
                enrichment['abuseipdb'] = abuseipdb_data
                enrichment['sources'].append('abuseipdb')
        
        if self.apis_available.get('OTX_KEY'):
            otx_data = self._query_otx(ip_address)
            if otx_data:
                enrichment['otx'] = otx_data
                enrichment['sources'].append('otx')
        
        if self.apis_available.get('VIRUSTOTAL_KEY'):
            vt_data = self._query_virustotal_ip(ip_address)
            if vt_data:
                enrichment['virustotal'] = vt_data
                enrichment['sources'].append('virustotal')
        
        if self.apis_available.get('SHODAN_KEY'):
            shodan_data = self._query_shodan(ip_address)
            if shodan_data:
                enrichment['shodan'] = shodan_data
                enrichment['sources'].append('shodan')
        
        if self.apis_available.get('GREYNOISE_KEY'):
            greynoise_data = self._query_greynoise(ip_address)
            if greynoise_data:
                enrichment['greynoise'] = greynoise_data
                enrichment['sources'].append('greynoise')
        
        # Always try IPInfo (works without key for basic data)
        ipinfo_data = self._query_ipinfo(ip_address)
        if ipinfo_data:
            enrichment['ipinfo'] = ipinfo_data
            enrichment['sources'].append('ipinfo')
        
        # Cache the result
        self._set_cache(cache_key, enrichment)
        
        return enrichment
    
    def _query_abuseipdb(self, ip: str) -> Optional[Dict]:
        """Query AbuseIPDB for IP reputation"""
        api_key = get('ABUSEIPDB_KEY')
        if not api_key:
            return None
        
        url = 'https://api.abuseipdb.com/api/v2/check'
        headers = {
            'Key': api_key,
            'Accept': 'application/json'
        }
        params = {
            'ipAddress': ip,
            'maxAgeInDays': 90,
            'verbose': ''
        }
        
        data = self._safe_request(url, headers=headers, params=params)
        if not data or 'data' not in data:
            return None
        
        result = data['data']
        return {
            'abuse_confidence_score': result.get('abuseConfidenceScore', 0),
            'total_reports': result.get('totalReports', 0),
            'is_whitelisted': result.get('isWhitelisted', False),
            'country': result.get('countryCode'),
            'isp': result.get('isp'),
            'domain': result.get('domain')
        }
    
    def _query_otx(self, ip: str) -> Optional[Dict]:
        """Query AlienVault OTX for threat indicators"""
        api_key = get('OTX_KEY')
        if not api_key:
            return None
        
        url = f'https://otx.alienvault.com/api/v1/indicators/IPv4/{ip}/general'
        headers = {
            'X-OTX-API-KEY': api_key
        }
        
        data = self._safe_request(url, headers=headers)
        if not data:
            return None
        
        return {
            'pulse_count': data.get('pulse_info', {}).get('count', 0),
            'reputation': data.get('reputation', 0),
            'country': data.get('country_name'),
            'asn': data.get('asn')
        }
    
    def _query_virustotal_ip(self, ip: str) -> Optional[Dict]:
        """Query VirusTotal for IP analysis"""
        api_key = get('VIRUSTOTAL_KEY')
        if not api_key:
            return None
        
        url = f'https://www.virustotal.com/api/v3/ip_addresses/{ip}'
        headers = {
            'x-apikey': api_key
        }
        
        data = self._safe_request(url, headers=headers)
        if not data or 'data' not in data:
            return None
        
        attributes = data['data'].get('attributes', {})
        stats = attributes.get('last_analysis_stats', {})
        
        return {
            'malicious': stats.get('malicious', 0),
            'suspicious': stats.get('suspicious', 0),
            'harmless': stats.get('harmless', 0),
            'undetected': stats.get('undetected', 0),
            'reputation': attributes.get('reputation', 0),
            'country': attributes.get('country'),
            'asn': attributes.get('asn')
        }
    
    def _query_shodan(self, ip: str) -> Optional[Dict]:
        """Query Shodan for internet scan data"""
        api_key = get('SHODAN_KEY')
        if not api_key:
            return None
        
        url = f'https://api.shodan.io/shodan/host/{ip}'
        params = {
            'key': api_key
        }
        
        data = self._safe_request(url, params=params)
        if not data:
            return None
        
        return {
            'open_ports': data.get('ports', []),
            'vulns': list(data.get('vulns', [])),
            'tags': data.get('tags', []),
            'os': data.get('os'),
            'org': data.get('org'),
            'country': data.get('country_name')
        }
    
    def _query_ipinfo(self, ip: str) -> Optional[Dict]:
        """Query IPInfo.io for geolocation (works without key)"""
        api_key = get('IPINFO_KEY')
        
        url = f'https://ipinfo.io/{ip}/json'
        if api_key:
            url += f'?token={api_key}'
        
        data = self._safe_request(url)
        if not data:
            return None
        
        return {
            'city': data.get('city'),
            'region': data.get('region'),
            'country': data.get('country'),
            'location': data.get('loc'),
            'org': data.get('org'),
            'postal': data.get('postal'),
            'timezone': data.get('timezone')
        }
    
    def _query_greynoise(self, ip: str) -> Optional[Dict]:
        """
        Query GreyNoise for internet noise classification.
        
        GreyNoise identifies IPs engaged in mass internet scanning vs targeted attacks.
        - classification: "benign" (research), "malicious", "unknown"
        - seen: True if IP is actively scanning the internet
        - noise: True if mass internet scanning (not specifically targeting you)
        """
        api_key = get('GREYNOISE_KEY')
        if not api_key:
            return None
        
        url = 'https://api.greynoise.io/v3/ip'
        headers = {
            'key': api_key,
            'accept': 'application/json',
            'content-type': 'application/json'
        }
        payload = {
            'ips': [ip]
        }
        
        if not requests:
            return None
        
        try:
            response = requests.post(
                url,
                headers=headers,
                json=payload,
                timeout=API_TIMEOUT
            )
            response.raise_for_status()
            data = response.json()
            
            # Extract first result
            if not data or len(data) == 0:
                return None
            
            ip_data = data[0]
            
            # Check if IP found
            if ip_data.get("error") or not ip_data.get("seen"):
                return {
                    'seen': False,
                    'classification': 'unknown',
                    'noise': False,
                    'message': 'Not found in GreyNoise (not mass scanning)'
                }
            
            # Extract key fields
            result = {
                'seen': ip_data.get('seen', False),
                'classification': ip_data.get('classification', 'unknown'),
                'noise': True,  # If seen by GreyNoise, it's internet noise
                'actor': ip_data.get('actor'),
                'tags': ip_data.get('tags', []),
                'last_seen': ip_data.get('last_seen')
            }
            
            # Add metadata if available
            metadata = ip_data.get('metadata', {})
            if metadata:
                result['country'] = metadata.get('country')
                result['city'] = metadata.get('city')
                result['organization'] = metadata.get('organization')
                result['asn'] = metadata.get('asn')
            
            # Add scan activity summary
            raw_data = ip_data.get('raw_data', {})
            if raw_data:
                scan_data = raw_data.get('scan', [])
                if scan_data:
                    # Extract ports being scanned
                    ports = [s.get('port') for s in scan_data if s.get('port')]
                    result['scanned_ports'] = sorted(set(ports))[:10]  # Top 10 ports
            
            return result
            
        except requests.Timeout:
            logger.warning(f"GreyNoise API timeout")
            return None
        except requests.RequestException as e:
            logger.warning(f"GreyNoise API request failed: {type(e).__name__}")
            return None
        except (json.JSONDecodeError, IndexError, KeyError) as e:
            logger.warning(f"GreyNoise response parsing failed: {e}")
            return None
    
    def format_for_discord(self, enrichment: Dict) -> str:
        """
        Format enrichment data for Discord embed.
        
        Args:
            enrichment: Output from enrich_ip()
        
        Returns:
            Formatted string for Discord message
        """
        if not enrichment.get('sources'):
            return "⚠️ No threat intelligence available"
        
        lines = []
        lines.append(f"**Threat Intel for {enrichment['ip']}**")
        lines.append(f"*Sources: {', '.join(enrichment['sources'])}*\n")
        
        # GreyNoise (show first - most important for honeypots)
        if 'greynoise' in enrichment:
            gn = enrichment['greynoise']
            if gn['seen']:
                classification = gn['classification']
                if classification == 'malicious':
                    emoji = "🔴"
                elif classification == 'benign':
                    emoji = "🟢"
                else:
                    emoji = "⚪"
                
                lines.append(f"{emoji} **GreyNoise**: {classification.upper()} mass scanner")
                
                if gn.get('actor'):
                    lines.append(f"   👤 Actor: {gn['actor']}")
                
                if gn.get('tags'):
                    tags_str = ', '.join(gn['tags'][:3])  # Show first 3 tags
                    lines.append(f"   🏷️ Tags: {tags_str}")
                
                if gn.get('scanned_ports'):
                    ports_str = ', '.join(map(str, gn['scanned_ports'][:5]))
                    lines.append(f"   🔍 Scanning ports: {ports_str}")
            else:
                lines.append("🟢 **GreyNoise**: Not mass scanning (targeted attack?)")
        
        # AbuseIPDB
        if 'abuseipdb' in enrichment:
            abuse = enrichment['abuseipdb']
            score = abuse['abuse_confidence_score']
            emoji = "🔴" if score > 75 else "🟡" if score > 25 else "🟢"
            lines.append(f"{emoji} **AbuseIPDB**: {score}% confidence, {abuse['total_reports']} reports")
        
        # VirusTotal
        if 'virustotal' in enrichment:
            vt = enrichment['virustotal']
            if vt['malicious'] > 0:
                lines.append(f"🔴 **VirusTotal**: {vt['malicious']} malicious, {vt['suspicious']} suspicious")
            else:
                lines.append(f"🟢 **VirusTotal**: Clean ({vt['harmless']} harmless)")
        
        # OTX
        if 'otx' in enrichment:
            otx = enrichment['otx']
            if otx['pulse_count'] > 0:
                lines.append(f"⚠️ **OTX**: Found in {otx['pulse_count']} threat pulses")
        
        # Shodan
        if 'shodan' in enrichment:
            shodan = enrichment['shodan']
            if shodan.get('open_ports'):
                ports_str = ', '.join(map(str, shodan['open_ports'][:5]))
                lines.append(f"🔍 **Shodan**: Ports {ports_str}")
            if shodan.get('vulns'):
                lines.append(f"⚠️ **Vulns**: {len(shodan['vulns'])} CVEs")
        
        # Geolocation
        if 'ipinfo' in enrichment:
            geo = enrichment['ipinfo']
            location = f"{geo.get('city', 'Unknown')}, {geo.get('country', 'Unknown')}"
            lines.append(f"🌍 **Location**: {location}")
            if geo.get('org'):
                lines.append(f"🏢 **Org**: {geo['org']}")
        
        return '\n'.join(lines)


# Singleton instance
_enrichment_instance = None

def get_enrichment() -> ThreatEnrichment:
    """Get or create threat enrichment singleton"""
    global _enrichment_instance
    if _enrichment_instance is None:
        _enrichment_instance = ThreatEnrichment()
    return _enrichment_instance


# CLI test
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python threat_enrichment.py <ip_address>")
        sys.exit(1)
    
    test_ip = sys.argv[1]
    
    print(f"\n{'='*60}")
    print(f"Testing threat enrichment for: {test_ip}")
    print(f"{'='*60}\n")
    
    enricher = ThreatEnrichment()
    result = enricher.enrich_ip(test_ip)
    
    print(json.dumps(result, indent=2))
    print("\n" + "="*60)
    print("Discord format:")
    print("="*60)
    print(enricher.format_for_discord(result))

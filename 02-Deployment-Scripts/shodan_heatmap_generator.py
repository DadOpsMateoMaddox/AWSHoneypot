#!/usr/bin/env python3
"""
Shodan Heatmap Generator - Daily attacker geolocation visualization
Generates heatmaps at midnight and posts to Discord
"""

import json
import requests
import folium
from datetime import datetime, timedelta
from collections import Counter
import os

class ShodanHeatmapGenerator:
    def __init__(self):
        self.shodan_api_key = os.getenv('SHODAN_API_KEY', 'z9W9eDodEBro84JX6CqYCbe0JgMjP8qo')
        self.discord_webhook = None
        self.load_discord_config()
    
    def load_discord_config(self):
        try:
            with open('/opt/cowrie/discord_config.json', 'r') as f:
                config = json.load(f)
                self.discord_webhook = config.get('discord_webhook_url')
        except:
            pass
    
    def get_attacker_ips_last_24h(self):
        """Extract unique attacker IPs from last 24 hours"""
        ips = []
        try:
            with open('/opt/cowrie/var/log/cowrie/cowrie.json', 'r') as f:
                yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
                for line in f:
                    if yesterday in line:
                        try:
                            event = json.loads(line.strip())
                            if 'src_ip' in event:
                                ips.append(event['src_ip'])
                        except:
                            continue
        except Exception as e:
            print(f"Error reading logs: {e}")
        
        return list(set(ips))
    
    def get_ip_geolocation(self, ip):
        """Get geolocation data from Shodan"""
        try:
            url = f"https://api.shodan.io/shodan/host/{ip}?key={self.shodan_api_key}"
            response = requests.get(url, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'ip': ip,
                    'lat': data.get('latitude'),
                    'lon': data.get('longitude'),
                    'country': data.get('country_name', 'Unknown'),
                    'city': data.get('city', 'Unknown'),
                    'org': data.get('org', 'Unknown')
                }
        except:
            pass
        return None
    
    def generate_heatmap(self, geolocations):
        """Generate folium heatmap"""
        # Create base map
        m = folium.Map(location=[20, 0], zoom_start=2, tiles='OpenStreetMap')
        
        # Add markers for each location
        for geo in geolocations:
            if geo['lat'] and geo['lon']:
                folium.CircleMarker(
                    location=[geo['lat'], geo['lon']],
                    radius=8,
                    popup=f"{geo['ip']}<br>{geo['city']}, {geo['country']}<br>{geo['org']}",
                    color='red',
                    fill=True,
                    fillColor='red',
                    fillOpacity=0.6
                ).add_to(m)
        
        # Save map
        output_file = f"/tmp/attacker_heatmap_{datetime.now().strftime('%Y%m%d')}.html"
        m.save(output_file)
        return output_file
    
    def generate_statistics(self, geolocations):
        """Generate attack statistics"""
        countries = Counter([g['country'] for g in geolocations])
        cities = Counter([g['city'] for g in geolocations])
        
        stats = f"""
**📊 24-Hour Attack Statistics**
**Date:** {datetime.now().strftime('%Y-%m-%d')}

**🌍 Top Countries:**
"""
        for country, count in countries.most_common(5):
            stats += f"• {country}: {count} attacks\n"
        
        stats += f"\n**🏙️ Top Cities:**\n"
        for city, count in cities.most_common(5):
            stats += f"• {city}: {count} attacks\n"
        
        stats += f"\n**📈 Total Unique Attackers:** {len(geolocations)}"
        
        return stats
    
    def send_to_discord(self, stats, heatmap_file):
        """Send heatmap and stats to Discord"""
        if not self.discord_webhook:
            print("Discord webhook not configured")
            return
        
        # Send statistics
        embed = {
            'title': '🗺️ Daily Attacker Heatmap Generated',
            'description': stats,
            'color': 0xff0000,
            'timestamp': datetime.utcnow().isoformat(),
            'footer': {'text': 'Shodan Geolocation Analysis'}
        }
        
        try:
            requests.post(self.discord_webhook, json={'embeds': [embed]}, timeout=10)
            print("Heatmap stats sent to Discord")
        except Exception as e:
            print(f"Failed to send to Discord: {e}")
    
    def run_daily_generation(self):
        """Main execution - run daily at midnight"""
        print(f"Starting daily heatmap generation at {datetime.now()}")
        
        # Get attacker IPs
        ips = self.get_attacker_ips_last_24h()
        print(f"Found {len(ips)} unique attacker IPs in last 24 hours")
        
        if not ips:
            print("No attackers found in last 24 hours")
            return
        
        # Get geolocation data
        geolocations = []
        for ip in ips[:50]:  # Limit to 50 to avoid API rate limits
            geo = self.get_ip_geolocation(ip)
            if geo:
                geolocations.append(geo)
        
        print(f"Retrieved geolocation for {len(geolocations)} IPs")
        
        if not geolocations:
            print("No geolocation data available")
            return
        
        # Generate heatmap
        heatmap_file = self.generate_heatmap(geolocations)
        print(f"Heatmap generated: {heatmap_file}")
        
        # Generate statistics
        stats = self.generate_statistics(geolocations)
        
        # Send to Discord
        self.send_to_discord(stats, heatmap_file)
        
        print("Daily heatmap generation complete!")

if __name__ == "__main__":
    generator = ShodanHeatmapGenerator()
    generator.run_daily_generation()

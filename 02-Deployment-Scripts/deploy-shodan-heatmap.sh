#!/bin/bash
# Deploy Shodan Heatmap Generator with Daily Cron Job

echo "🗺️ DEPLOYING SHODAN HEATMAP GENERATOR..."

# Install dependencies
echo "📦 Installing dependencies..."
sudo pip3 install folium requests

# Deploy script
echo "📁 Deploying heatmap generator..."
sudo cp shodan_heatmap_generator.py /opt/cowrie/
sudo chown cowrie:cowrie /opt/cowrie/shodan_heatmap_generator.py
sudo chmod +x /opt/cowrie/shodan_heatmap_generator.py

# Create cron job for midnight execution
echo "⏰ Setting up daily cron job (midnight UTC)..."
sudo -u cowrie bash -c "(crontab -l 2>/dev/null; echo '0 0 * * * /usr/bin/python3 /opt/cowrie/shodan_heatmap_generator.py >> /opt/cowrie/var/log/heatmap.log 2>&1') | crontab -"

# Test the script
echo "🧪 Testing heatmap generator..."
sudo -u cowrie python3 /opt/cowrie/shodan_heatmap_generator.py

echo ""
echo "✅ SHODAN HEATMAP GENERATOR DEPLOYED!"
echo "📊 Features:"
echo "   • Daily execution at midnight UTC"
echo "   • Geolocation of last 24h attackers"
echo "   • Heatmap visualization"
echo "   • Top countries and cities stats"
echo "   • Automatic Discord posting"
echo ""
echo "🔑 IMPORTANT: Set your Shodan API key:"
echo "   export SHODAN_API_KEY='your_key_here'"
echo "   Or add to /opt/cowrie/.env"
echo ""
echo "📊 View logs: tail -f /opt/cowrie/var/log/heatmap.log"
echo "🗺️ Heatmaps saved to: /tmp/attacker_heatmap_*.html"

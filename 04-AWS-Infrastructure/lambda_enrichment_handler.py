#!/usr/bin/env python3
"""
Lambda Enrichment Handler - Decoupled threat intelligence pipeline
Cowrie → SNS → Lambda → Discord + S3
"""

import os, json, time, hashlib, requests, boto3
from datetime import datetime, timezone

DISCORD_WEBHOOK = os.environ["DISCORD_WEBHOOK"]
S3_BUCKET = os.environ["S3_BUCKET"]
GREYNOISE_KEY = os.getenv("GREYNOISE_KEY", "t6UcPKF1RR1hn6eRuOsqc7X5FU8uM6ldUdcRUWA6uldMgsTysCQnWhmk2SIZN3C1")
ABUSEIPDB_KEY = os.getenv("ABUSEIPDB_KEY")
SHODAN_KEY = os.getenv("SHODAN_KEY")

s3 = boto3.client("s3")

# MITRE ATT&CK Mapping
ATTACK_PATTERNS = {
    'recon': (['uname', 'whoami', 'id', 'cat /etc/', 'ls', 'pwd'], 'T1082 - System Information Discovery', 'low'),
    'persistence': (['wget', 'curl', 'chmod +x', 'crontab'], 'T1053 - Scheduled Task/Job', 'high'),
    'data_theft': (['scp', 'tar', 'zip', 'base64'], 'T1560 - Archive Collected Data', 'critical'),
    'execution': (['bash', 'python', './'], 'T1059 - Command Interpreter', 'medium')
}

def sha256(data):
    return hashlib.sha256(data.encode("utf-8")).hexdigest()

def enrich_ip(ip):
    result = {"ip": ip}
    
    # GreyNoise enrichment
    if GREYNOISE_KEY:
        try:
            r = requests.get(
                f"https://api.greynoise.io/v3/community/{ip}",
                headers={"key": GREYNOISE_KEY}, timeout=5
            )
            if r.status_code == 200:
                j = r.json()
                result["greynoise"] = {
                    "classification": j.get("classification"),
                    "name": j.get("name"),
                    "noise": j.get("noise", False),
                    "riot": j.get("riot", False)
                }
        except Exception as e:
            result["greynoise_err"] = str(e)
    
    # AbuseIPDB enrichment
    if ABUSEIPDB_KEY:
        try:
            r = requests.get(
                "https://api.abuseipdb.com/api/v2/check",
                params={"ipAddress": ip, "maxAgeInDays": 90},
                headers={"Key": ABUSEIPDB_KEY, "Accept": "application/json"},
                timeout=5
            )
            if r.status_code == 200:
                j = r.json()
                result["abuseipdb"] = {
                    "score": j["data"]["abuseConfidenceScore"],
                    "country": j["data"]["countryCode"]
                }
        except Exception as e:
            result["abuseipdb_err"] = str(e)
    
    return result

def classify_command(command):
    """Classify command into MITRE ATT&CK technique"""
    cmd_lower = command.lower()
    
    for phase, (patterns, mitre, severity) in ATTACK_PATTERNS.items():
        if any(p in cmd_lower for p in patterns):
            return {"phase": phase, "mitre": mitre, "severity": severity}
    
    return {"phase": "unknown", "mitre": "Unknown", "severity": "low"}

def calculate_threat_score(event, enrichment):
    """Calculate overall threat score"""
    score = 0
    
    # AbuseIPDB score
    if "abuseipdb" in enrichment:
        score += enrichment["abuseipdb"]["score"]
    
    # GreyNoise classification
    if "greynoise" in enrichment:
        if enrichment["greynoise"].get("classification") == "malicious":
            score += 50
    
    # Command severity
    if "command_analysis" in enrichment:
        severity_map = {"critical": 40, "high": 30, "medium": 20, "low": 10}
        score += severity_map.get(enrichment["command_analysis"]["severity"], 0)
    
    return min(score, 100)

def discord_embed(event, enrichment):
    """Generate enhanced Discord embed with MITRE mapping"""
    
    threat_score = calculate_threat_score(event, enrichment)
    threat_level = "🔴 CRITICAL" if threat_score >= 80 else "🟡 HIGH" if threat_score >= 50 else "🟢 MEDIUM" if threat_score >= 30 else "⚪ LOW"
    
    # Build description
    desc = f"**Threat Score:** {threat_score}/100\n"
    
    if "greynoise" in enrichment:
        gn = enrichment["greynoise"]
        desc += f"**GreyNoise:** {gn.get('classification', 'unknown')} - {gn.get('name', 'Unknown')}\n"
    
    if "command_analysis" in enrichment:
        ca = enrichment["command_analysis"]
        desc += f"**MITRE ATT&CK:** {ca['mitre']}\n"
        desc += f"**Attack Phase:** {ca['phase'].upper()}\n"
    
    # Build fields
    fields = [
        {"name": "🌐 Attacker IP", "value": enrichment["ip"], "inline": True},
        {"name": "🎯 Threat Level", "value": threat_level, "inline": True},
        {"name": "🆔 Session", "value": event.get("session", "n/a")[:12], "inline": True}
    ]
    
    if event.get("input"):
        fields.append({
            "name": "💻 Command",
            "value": f"```bash\n{event['input'][:200]}\n```",
            "inline": False
        })
    
    if event.get("username"):
        fields.append({
            "name": "👤 Credentials",
            "value": f"`{event.get('username')}:{event.get('password', 'N/A')}`",
            "inline": True
        })
    
    # Color based on threat score
    color = 0xff0000 if threat_score >= 80 else 0xffa500 if threat_score >= 50 else 0xffff00 if threat_score >= 30 else 0x00ff00
    
    embed = {
        "title": f"🚨 HONEYPOT ALERT - {event.get('eventid', 'unknown')}",
        "description": desc,
        "color": color,
        "fields": fields,
        "footer": {"text": "AWS Honeypot Pipeline | Powered by Arcanum"},
        "timestamp": datetime.now(timezone.utc).isoformat()
    }
    
    return {"embeds": [embed]}

def upload_s3(obj, key_prefix="events/"):
    """Upload enriched event to S3 with immutable storage"""
    timestamp = datetime.now(timezone.utc).strftime("%Y/%m/%d")
    key = f"{key_prefix}{timestamp}/{int(time.time())}-{sha256(obj)[:12]}.json"
    
    s3.put_object(
        Bucket=S3_BUCKET,
        Key=key,
        Body=obj,
        ContentType="application/json",
        ServerSideEncryption="AES256"
    )
    return key

def lambda_handler(event, context):
    """Main Lambda handler"""
    
    for record in event["Records"]:
        msg = record["Sns"]["Message"]
        raw = json.loads(msg)
        
        # Extract IP
        ip = raw.get("src_ip") or raw.get("peerIP") or "0.0.0.0"
        
        # Enrich IP
        enrichment = enrich_ip(ip)
        
        # Classify command if present
        if raw.get("input"):
            enrichment["command_analysis"] = classify_command(raw["input"])
        
        # Archive enriched event to S3
        enriched = {
            "event": raw,
            "enrichment": enrichment,
            "processed_at": datetime.now(timezone.utc).isoformat()
        }
        
        s3_key = upload_s3(json.dumps(enriched))
        print(f"Archived to S3: {s3_key}")
        
        # Send Discord alert
        payload = discord_embed(raw, enrichment)
        try:
            r = requests.post(DISCORD_WEBHOOK, json=payload, timeout=6)
            print(f"Discord alert sent: {r.status_code}")
        except Exception as e:
            print(f"Discord error: {e}")
    
    return {"statusCode": 200, "body": "Processed successfully"}

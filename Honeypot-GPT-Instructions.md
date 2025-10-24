# Honeypot GPT — Operational Overview & Instructions

Purpose: This document explains our Cowrie honeypot deployment, monitoring, and operational procedures so that `ChatGPT Honeypot GPT` (an assistant-model) can help maintain, troubleshoot, and answer team questions reliably.

---

## 1) High-level architecture

- Deployment region: `us-east-1` (primary production)
- Active EC2 instance: `i-04d996c187504b547`
- Elastic IP: `44.218.220.47` (allocation `eipalloc-08590544ca10eec05`)
- Honeypot service: Cowrie (SSH honeypot), configured on port `2222`
- Monitoring: `cowrie-discord-monitor` (Python script, systemd service) pushes alerts to a Discord webhook
- Logs: Cowrie writes JSON logs to `/opt/cowrie/var/log/cowrie/cowrie.json`
- Code and scripts: Repository `AWSHoneypot` contains deployment scripts and docs in `02-Deployment-Scripts/` and `01-Project-Documentation/`
- CloudFormation: `04-AWS-Infrastructure/gmu-honeypot-stack-import.yaml` (import template).


## 2) Components and locations

- Cowrie installation:
  - Root path: `/opt/cowrie`
  - Virtualenv: `/opt/cowrie/cowrie-env`
  - Start/stop script: `/opt/cowrie/bin/cowrie`
  - Config: `/opt/cowrie/etc/cowrie.cfg`
  - Logs: `/opt/cowrie/var/log/cowrie/cowrie.json` and `/opt/cowrie/var/log/cowrie/` folder

- Discord monitor:
  - Path: `/opt/cowrie/discord-monitor`
  - Main script: `/opt/cowrie/discord-monitor/discord_honeypot_monitor.py`
  - Enhanced monitor: `/opt/cowrie/discord-monitor/Enhanced_Honeypot_Monitor_Script.py`
  - Config: `/opt/cowrie/discord-monitor/discord_config.json`
  - Systemd service: `/etc/systemd/system/cowrie-discord-monitor.service`

- Threat intelligence enrichment:
  - Secrets loader: `/opt/cowrie/discord-monitor/secrets_loader.py`
  - Enrichment module: `/opt/cowrie/discord-monitor/threat_enrichment.py`
  - API keys (secrets): `/opt/cowrie/discord-monitor/.env` (600 permissions, never commit!)
  - Intel cache: `/opt/cowrie/discord-monitor/intel_cache.json` (48h TTL)
  - Supported APIs: AbuseIPDB, AlienVault OTX, VirusTotal, Shodan, IPInfo

- Systemd service for Cowrie:
  - Created service: `/etc/systemd/system/cowrie.service`
  - ExecStart: `/opt/cowrie/bin/cowrie start`
  - User: `cowrie` (runs the honeypot process)

- SSH keys:
  - Primary key in repo: `local-honeypot-key.pem` (used for testing)
  - Team key: `~/.ssh/gmu-honeypot-key.pem`

- Repository paths (local):
  - `02-Deployment-Scripts/` – helper scripts for deploy and setup
  - `03-Team-Tutorials/` – onboarding and SSH instructions
  - `04-AWS-Infrastructure/` – CloudFormation templates


## 3) How alerts flow (end-to-end)

1. An attacker connects to the honeypot on TCP port 2222. Cowrie logs events in JSON to `/opt/cowrie/var/log/cowrie/cowrie.json`.
2. `cowrie-discord-monitor` tails the Cowrie JSON log file and parses events.
3. When an alert-worthy event occurs (e.g., new session connect, command execution), the monitor sends a POST request to pre-configured Discord webhook(s) contained in `/opt/cowrie/discord-monitor/discord_config.json`.
4. The Discord webhook posts in the team's channel. Team members receive the alert.


## 4) Commands for the assistant to run (always verify which instance and region first)

- SSH into instance:
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

- Check Cowrie service status:
```bash
sudo systemctl status cowrie
```

- Check Discord monitor status:
```bash
sudo systemctl status cowrie-discord-monitor
```

- View Cowrie JSON logs (tail):
```bash
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json | jq .
```

- Restart services:
```bash
sudo systemctl restart cowrie
sudo systemctl restart cowrie-discord-monitor
```

- Check that Cowrie is listening on port 2222:
```bash
sudo netstat -tlnp | grep 2222
```


## 5) Troubleshooting checklist (in order)

1. Confirm correct instance & region (avoid acting on terminated duplicate)
2. SSH to instance: `ssh -i ... ec2-user@44.218.220.47`
3. Check `cowrie` service status: `sudo systemctl status cowrie`
   - If not found: ensure `/etc/systemd/system/cowrie.service` exists and is enabled
4. If Cowrie fails to start, check `/opt/cowrie/etc/cowrie.cfg` for syntax errors (duplicate sections are a common cause)
5. Check Cowrie logs in `/opt/cowrie/var/log/cowrie/` and `twistd.log`
6. Check `cowrie-discord-monitor` status and journal logs: `sudo journalctl -u cowrie-discord-monitor -n 200 --no-pager`
7. Verify `discord_config.json` contains valid webhook URLs and correct permissions to write logs
8. Ensure ownership/permissions match the service user (Cowrie runs as `cowrie`, monitor runs as `ec2-user` by default)
9. If Cowrie shows errors about `urllib3/OpenSSL` mismatch, that only impacts `curl/wget` simulated commands — the core honeypot still runs. Only upgrade OpenSSL/urllib3 if you need those commands working.


## 6) Inputs / outputs for ChatGPT Honeypot GPT

- Inputs the assistant can expect:
  - SSH credentials (private key) available to authorized user
  - Access to repository files and systemd units via SSH
  - Access to CloudFormation templates

- Outputs the assistant should produce:
  - Clear troubleshooting steps and commands
  - Edited docs and scripts committed to the `copilot/*` branch
  - Clear status reports (service status, recent alerts, uptime)


## 7) Edge cases and safety rules for the assistant

- Never modify the live instance region or create new EC2 instances without explicit approval.
- If a command will change data or terminate instances, ask for explicit confirmation.
- Prefer non-destructive checks first (status, logs) before restarts.
- If you detect multiple instances with similar names or IPs, pause and ask which is authoritative.
- When changing configuration files, create a timestamped backup in the same directory.


## 8) Maintenance tasks (recommended)

- Add systemd service for Cowrie (already done)
- Add log rotation for `/opt/cowrie/var/log/cowrie/cowrie.json`
- Periodically rotate the Discord webhook secrets and validate in `discord_config.json`
- Add CloudWatch (or similar) alarms for service down events


## 9) Example dialogues and expected assistant behavior

- "The alerts stopped again" → Run the checklist (verify instance, check services, tail logs, report back) and only make changes after reporting findings.
- "Please update the webhook" → Verify `discord_config.json`, update the value, restart `cowrie-discord-monitor`, confirm test alert.
- "Enable more logging" → Propose changes (e.g., increase logging level in `cowrie.cfg`), create backup, apply, and verify.


## 10) Useful file references

- `/opt/cowrie/etc/cowrie.cfg` — cowrie config
- `/opt/cowrie/var/log/cowrie/cowrie.json` — events
- `/opt/cowrie/discord-monitor/discord_config.json` — Discord webhook(s)
- `/opt/cowrie/discord-monitor/.env` — threat intel API keys (NEVER log or commit!)
- `/opt/cowrie/discord-monitor/intel_cache.json` — cached threat intel (48h TTL)
- `/etc/systemd/system/cowrie.service` — Cowrie systemd unit
- `/etc/systemd/system/cowrie-discord-monitor.service` — Discord monitor unit
- `04-AWS-Infrastructure/gmu-honeypot-stack-import.yaml` — CF import template
- `02-Deployment-Scripts/*` — deployment helper scripts
- `02-Deployment-Scripts/THREAT-INTEL-DEPLOYMENT.md` — threat enrichment setup guide


## 11) Threat intelligence enrichment

- **Purpose**: Enrich IP addresses with reputation data from multiple threat intel APIs
- **APIs supported**: AbuseIPDB, AlienVault OTX, VirusTotal, Shodan, IPInfo
- **Cache**: 48-hour TTL in `intel_cache.json` to reduce API calls
- **Rate limits**: 3-second timeout per API, respects free-tier limits
- **Security**: API keys stored in `/opt/cowrie/discord-monitor/.env` (chmod 600)

**Commands:**
```bash
# Test secrets loader
cd /opt/cowrie/discord-monitor && python3 secrets_loader.py

# Test enrichment for an IP
python3 threat_enrichment.py 8.8.8.8

# Clear cache
sudo rm /opt/cowrie/discord-monitor/intel_cache.json
```

**Troubleshooting:**
- If "No threat intel keys": check `.env` exists and has correct keys
- If API timeouts: normal for some IPs, cached on retry
- If rate limit errors: free tiers have limits, upgrade or wait


---

If you'd like, I can also:
- Commit this file to the repository (already created)
- Produce a shorter playbook version for quick queries by the assistant
- Add a safety wrapper that prompts for confirmation before destructive actions

Tell me which you'd like next.

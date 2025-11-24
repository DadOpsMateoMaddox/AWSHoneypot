#!/bin/bash

# Create directories if they don't exist
mkdir -p "02-Deployment-Scripts" "01-Project-Documentation"

# Move scripts to 02-Deployment-Scripts
mv enhanced_discord_monitor_with_ai_responses.py "02-Deployment-Scripts/" 2>/dev/null
mv generate_repo_heatmap.py "02-Deployment-Scripts/" 2>/dev/null
mv get_stats.py "02-Deployment-Scripts/" 2>/dev/null
mv fix_bashrc.sh "02-Deployment-Scripts/" 2>/dev/null
mv setup_aliases.sh "02-Deployment-Scripts/" 2>/dev/null
mv revert-to-correct-ip.sh "02-Deployment-Scripts/" 2>/dev/null
mv get-presentation-pcaps.sh "02-Deployment-Scripts/" 2>/dev/null
mv get-cowrie-logs.sh "02-Deployment-Scripts/" 2>/dev/null
mv troubleshoot-honeypot.sh "02-Deployment-Scripts/" 2>/dev/null
mv fix-discord-webhook.sh "02-Deployment-Scripts/" 2>/dev/null
mv fix-monitoring-complete.sh "02-Deployment-Scripts/" 2>/dev/null
mv nuke-old-monitor.sh "02-Deployment-Scripts/" 2>/dev/null
mv cowrie_analysis_fixed.py "02-Deployment-Scripts/" 2>/dev/null

# Move documentation to 01-Project-Documentation
mv DISCORD-MONITORING-FIX-SUMMARY.md "01-Project-Documentation/" 2>/dev/null
mv CLOUDSHELL-LOG-PULL-INSTRUCTIONS.md "01-Project-Documentation/" 2>/dev/null
mv FINAL-PROJECT-SUMMARY.md "01-Project-Documentation/" 2>/dev/null
mv TEAM-COMPLETE-OVERVIEW.md "01-Project-Documentation/" 2>/dev/null
mv VSCODE-QUICK-START.md "01-Project-Documentation/" 2>/dev/null
mv EC2-VERIFICATION-CHECKLIST.md "01-Project-Documentation/" 2>/dev/null
mv ELASTIC-IP-UPDATE-GUIDE.md "01-Project-Documentation/" 2>/dev/null
mv INFRASTRUCTURE-CONSOLIDATION-GUIDE.md "01-Project-Documentation/" 2>/dev/null
mv IP-UPDATE-SUMMARY.md "01-Project-Documentation/" 2>/dev/null
mv ISSUE-RESOLVED-SUMMARY.md "01-Project-Documentation/" 2>/dev/null
mv PLANTUML-FIXES-SUMMARY.md "01-Project-Documentation/" 2>/dev/null
mv REVERSION-COMPLETE-SUMMARY.md "01-Project-Documentation/" 2>/dev/null
mv DOCUMENTATION-UPDATE-SUMMARY.md "01-Project-Documentation/" 2>/dev/null

# Add files to git
git add "02-Deployment-Scripts/enhanced_discord_monitor_with_ai_responses.py"
git add "02-Deployment-Scripts/generate_repo_heatmap.py"
git add "02-Deployment-Scripts/requirements.txt"
git add "01-Project-Documentation/"
git add "02-Deployment-Scripts/"

# Commit
git commit -m "feat: Add AI Discord monitor, heatmap generator with tracing, and updated documentation"

# Push (this might fail if auth is needed, but we'll try)
git push origin main

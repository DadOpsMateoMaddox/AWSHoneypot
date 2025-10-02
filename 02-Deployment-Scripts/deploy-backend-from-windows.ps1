#!/usr/bin/env powershell
# Deploy Shell Backend Script from Windows to EC2
# This script uploads and executes the enable-shell-backend.sh script

Write-Host "🚀 DEPLOYING SHELL BACKEND TO DEATHSTAR HONEYPOT" -ForegroundColor Green

$EC2_IP = "44.218.220.47"
$KEY_PATH = "local-honeypot-key.pem"
$SCRIPT_PATH = "enable-shell-backend.sh"

# Check if we have required files
if (!(Test-Path $KEY_PATH)) {
    Write-Host "❌ Key file not found: $KEY_PATH" -ForegroundColor Red
    Write-Host "💡 Copy your key file to current directory or update KEY_PATH" -ForegroundColor Yellow
    exit 1
}

if (!(Test-Path $SCRIPT_PATH)) {
    Write-Host "❌ Script file not found: $SCRIPT_PATH" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Files found:" -ForegroundColor Cyan
Write-Host "   Key: $KEY_PATH" -ForegroundColor Gray
Write-Host "   Script: $SCRIPT_PATH" -ForegroundColor Gray
Write-Host "   Target: $EC2_IP" -ForegroundColor Gray

# Instructions for manual deployment
Write-Host "`n🔧 DEPLOYMENT INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "Since you're on Windows, here are the steps to deploy manually:`n" -ForegroundColor White

Write-Host "1️⃣ Open PowerShell or Command Prompt as Administrator" -ForegroundColor Cyan
Write-Host "2️⃣ Navigate to your project directory:" -ForegroundColor Cyan
Write-Host "   cd `"d:\School\AIT670 Cloud Computing In Person\Group Project\AWSHoneypot\02-Deployment-Scripts`"" -ForegroundColor Gray

Write-Host "`n3️⃣ Copy the script to EC2 using SCP:" -ForegroundColor Cyan
Write-Host "   scp -i $KEY_PATH $SCRIPT_PATH ec2-user@${EC2_IP}:/tmp/" -ForegroundColor Gray

Write-Host "`n4️⃣ SSH to EC2 and execute:" -ForegroundColor Cyan
Write-Host "   ssh -i $KEY_PATH ec2-user@$EC2_IP" -ForegroundColor Gray
Write-Host "   chmod +x /tmp/enable-shell-backend.sh" -ForegroundColor Gray
Write-Host "   sudo /tmp/enable-shell-backend.sh" -ForegroundColor Gray

Write-Host "`n🌐 ALTERNATIVE - Use AWS CloudShell:" -ForegroundColor Yellow
Write-Host "1. Go to AWS Console → CloudShell" -ForegroundColor Gray
Write-Host "2. Upload enable-shell-backend.sh using CloudShell upload feature" -ForegroundColor Gray
Write-Host "3. Run: ssh ec2-user@$EC2_IP" -ForegroundColor Gray
Write-Host "4. Run: sudo ./enable-shell-backend.sh" -ForegroundColor Gray

Write-Host "`n✨ EXPECTED RESULT:" -ForegroundColor Green
Write-Host "   🔓 Interactive shell backend enabled" -ForegroundColor Gray
Write-Host "   🎯 Attackers can execute commands" -ForegroundColor Gray
Write-Host "   📊 Discord alerts active" -ForegroundColor Gray
Write-Host "   🕵️ Full session recording" -ForegroundColor Gray

Write-Host "`n🎯 Ready to deploy? Choose your method above!" -ForegroundColor Green
@echo off
echo 🐱 Running Full Stack Cowrie Optimization
echo ==========================================

echo.
echo 📋 Manual Deployment Steps:
echo ---------------------------
echo.
echo 1. Open WSL or Git Bash terminal
echo 2. Navigate to this directory
echo 3. Run: bash deploy-full-stack-optimization.sh
echo.
echo OR run these commands manually:
echo.

echo 📁 Step 1: Upload scripts to honeypot
echo scp -i "local-honeypot-key.pem" -o "StrictHostKeyChecking=no" full-stack-optimizer.py ubuntu@44.218.220.47:/tmp/
echo scp -i "local-honeypot-key.pem" -o "StrictHostKeyChecking=no" cowrie-config-optimizer.py ubuntu@44.218.220.47:/tmp/

echo.
echo ⏹️ Step 2: Stop Cowrie and backup
echo ssh -i "local-honeypot-key.pem" ubuntu@44.218.220.47 "sudo systemctl stop cowrie && sudo mkdir -p /opt/cowrie/backup/fullstack_$(date +%%Y%%m%%d_%%H%%M%%S) && sudo cp -r /opt/cowrie/etc /opt/cowrie/backup/fullstack_$(date +%%Y%%m%%d_%%H%%M%%S)/"

echo.
echo ⚙️ Step 3: Deploy optimized configuration
echo ssh -i "local-honeypot-key.pem" ubuntu@44.218.220.47 "cd /tmp && python3 cowrie-config-optimizer.py && sudo cp /tmp/cowrie_optimized.cfg /opt/cowrie/etc/cowrie.cfg"

echo.
echo 🚀 Step 4: Start Cowrie
echo ssh -i "local-honeypot-key.pem" ubuntu@44.218.220.47 "sudo systemctl start cowrie"

echo.
echo 🧪 Step 5: Test the honeypot
echo ssh admin@44.218.220.47 -p 2222
echo Password: admin123

echo.
echo 📊 Full optimization script available: deploy-full-stack-optimization.sh
echo 🎯 This will make your honeypot purr like a kitten! 🐱

pause
@echo off
echo 🧪 Testing Obfuscated Honeypot
echo ==============================

echo.
echo 📋 Test 1: Basic Honeypot Connection
echo ------------------------------------
ssh -i "local-honeypot-key.pem" -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=nul" -o "ConnectTimeout=10" lmenendez@44.218.220.47 -p 2222 "hostname && echo 'User:' && whoami && echo 'OS Info:' && cat /etc/issue && echo 'Home Dirs:' && ls /home && echo 'Fake Files:' && ls -la /home/lmenendez/ 2>/dev/null || echo 'No home dir found'"

echo.
echo 📋 Test 2: System Information Check
echo -----------------------------------
ssh -i "local-honeypot-key.pem" -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=nul" -o "ConnectTimeout=10" lmenendez@44.218.220.47 -p 2222 "echo 'CPU Info:' && cat /proc/cpuinfo | head -5 && echo 'Memory:' && cat /proc/meminfo | head -3 && echo 'Kernel:' && uname -a"

echo.
echo 📋 Test 3: Check for Default Indicators
echo ----------------------------------------
ssh -i "local-honeypot-key.pem" -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=nul" -o "ConnectTimeout=10" lmenendez@44.218.220.47 -p 2222 "echo 'Checking for phil user:' && grep phil /etc/passwd || echo 'Phil user NOT found (good!)' && echo 'Checking passwd file:' && cat /etc/passwd | head -10"

echo.
echo 🎯 Test Complete! Check Discord for alerts.
pause
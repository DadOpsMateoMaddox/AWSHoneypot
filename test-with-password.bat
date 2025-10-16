@echo off
echo 🧪 Testing Honeypot with Password Authentication
echo ================================================

echo.
echo 📋 Testing password login (should trigger Discord alert)
echo --------------------------------------------------------
echo This will test if the new user credentials work...
echo.

REM Test with sshpass if available, otherwise manual
where sshpass >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Using sshpass for automated login...
    sshpass -p "lmenendez" ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=nul" -o "ConnectTimeout=10" lmenendez@44.218.220.47 -p 2222 "hostname && whoami && echo 'SUCCESS: Obfuscated honeypot working!'"
) else (
    echo sshpass not found. Manual test required.
    echo.
    echo Please run this command manually:
    echo ssh lmenendez@44.218.220.47 -p 2222
    echo Password: lmenendez
    echo.
    echo Then run these commands in the honeypot:
    echo   hostname
    echo   whoami  
    echo   cat /etc/issue
    echo   ls /home
    echo   cat /proc/cpuinfo ^| head -5
    echo.
)

echo.
echo 🎯 Check your Discord channel for the alert!
pause
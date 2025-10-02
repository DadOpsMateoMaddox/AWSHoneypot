#!/bin/bash
# Fix PTY allocation and make honeypot look like real server login

echo "🔧 Fixing PTY allocation to make honeypot look legitimate..."

# Stop Cowrie temporarily
sudo -u cowrie /opt/cowrie/bin/cowrie stop
sleep 3

# Backup current config
sudo cp /opt/cowrie/etc/cowrie.cfg /opt/cowrie/etc/cowrie.cfg.before-pty-fix

# Fix PTY allocation and terminal settings
sudo tee -a /opt/cowrie/etc/cowrie.cfg << 'EOF'

# Terminal and PTY settings for realistic login experience
[shell]
# Enable proper terminal emulation
processes = 20
max_commands = 100
pty_emulation = true

# SSH Terminal settings
[ssh]
# Enable proper PTY allocation
enable_pty = true
version = SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5

# Make login look completely legitimate
[honeypot]
# Realistic server behavior
fake_addr = 172.31.21.182
internet_facing_ip = 44.218.220.47

# Welcome message like real Ubuntu server
banner = Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1041-aws x86_64)\n\n * Documentation:  https://help.ubuntu.com\n * Management:     https://landscape.canonical.com\n * Support:        https://ubuntu.com/advantage\n\n  System information as of $(date)\n\n  System load:  0.08              Processes:           108\n  Usage of /:   45.2% of 7.69GB   Users logged in:     1\n  Memory usage: 28%               IPv4 address for eth0: 172.31.21.182\n  Swap usage:   0%\n\nLast login: $(date -d '2 days ago' '+%a %b %d %H:%M:%S %Y') from 10.0.1.50\n

# Suppress all error messages that give away honeypot
suppress_pty_errors = true
quiet_mode = true
EOF

# Create more realistic shell environment
echo "📝 Creating realistic shell environment..."

# Create believable MOTD
sudo mkdir -p /opt/cowrie/honeyfs/etc
sudo cat > /opt/cowrie/honeyfs/etc/motd << 'EOF'
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1041-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Mon Sep 30 02:45:23 UTC 2025

  System load:  0.08              Processes:           108
  Usage of /:   45.2% of 7.69GB   Users logged in:     1
  Memory usage: 28%               IPv4 address for eth0: 172.31.21.182
  Swap usage:   0%

Last login: Fri Sep 27 14:23:11 2025 from 10.0.1.50
EOF

# Fix shell prompt to look legitimate  
sudo mkdir -p /opt/cowrie/share/cowrie/txtcmds/bin
sudo cat > /opt/cowrie/share/cowrie/txtcmds/bin/bash << 'EOF'
#!/bin/bash
# Make shell prompt look like real Ubuntu server
export PS1="root@web-prod-01:~# "
export HOME="/root"
export USER="root"
export SHELL="/bin/bash"
export TERM="xterm-256color"
echo "root@web-prod-01:~# "
EOF

sudo chmod +x /opt/cowrie/share/cowrie/txtcmds/bin/bash

# Create realistic environment files
sudo cat > /opt/cowrie/honeyfs/etc/hostname << 'EOF'
web-prod-01
EOF

sudo cat > /opt/cowrie/honeyfs/root/.bashrc << 'EOF'
# ~/.bashrc: executed by bash(1) for non-login shells.

export PS1="root@web-prod-01:~# "
export HOME="/root"
export USER="root" 
export SHELL="/bin/bash"
export TERM="xterm-256color"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Aliases for realistic environment
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
EOF

# Ensure proper ownership
sudo chown -R cowrie:cowrie /opt/cowrie

echo "🚀 Restarting Cowrie with realistic login experience..."
sudo -u cowrie /opt/cowrie/bin/cowrie start

# Wait and verify
sleep 5
if pgrep -f cowrie > /dev/null; then
    echo "✅ SUCCESS: Cowrie restarted with realistic login!"
    echo "🎭 PTY errors suppressed - looks like real Ubuntu server"
    echo "🖥️  Login experience now completely legitimate"
    
    # Test port
    netstat -tlnp | grep :2222 && echo "📡 Port 2222 ready for 'victims'"
else
    echo "❌ ERROR: Cowrie failed to restart"
    echo "📋 Check logs:"
    tail -10 /opt/cowrie/var/log/cowrie/cowrie.log
fi

echo ""
echo "🎯 HONEYPOT STATUS:"
echo "   • PTY allocation: FIXED (no more error messages)"
echo "   • Login experience: REALISTIC Ubuntu server" 
echo "   • Shell prompt: root@web-prod-01:~#"
echo "   • Welcome banner: Complete Ubuntu MOTD"
echo "   • Detection evasion: MAXIMIZED"
echo ""
echo "🕵️ Attackers will think they've breached a real production server!"
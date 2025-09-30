#!/bin/bash
# Test Cowrie Backend - Verify shell mode is working

echo "🧪 Testing Cowrie backend configuration..."

# Check if Cowrie is running
if ! pgrep -f cowrie > /dev/null; then
    echo "❌ Cowrie is not running!"
    exit 1
fi

# Check configuration
echo "📋 Current backend configuration:"
grep -A 5 "backend.*=" /opt/cowrie/etc/cowrie.cfg

# Check if shell backend is enabled
if grep -q "backend = shell" /opt/cowrie/etc/cowrie.cfg; then
    echo "✅ Shell backend is configured"
else
    echo "❌ Shell backend is NOT configured"
fi

# Check filesystem structure
echo "📁 Filesystem structure:"
ls -la /opt/cowrie/honeyfs/ 2>/dev/null || echo "❌ No honeyfs directory"

# Check if port 2222 is listening
echo "🔌 Port status:"
netstat -tlnp | grep :2222 || echo "❌ Port 2222 not listening"

# Check recent logs
echo "📝 Recent Cowrie logs:"
tail -10 /opt/cowrie/var/log/cowrie/cowrie.log 2>/dev/null || echo "❌ No log file found"

echo ""
echo "🎯 To test manually:"
echo "ssh -p 2222 root@localhost"
echo "Password: anything (should work)"
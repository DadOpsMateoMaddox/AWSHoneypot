# Connecting to AWS Honeypot via VS Code

## Overview
This guide walks you through connecting to the GMU AWS Honeypot EC2 instance using Visual Studio Code's Remote-SSH extension. This provides a full IDE experience directly on the remote server.

## Prerequisites

- **VS Code** installed on your local machine
- **SSH key** (`gmu-honeypot-key.pem`) provided by team leader
- **Remote-SSH extension** for VS Code
- Basic familiarity with VS Code and SSH

## Step 1: Install Remote-SSH Extension

1. Open VS Code
2. Click on the **Extensions** icon in the sidebar (or press `Ctrl+Shift+X` / `Cmd+Shift+X`)
3. Search for **"Remote - SSH"**
4. Install the extension by **Microsoft** (ms-vscode-remote.remote-ssh)
5. VS Code may prompt you to reload - click **Reload** if asked

## Step 2: Configure SSH Key

### On Windows:

1. Create `.ssh` directory in your user folder if it doesn't exist:
   ```powershell
   # In PowerShell
   mkdir $HOME\.ssh
   ```

2. Copy the `gmu-honeypot-key.pem` file to `C:\Users\<YourUsername>\.ssh\`

3. Set proper permissions (right-click the file → Properties → Security → Advanced):
   - Remove all inherited permissions
   - Add yourself with Full Control
   - Ensure no other users have access

### On macOS/Linux:

```bash
# Create .ssh directory if needed
mkdir -p ~/.ssh

# Copy key file (adjust source path as needed)
cp /path/to/gmu-honeypot-key.pem ~/.ssh/

# Set correct permissions
chmod 600 ~/.ssh/gmu-honeypot-key.pem
```

## Step 3: Configure SSH Config File

1. Open (or create) your SSH config file:
   - **Windows**: `C:\Users\<YourUsername>\.ssh\config`
   - **macOS/Linux**: `~/.ssh/config`

2. Add the following configuration:

```ssh-config
Host gmu-honeypot
    HostName 44.218.220.47
    User ec2-user
    IdentityFile ~/.ssh/gmu-honeypot-key.pem
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**For Windows users**, use the Windows path format:
```ssh-config
Host gmu-honeypot
    HostName 44.218.220.47
    User ec2-user
    IdentityFile C:\Users\<YourUsername>\.ssh\gmu-honeypot-key.pem
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

3. Save the file

## Step 4: Connect to Honeypot via VS Code

1. In VS Code, press `F1` or `Ctrl+Shift+P` / `Cmd+Shift+P` to open the Command Palette

2. Type **"Remote-SSH: Connect to Host"** and select it

3. Select **"gmu-honeypot"** from the list

4. A new VS Code window will open and connect to the EC2 instance

5. When prompted to select the platform, choose **"Linux"**

6. VS Code will install the VS Code Server on the remote host (first time only)

7. Once connected, you'll see **"SSH: gmu-honeypot"** in the bottom-left corner

## Step 5: Open the Honeypot Workspace

1. In the connected VS Code window, click **File** → **Open Folder**

2. Navigate to `/home/ec2-user` (or your preferred working directory)

3. Click **OK**

4. You can also clone the repository directly on the remote server:
   ```bash
   # In VS Code's integrated terminal
   cd ~
   git clone https://github.com/DadOpsMateoMaddox/AWSHoneypot.git
   cd AWSHoneypot
   ```

5. Open the cloned repository: **File** → **Open Folder** → `/home/ec2-user/AWSHoneypot`

## Step 6: Set Up Environment Variables

VS Code's settings.json includes environment variables, but for shell sessions, create a profile script:

```bash
# Create environment setup script
cat > ~/.honeypot_env << 'EOF'
# AWS Honeypot Environment Variables
export HONEYPOT_USER="ec2-user"
export HONEYPOT_IP="44.218.220.47"
export LOCAL_ARCHIVE_DIR="$HOME/cowrie_archives"
export COWRIE_LOG_DIR="/opt/cowrie/var/log/cowrie"
export COWRIE_HOME="/opt/cowrie"

# Create archive directory if it doesn't exist
mkdir -p "$LOCAL_ARCHIVE_DIR"

# Helpful aliases
alias cowrie-status='sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py status'
alias cowrie-logs='sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json | jq .'
alias cowrie-start='sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py start'
alias cowrie-stop='sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py stop'
alias cowrie-restart='sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py restart'

echo "🍯 Honeypot environment loaded!"
echo "   HONEYPOT_IP: $HONEYPOT_IP"
echo "   ARCHIVE_DIR: $LOCAL_ARCHIVE_DIR"
EOF

# Add to bashrc for automatic loading
echo "" >> ~/.bashrc
echo "# Load Honeypot Environment" >> ~/.bashrc
echo "source ~/.honeypot_env" >> ~/.bashrc

# Load immediately
source ~/.honeypot_env
```

## Step 7: Install Recommended Extensions (Remote)

VS Code will prompt you to install recommended extensions when you open the workspace. Click **Install All** to get:

- Python extension
- YAML extension
- Other helpful tools

These extensions run on the remote server, not your local machine.

## Step 8: Using VS Code Tasks

The repository includes pre-configured tasks for common operations:

1. Press `Ctrl+Shift+P` / `Cmd+Shift+P`
2. Type **"Tasks: Run Task"**
3. Select from available tasks:
   - **View Live Cowrie Logs** - Real-time JSON log viewing
   - **Check Cowrie Status** - Check if Cowrie is running
   - **Pull and Archive Logs** - Create downloadable log archive
   - **Test Honeypot Connection** - Test SSH connection to honeypot
   - **View Behavioral Analytics** - Run analytics script

## Step 9: Pull and Archive Logs from VS Code

### Using the Built-in Task:

1. Press `Ctrl+Shift+P` / `Cmd+Shift+P`
2. Type **"Tasks: Run Task"**
3. Select **"Pull and Archive Logs"**
4. The archive will be created in `/tmp/` with timestamp

### Using Terminal with Environment Variables:

```bash
# The environment variables are already set from ~/.honeypot_env

# Create a local archive directory
mkdir -p "$LOCAL_ARCHIVE_DIR"

# Pull logs using the script
cd ~/AWSHoneypot/02-Deployment-Scripts
sudo ./pull_and_archive_cowrie_logs.sh \
  --out "$LOCAL_ARCHIVE_DIR/archive_$(date +%Y%m%d_%H%M%S)" \
  --convert-pcap

# The archive will be in the output directory specified
```

### Manual Log Pull with Variables:

```bash
# All variables are pre-set in your environment
echo "Honeypot: $HONEYPOT_USER@$HONEYPOT_IP"
echo "Archive location: $LOCAL_ARCHIVE_DIR"

# Create timestamped archive directory
ARCHIVE_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_PATH="$LOCAL_ARCHIVE_DIR/logs_$ARCHIVE_TIMESTAMP"

# Copy logs to local archive
sudo cp -r "$COWRIE_LOG_DIR" "$ARCHIVE_PATH/"

# Create tarball
cd "$LOCAL_ARCHIVE_DIR"
tar -czf "cowrie_logs_$ARCHIVE_TIMESTAMP.tar.gz" "logs_$ARCHIVE_TIMESTAMP"

echo "Archive created: $LOCAL_ARCHIVE_DIR/cowrie_logs_$ARCHIVE_TIMESTAMP.tar.gz"
```

## Step 10: Download Files from Remote to Local Machine

### Option 1: Using VS Code's File Explorer

1. In the Explorer sidebar, right-click on a file
2. Select **"Download..."**
3. Choose where to save on your local machine

### Option 2: Using SCP from Your Local Machine

```bash
# On your local machine (NOT in VS Code remote terminal)

# Download a single file
scp -i ~/.ssh/gmu-honeypot-key.pem \
  ec2-user@44.218.220.47:/tmp/cowrie_logs_*.tar.gz \
  ~/Downloads/

# Download entire directory
scp -r -i ~/.ssh/gmu-honeypot-key.pem \
  ec2-user@44.218.220.47:~/cowrie_archives/ \
  ~/Downloads/honeypot-archives/
```

### Option 3: Using VS Code's Remote Explorer

1. Click the **Remote Explorer** icon in the sidebar
2. Right-click on the connected host
3. Select **"Open SSH Configuration File"** to manage settings
4. Use the integrated terminal for file operations

## Useful VS Code Features for Honeypot Work

### Integrated Terminal

- Open with `` Ctrl+` `` or `View → Terminal`
- Multiple terminals supported
- Run all honeypot commands directly

### File Editing

- Edit configuration files directly: `/opt/cowrie/etc/cowrie.cfg`
- View logs with syntax highlighting
- Use Find & Replace across multiple files

### Extensions for Honeypot Analysis

- **Python** - For behavioral analytics scripts
- **JSON** - For viewing Cowrie JSON logs
- **Remote - SSH** - Already installed
- **GitLens** - Enhanced Git integration
- **Rainbow CSV** - For CSV log analysis

### Keyboard Shortcuts

| Action | Windows/Linux | macOS |
|--------|---------------|-------|
| Command Palette | `Ctrl+Shift+P` | `Cmd+Shift+P` |
| Open Terminal | `` Ctrl+` `` | `` Ctrl+` `` |
| Quick Open File | `Ctrl+P` | `Cmd+P` |
| Find in Files | `Ctrl+Shift+F` | `Cmd+Shift+F` |
| Run Task | `Ctrl+Shift+B` | `Cmd+Shift+B` |

## Common Operations

### View Live Honeypot Activity

```bash
# In VS Code terminal
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.json | jq .
```

### Check Honeypot Status

```bash
cowrie-status
# or
sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py status
```

### Analyze Logs

```bash
# Count login attempts
sudo jq -r 'select(.eventid=="cowrie.login.success")' \
  /opt/cowrie/var/log/cowrie/cowrie.json | wc -l

# List unique attacker IPs
sudo jq -r '.src_ip' /opt/cowrie/var/log/cowrie/cowrie.json | \
  sort -u | head -20
```

### Run Python Scripts

```bash
# Run behavioral analytics
cd ~/AWSHoneypot/02-Deployment-Scripts
sudo python3 behavioral_analytics.py

# Run telemetry enrichment
sudo python3 telemetry_enrichment.py
```

## Troubleshooting

### "Could not establish connection"

1. Verify EC2 instance is running in AWS Console
2. Check security group allows SSH (port 22) from your IP
3. Verify SSH key permissions (`chmod 600` on macOS/Linux)
4. Test connection manually: `ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47`

### "Permission denied (publickey)"

1. Ensure you're using the correct key file
2. Verify key file path in SSH config
3. Check key file permissions
4. Confirm you're using username `ec2-user`, not `root` or `ubuntu`

### "Timeout waiting for VS Code Server"

1. Check your internet connection
2. Try increasing timeout: Add `"remote.SSH.connectTimeout": 60` to VS Code settings
3. Connect manually first via terminal, then try VS Code

### Environment Variables Not Loading

```bash
# Manually source the environment file
source ~/.honeypot_env

# Or re-run the setup
cat > ~/.honeypot_env << 'EOF'
export HONEYPOT_USER="ec2-user"
export HONEYPOT_IP="44.218.220.47"
export LOCAL_ARCHIVE_DIR="$HOME/cowrie_archives"
export COWRIE_LOG_DIR="/opt/cowrie/var/log/cowrie"
mkdir -p "$LOCAL_ARCHIVE_DIR"
EOF

source ~/.honeypot_env
```

### VS Code Extensions Not Working

1. Ensure extensions are installed on the remote server
2. Reload VS Code window: `Ctrl+Shift+P` → "Reload Window"
3. Check VS Code output logs: `View → Output` → Select "Remote - SSH"

## Best Practices

1. **Coordinate with Team**: Notify team before restarting Cowrie or making infrastructure changes
2. **Use Sudo Wisely**: Most Cowrie operations require `sudo -u cowrie`
3. **Regular Backups**: Archive logs regularly using the provided scripts
4. **Monitor Resources**: Check disk space and CPU usage periodically
5. **Git Integration**: Commit and push documentation updates
6. **Session Management**: Use `screen` or `tmux` for long-running processes

## Security Reminders

- ✅ Never commit SSH keys to Git repository
- ✅ Never share private keys publicly
- ✅ Use SSH key authentication only (no password auth)
- ✅ Keep VS Code and extensions updated
- ✅ Log out when done working
- ✅ Only use for project purposes

## Quick Reference

### Environment Variables
```bash
$HONEYPOT_USER    # ec2-user
$HONEYPOT_IP      # 44.218.220.47
$LOCAL_ARCHIVE_DIR # ~/cowrie_archives
$COWRIE_LOG_DIR   # /opt/cowrie/var/log/cowrie
$COWRIE_HOME      # /opt/cowrie
```

### Helpful Aliases
```bash
cowrie-status    # Check Cowrie status
cowrie-logs      # View live logs with jq
cowrie-start     # Start Cowrie
cowrie-stop      # Stop Cowrie
cowrie-restart   # Restart Cowrie
```

### Key Locations
```
/opt/cowrie/                    # Cowrie installation
/opt/cowrie/var/log/cowrie/     # Log files
/opt/cowrie/etc/cowrie.cfg      # Main configuration
~/AWSHoneypot/                  # Project repository
~/cowrie_archives/              # Local log archives
```

## Additional Resources

- **Main README**: `/home/ec2-user/AWSHoneypot/README.md`
- **Team Tutorial**: `/home/ec2-user/AWSHoneypot/03-Team-Tutorials/team-access-tutorial.md`
- **CloudShell Guide**: `/home/ec2-user/AWSHoneypot/CLOUDSHELL-LOG-PULL-INSTRUCTIONS.md`
- **Deployment Scripts**: `/home/ec2-user/AWSHoneypot/02-Deployment-Scripts/`

## Support

- **Technical Issues**: Contact project leadership
- **VS Code Issues**: Check [VS Code Remote-SSH docs](https://code.visualstudio.com/docs/remote/ssh)
- **AWS Issues**: Verify EC2 instance status and security groups

---

**Last Updated**: November 2025  
**Maintained By**: GMU AIT670 Team - PatriotPot Project

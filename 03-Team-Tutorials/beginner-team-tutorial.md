# Team Access Tutorial: GMU Honeypot EC2 Instance
**Technical Guide for Team Access**

## Objectives
- Configure access to the cloud server (EC2 instance)
- Execute basic commands to monitor the honeypot
- Establish team collaboration procedures

## Step 1: Install WSL2 (Windows Subsystem for Linux)

**WSL Overview**: Windows Subsystem for Linux enables running Linux distributions on Windows.

1. **Open PowerShell as Administrator:**
   - Press `Windows key + X`
   - Click "Windows PowerShell (Admin)" or "Terminal (Admin)"
   - Click "Yes" when prompted

2. **Install WSL:**
   ```powershell
   wsl --install
   ```
   - Wait for installation to complete
   - **Restart your computer** when prompted

3. **After restart:**
   - WSL will automatically open
   - Create a username and password (remember these!)

## Step 2: Install VS Code

1. Download from: https://code.visualstudio.com/
2. Install using default configuration
3. Launch VS Code
4. Install the "Remote - WSL" extension:
   - Access Extensions panel (left sidebar)
   - Search "Remote WSL"
   - Install the Microsoft Remote WSL extension

## Step 3: Open WSL in VS Code

1. **Open VS Code**
2. **Press `Ctrl + Shift + P`**
3. **Type:** `WSL: Connect to WSL`
4. **Press Enter**
5. **A new VS Code window opens** - this is connected to Linux!

## Step 4: Configure SSH Key Authentication

**Obtain the SSH key file `gmu-honeypot-key.pem` from the project administrator**

1. **Save to Downloads directory**
2. **In VS Code WSL terminal** (bottom panel), execute:
   ```bash
   mkdir ~/.ssh
   ```
   - Creates secure directory for SSH keys

3. **Copy the key file:**
   ```bash
   cp /mnt/c/Users/YourWindowsUsername/Downloads/gmu-honeypot-key.pem ~/.ssh/
   ```
   - Replace `YourWindowsUsername` with your Windows username
   - Example: `cp /mnt/c/Users/John/Downloads/gmu-honeypot-key.pem ~/.ssh/`

4. **Set correct permissions** (required for SSH security):
   ```bash
   chmod 400 ~/.ssh/gmu-honeypot-key.pem
   ```

## Step 5: Establish Server Connection

**Execute the following command:**
```bash
ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47
```

**Command explanation:**
- `ssh` = Secure Shell protocol for remote access
- `-i ~/.ssh/gmu-honeypot-key.pem` = Specifies private key file
- `ubuntu` = Server username (Ubuntu AMI default)
- `44.218.220.47` = Server Elastic IP address (permanent)

**Successful connection displays:**
```
[ec2-user@ip-172-31-21-182 ~]$
```
**Connection established to cloud server.**

## Step 6: Configure Connection Alias

**Create an alias for simplified access:**

1. **Execute:** `nano ~/.bashrc`
   - Opens bash configuration file

2. **Navigate to file end using arrow keys**

3. **Add alias definition:**
   ```bash
   alias ec2='ssh -i ~/.ssh/gmu-honeypot-key.pem ec2-user@44.218.220.47'
   ```

4. **Save and exit:**
   - Press `Ctrl + X`
   - Press `Y` (confirm save)
   - Press `Enter`

5. **Reload configuration:**
   ```bash
   source ~/.bashrc
   ```

**Connection simplified to:**
```bash
ec2
```

## Basic Linux Commands You'll Need

**Navigation:**
```bash
pwd                    # Shows current folder location
ls                     # Lists files in current folder
ls -la                 # Lists all files with details
cd /path/to/folder     # Changes to a folder
cd ~                   # Goes to your home folder
```

**Viewing Files:**
```bash
cat filename.txt       # Shows entire file content
head filename.txt      # Shows first 10 lines
tail filename.txt      # Shows last 10 lines
tail -f filename.txt   # Shows last lines and keeps updating
```

**Basic Operations:**
```bash
sudo command           # Runs command as administrator
exit                   # Disconnects from server
clear                  # Clears the screen
```

## Honeypot Commands (Copy & Paste These)

**Check if honeypot is running:**
```bash
sudo netstat -tlnp | grep 2222
```
- If you see output, it's running
- If no output, it's stopped

**View live honeypot activity:**
```bash
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log
```
- Press `Ctrl + C` to stop viewing

**Test the honeypot (open a second terminal):**
```bash
ssh -p 2222 root@44.218.220.47
```
- This connects to our fake server
- Try commands like `ls`, `whoami`, `cat /etc/passwd`
- Type `exit` to disconnect

**Start/Stop honeypot (coordinate with team first!):**
```bash
# Stop honeypot
sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py stop

# Start honeypot
sudo -u cowrie python3.10 /opt/cowrie/src/cowrie/scripts/cowrie.py start
```

## Understanding the Terminal Prompt

Prompt format:
```
[ec2-user@ip-172-31-21-182 ~]$
```

Components:
- `ec2-user` = Current username
- `ip-172-31-21-182` = Server hostname
- `~` = Current directory (home folder)
- `$` = Command prompt (ready for input)

## Common Connection Issues

**"Permission denied" error:**
- Verify command syntax is correct
- Verify key file permissions: `chmod 400 ~/.ssh/gmu-honeypot-key.pem`

**"Connection refused" error:**
- Server may be offline
- Contact project administrator

**"No such file or directory":**
- Verify file path and filename
- Check current directory with `pwd`

**Command not responding:**
- Press `Ctrl + C` to terminate
- Press `Ctrl + D` to exit session

## Team Coordination Protocols

1. **Required team notification before:**
   - Stopping the honeypot service
   - Modifying system configuration
   - Running tests that impact system availability

2. **Documentation requirements:**
   - Capture unusual log entries via screenshot
   - Document observed attack patterns

3. **Error handling procedures:**
   - Capture error messages and system state
   - Report to team via communication channel
   - Avoid unauthorized modification attempts

## Support Procedures

**Issue resolution process:**
1. Capture terminal screenshot
2. Record exact error message
3. Report via team communication channel with context

**Keyboard shortcuts:**
- `Ctrl + C` = Terminate current command
- `Ctrl + D` = Exit/logout
- `Ctrl + L` = Clear screen
- `Up arrow` = Recall previous command
- `Tab` = Auto-complete file/folder names

## Project Scope

**Research objectives:**
- Deploy honeypot deception system
- Monitor unauthorized access attempts
- Analyze attack patterns and methodologies

**Team member responsibilities:**
- Monitor honeypot activity
- Document security incidents
- Contribute to cybersecurity research

---
**Support:** Contact project administrator for assistance.
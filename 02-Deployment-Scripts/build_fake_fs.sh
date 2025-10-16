#!/bin/bash
#
# build_fake_fs.sh - Build a realistic fake filesystem for the Cowrie honeypot.
# This script enhances the deceptiveness of the honeypot by creating a
# believable directory structure, adding decoy files, and removing default
# artifacts that could reveal the honeypot's nature.
#
# Based on the principles outlined in:
# Cabral, W. Z., Valli, C., Sikos, L. F., & Wakeling, S. G. (2019).
# "Advanced Cowrie Configuration to Increase Honeypot Deceptiveness."
#
# Usage: Run this script on the EC2 instance where Cowrie is installed.
# sudo ./build_fake_fs.sh

set -e
echo "--- Starting Fake Filesystem Build for Cowrie ---"

# --- Configuration ---
COWRIE_DIR="/opt/cowrie"
HONEYFS_DIR="${COWRIE_DIR}/honeyfs"
COWRIE_USER="cowrie"

# Verify Cowrie directory exists
if [ ! -d "$COWRIE_DIR" ]; then
    echo "Error: Cowrie directory not found at $COWRIE_DIR"
    exit 1
fi

echo "Targeting Cowrie installation at: $COWRIE_DIR"
echo "Building fake filesystem in: $HONEYFS_DIR"

# --- 1. Clean Slate: Remove Default Filesystem ---
echo "Removing old honeyfs to ensure a clean build..."
if [ -d "$HONEYFS_DIR" ]; then
    sudo rm -rf "$HONEYFS_DIR"
fi
sudo mkdir -p "$HONEYFS_DIR"
sudo chown -R ${COWRIE_USER}:${COWRIE_USER} "$HONEYFS_DIR"

# --- 2. Create a Believable Directory Structure ---
echo "Creating standard Linux directory structure..."
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/bin"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/boot"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/dev"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/etc/network"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/etc/ssh"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/home"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/lib"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/media"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/mnt"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/opt/app"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/proc"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/root"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/run"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/sbin"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/srv"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/sys"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/tmp"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/usr/local/bin"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/var/log"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/var/www/html"

# --- 3. Create Realistic User Home Directories ---
echo "Creating diverse user home directories..."
# Avoid common names. Use more realistic-sounding names per user request.
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/home/lmenendez"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/home/wfingerdoo"

# Populate user directories with some basic files
sudo -u ${COWRIE_USER} touch "${HONEYFS_DIR}/home/lmenendez/.bash_history"
sudo -u ${COWRIE_USER} touch "${HONEYFS_DIR}/home/lmenendez/.profile"
sudo -u ${COWRIE_USER} bash -c "echo 'export HISTSIZE=1000' > ${HONEYFS_DIR}/home/lmenendez/.bashrc"

sudo -u ${COWRIE_USER} mkdir "${HONEYFS_DIR}/home/wfingerdoo/documents"
sudo -u ${COWRIE_USER} bash -c "echo 'Project Zeta notes...' > ${HONEYFS_DIR}/home/wfingerdoo/documents/zeta.txt"

# --- 4. Plant High-Value Decoy Files ---
echo "Planting decoy files to entice attackers..."

# Fake AWS credentials
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/root/.aws"
sudo -u ${COWRIE_USER} bash -c "cat > ${HONEYFS_DIR}/root/.aws/credentials" <<EOF
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF

# Fake SSH private key in a non-standard location
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/srv/backups"
sudo -u ${COWRIE_USER} bash -c "cat > ${HONEYFS_DIR}/srv/backups/prod_key.pem" <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAr... (fake key data) ...
-----END RSA PRIVATE KEY-----
EOF

# Fake database connection config
sudo -u ${COWRIE_USER} bash -c "cat > ${HONEYFS_DIR}/var/www/html/config.php" <<EOF
<?php
\$db_host = "127.0.0.1";
\$db_user = "webapp_user";
\$db_pass = "S3cureP@ssw0rd123!";
\$db_name = "prod_database";
?>
EOF

# --- 5. Create Fake Log Files ---
echo "Creating plausible fake log files..."
sudo -u ${COWRIE_USER} bash -c "cat > ${HONEYFS_DIR}/var/log/auth.log" <<EOF
Oct 16 10:01:01 ubuntu-s-1vcpu-1gb-sfo3-01 CRON[12345]: pam_unix(cron:session): session opened for user root by (uid=0)
Oct 16 10:01:01 ubuntu-s-1vcpu-1gb-sfo3-01 CRON[12345]: pam_unix(cron:session): session closed for user root
Oct 16 10:05:00 ubuntu-s-1vcpu-1gb-sfo3-01 sshd[12389]: Accepted password for lmenendez from 192.168.1.10 port 54321 ssh2
Oct 16 10:09:01 ubuntu-s-1vcpu-1gb-sfo3-01 CRON[13001]: pam_unix(cron:session): session opened for user root by (uid=0)
Oct 16 10:09:01 ubuntu-s-1vcpu-1gb-sfo3-01 CRON[13001]: pam_unix(cron:session): session closed for user root
Oct 16 10:17:01 ubuntu-s-1vcpu-1gb-sfo3-01 CRON[14221]: pam_unix(cron:session): session opened for user root by (uid=0)
Oct 16 10:17:01 ubuntu-s-1vcpu-1gb-sfo3-01 CRON[14221]: pam_unix(cron:session): session closed for user root
EOF
sudo -u ${COWRIE_USER} touch "${HONEYFS_DIR}/var/log/syslog"
sudo -u ${COWRIE_USER} touch "${HONEYFS_DIR}/var/log/syslog"
sudo -u ${COWRIE_USER} mkdir -p "${HONEYFS_DIR}/var/log/apache2"
sudo -u ${COWRIE_USER} touch "${HONEYFS_DIR}/var/log/apache2/access.log"

# --- 6. Customize System Information ---
# This part is often handled by modifying cowrie.cfg and python scripts,
# but we can create the base files here.
echo "Creating placeholder system info files..."
sudo -u ${COWRIE_USER} bash -c "echo 'Debian GNU/Linux 11' > ${HONEYFS_DIR}/etc/issue"
sudo -u ${COWRIE_USER} bash -c "echo 'ubuntu-s-1vcpu-1gb-sfo3-01' > ${HONEYFS_DIR}/etc/hostname"

# --- 7. Finalize Filesystem and Permissions ---
echo "Setting final permissions..."
sudo chown -R ${COWRIE_USER}:${COWRIE_USER} "${HONEYFS_DIR}"
sudo find "${HONEYFS_DIR}" -type d -exec chmod 755 {} \;
sudo find "${HONEYFS_DIR}" -type f -exec chmod 644 {} \;

# Special permissions for sensitive files
sudo -u ${COWRIE_USER} chmod 600 "${HONEYFS_DIR}/root/.aws/credentials"
sudo -u ${COWRIE_USER} chmod 600 "${HONEYFS_DIR}/srv/backups/prod_key.pem"
sudo -u ${COWRIE_USER} chmod 700 "${HONEYFS_DIR}/root"

# --- 8. Recreate Filesystem Pickle ---
# This is a critical step for Cowrie to recognize the new filesystem.
# It must be run as the cowrie user from within the venv.
echo "Recreating fs.pickle to apply changes..."
cd "$COWRIE_DIR"
sudo -u ${COWRIE_USER} /opt/cowrie/cowrie-env/bin/python3 /opt/cowrie/bin/createfs -l /opt/cowrie/honeyfs -o /opt/cowrie/var/lib/cowrie/fs.pickle

# --- 7. Finalize Filesystem and Permissions ---
echo "Setting final permissions..."
sudo chown -R ${COWRIE_USER}:${COWRIE_USER} "${HONEYFS_DIR}"
sudo find "${HONEYFS_DIR}" -type d -exec chmod 755 {} \;
sudo find "${HONEYFS_DIR}" -type f -exec chmod 644 {} \;

# Special permissions for sensitive files
sudo -u ${COWRIE_USER} chmod 600 "${HONEYFS_DIR}/root/.aws/credentials"
sudo -u ${COWRIE_USER} chmod 600 "${HONEYFS_DIR}/srv/backups/prod_key.pem"
sudo -u ${COWRIE_USER} chmod 700 "${HONEYFS_DIR}/root"

# --- 8. Recreate Filesystem Pickle ---
# This is a critical step for Cowrie to recognize the new filesystem.
# It must be run as the cowrie user from within the venv.
echo "Recreating fs.pickle to apply changes..."
cd "$COWRIE_DIR"
sudo -u ${COWRIE_USER} /opt/cowrie/cowrie-env/bin/python3 /opt/cowrie/bin/createfs -l /opt/cowrie/honeyfs -o /opt/cowrie/var/lib/cowrie/fs.pickle

echo "--- Fake Filesystem Build Complete! ---"
echo "Restart the Cowrie service for all changes to take effect."
echo "sudo systemctl restart cowrie"

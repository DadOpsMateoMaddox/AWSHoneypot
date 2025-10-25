#!/bin/bash
cp ~/.bashrc ~/.bashrc.backup
sed -i 's/&>/2>\&1 >/g' ~/.bashrc
echo "Fixed bashrc. Backup saved to ~/.bashrc.backup"

#!/bin/sh

# Setup hostname
echo $1 > /etc/hostname

# Change plymouth default theme
plymouth-set-default-theme kali

# Enable essential services
systemctl enable bluetooth.service
systemctl enable ssh

# Load phosh on startup if package is installed
if [ -f /usr/bin/phosh ]; then
    systemctl enable phosh.service
fi

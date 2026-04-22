#!/bin/bash
# ufw_rules.sh - Universal Firewall Configuration Script
# Author: Muhammad Saif Rahman
# Usage: sudo bash ufw_rules.sh [vm1|vm2]

set -e

MODE=$1

if [ -z "$MODE" ]; then
    echo "Usage: sudo bash ufw_rules.sh [vm1|vm2]"
    echo "  vm1 - Web Server rules"
    echo "  vm2 - Database Server rules"
    exit 1
fi

echo "=== Configuring UFW for $MODE ==="

# Reset UFW to defaults
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

if [ "$MODE" = "vm1" ]; then
    # Web Server Rules
    echo "Applying WEB SERVER firewall rules..."
    sudo ufw allow 22/tcp comment 'SSH'
    sudo ufw allow 80/tcp comment 'HTTP'
    sudo ufw allow 443/tcp comment 'HTTPS'
    
    # Rate limiting for SSH (prevents brute force)
    sudo ufw limit 22/tcp
    
    echo "Web Server rules applied."
    
elif [ "$MODE" = "vm2" ]; then
    # Database Server Rules
    echo "Applying DATABASE SERVER firewall rules..."
    sudo ufw allow 22/tcp comment 'SSH'
    
    # ONLY allow MySQL access from Web Server (VM1)
    # Replace with your actual VM1 IP!
    WEB_SERVER_IP="192.168.56.10"
    sudo ufw allow from $WEB_SERVER_IP to any port 3306 comment 'MySQL from Web Server'
    
    # Rate limiting for SSH
    sudo ufw limit 22/tcp
    
    echo "Database Server rules applied."
    echo "MySQL port 3306 is ONLY accessible from $WEB_SERVER_IP"
else
    echo "Invalid mode: $MODE"
    echo "Use 'vm1' or 'vm2'"
    exit 1
fi

# Enable UFW
sudo ufw --force enable
sudo ufw status verbose

echo "=== UFW Configuration Complete ==="
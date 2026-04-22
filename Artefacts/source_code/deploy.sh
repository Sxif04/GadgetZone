#!/bin/bash
# deploy.sh - Web Server Auto-Setup Script
# Author: Muhammad Saif Rahman
# Tester: Syed Rizwan
# Purpose: Installs Nginx, PHP, SSL, and configures firewall on Web Server

set -e  # Exit on error

# ============ CONFIGURATION ============
DB_HOST="192.168.56.11"  # 
WEB_SERVER_IP="192.168.56.10"
# =======================================

echo "=== GadgetZone Web Server Deployment ==="
echo "Starting at: $(date)"

# 1. Update system
echo "Step 1: Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 2. Install Nginx
echo "Step 2: Installing Nginx..."
sudo apt install -y nginx

# 3. Install PHP and required extensions
# FIX: Ubuntu 24.04 (Noble) does not ship php8.1 in its default repos.
#      Using php8.3 which is the default PHP version on Ubuntu 24.04.
#      Note: php8.3-json is no longer a separate package (built into core PHP).
echo "Step 3: Installing PHP 8.3 with extensions..."
sudo apt install -y php8.3-fpm php8.3-mysql php8.3-curl

# 4. Configure Nginx to use PHP
echo "Step 4: Configuring Nginx..."
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

# Create new Nginx config
# FIX: Updated fastcgi socket path from php8.1-fpm.sock to php8.3-fpm.sock
sudo tee /etc/nginx/sites-available/gadgetzone > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name _;
    
    root /var/www/html;
    index index.php index.html index.htm;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/gadgetzone /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

# 5. Create health check endpoint
echo "Step 5: Creating application files..."
sudo mkdir -p /var/www/html

# Copy index.php (will be placed separately)
# For now, create a health check
sudo tee /var/www/html/health.php > /dev/null << 'EOF'
<?php
header('Content-Type: application/json');
echo json_encode(['status' => 'ok', 'timestamp' => date('c')]);
?>
EOF

# 6. Configure UFW Firewall
echo "Step 6: Configuring firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw reload

# 7. Generate self-signed SSL certificate (for testing)
echo "Step 7: Generating SSL certificate..."
sudo mkdir -p /etc/ssl/gadgetzone
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/gadgetzone/private.key \
    -out /etc/ssl/gadgetzone/certificate.crt \
    -subj "/CN=${WEB_SERVER_IP}"

# 8. Configure HTTPS in Nginx
echo "Step 8: Configuring HTTPS..."
# FIX: Updated fastcgi socket path from php8.1-fpm.sock to php8.3-fpm.sock
sudo tee /etc/nginx/sites-available/gadgetzone-ssl > /dev/null << EOF
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name _;
    
    ssl_certificate /etc/ssl/gadgetzone/certificate.crt;
    ssl_certificate_key /etc/ssl/gadgetzone/private.key;
    
    root /var/www/html;
    index index.php index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name _;
    return 301 https://\$server_name\$request_uri;
}
EOF

sudo ln -sf /etc/nginx/sites-available/gadgetzone-ssl /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 9. Set correct permissions
echo "Step 9: Setting permissions..."
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

echo "=== Deployment Complete ==="
echo "Web Server IP: ${WEB_SERVER_IP}"
echo "Database Server IP: ${DB_HOST}"
echo "Health check: curl http://${WEB_SERVER_IP}/health.php"
echo "HTTPS: https://${WEB_SERVER_IP}"
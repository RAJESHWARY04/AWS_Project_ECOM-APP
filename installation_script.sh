#!/bin/bash

# Function to check and install packages
install_package() {
    PACKAGE=$1
    if ! rpm -q "$PACKAGE" &>/dev/null; then
        echo "Installing $PACKAGE..."
        dnf install -y "$PACKAGE"
    else
        echo "$PACKAGE is already installed."
    fi
}

# Install required packages
install_package mariadb105
install_package php-mysqli
install_package php
install_package httpd
install_package git

# Clone the Git repository
# REPO_URL="https://github.com/cloudiandevops/ecom-project-aws.git"
# TARGET_DIR="/var/www/html"
# if [ ! -d "$TARGET_DIR" ]; then
#     echo "Cloning repository..."
#     git clone "$REPO_URL" "$TARGET_DIR"
# else
#     echo "Repository already cloned at $TARGET_DIR."
# fi
if [ -d "/var/www/html" ]; then
    echo "/var/www/html exists, removing contents..."
    rm -rf /var/www/html/*
fi
git clone https://github.com/cloudiandevops/ecom-project-aws.git /var/www/html/


# Update Apache configuration to use index.php
HTTPD_CONF="/etc/httpd/conf/httpd.conf"
if grep -q "index.html" "$HTTPD_CONF"; then
    sed -i 's/index.html/index.php/g' "$HTTPD_CONF"
    echo "Updated Apache configuration to use index.php."
else
    echo "Apache configuration already set to use index.php."
fi

# Update Apache document root to /var/www/html/learning-app-ecommerce
if grep -q "DocumentRoot \"/var/www/html\"" "$HTTPD_CONF"; then
    sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/var/www/html/learning-app-ecommerce"|g' "$HTTPD_CONF"
    echo "Updated Apache document root to /var/www/html/learning-app-ecommerce."
else
    echo "Apache document root already set to /var/www/html/learning-app-ecommerce."
fi

# Update index.php with the correct database host and password
INDEX_FILE="/var/www/html/index.php"
if [ -f "$INDEX_FILE" ]; then
    sed -i 's/172.20.1.101/ecomdb.aws/g' "$INDEX_FILE"
    sed -i 's/ecompassword/ecompas/g' "$INDEX_FILE"
    echo "Updated index.php with database host and password."
else
    echo "index.php not found in $TARGET_DIR."
fi

# Start, enable and Restart Apache service
systemctl start httpd
systemctl enable httpd
echo "Restarting Apache service..."
systemctl restart httpd

# Check Apache service status
if systemctl is-active --quiet httpd; then
    echo "Apache service restarted successfully."
else
    echo "Failed to restart Apache service. Check logs for details."
fi


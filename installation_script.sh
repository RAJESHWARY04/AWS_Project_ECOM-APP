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

# Update Apache configuration to use index.php
HTTPD_CONF="/etc/httpd/conf/httpd.conf"
if grep -q "index.html" "$HTTPD_CONF"; then
    sed -i 's/index.html/index.php/g' "$HTTPD_CONF"
    echo "Updated Apache configuration to use index.php."
else
    echo "Apache configuration already set to use index.php."
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


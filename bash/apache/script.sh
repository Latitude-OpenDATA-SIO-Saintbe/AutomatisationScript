#!/bin/bash

# Function to log messages
log_message() {
    echo "[INFO] $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Apache
install_apache() {
    log_message "Installing Apache web server..."
    
    # Check for the package manager
    if command_exists apt; then
        sudo apt update
        sudo apt install -y apache2
        
        # Enable and start Apache service
        sudo systemctl enable apache2
        sudo systemctl start apache2
        
        log_message "Apache installed and started successfully."
    else
        log_message "No supported package manager found. Exiting."
        exit 1
    fi
}

# Main script execution
install_apache

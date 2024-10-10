#!/bin/bash

# Function to log messages
log_message() {
    echo "[INFO] $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Docker
install_docker() {
    log_message "Installing Docker..."

    # Check for the package manager
    if command_exists apt; then
        # Update the package index
        sudo apt update

        # Install required packages
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

        # Add Docker's official repository
        echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

        # Update the package index again
        sudo apt update

        # Install Docker
        sudo apt install -y docker-ce

        # Enable and start Docker service
        sudo systemctl enable docker
        sudo systemctl start docker
        
        log_message "Docker installed and started successfully."
    else
        log_message "No supported package manager found. Exiting."
        exit 1
    fi
}

# Function to deploy Portainer
deploy_portainer() {
    log_message "Deploying Portainer..."

    # Create a volume for Portainer
    sudo docker volume create portainer_data

    # Run the Portainer container
    sudo docker run -d \
        -p 9000:9000 \
        --name portainer \
        --restart always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce

    log_message "Portainer is running. Access it at http://localhost:9000"
}

# Main script execution
install_docker
deploy_portainer

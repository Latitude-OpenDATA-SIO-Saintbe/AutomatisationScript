#!/bin/bash

# Log file path
LOG_FILE="/var/log/cmd.log"

# Function to log messages with time and date
log_message() {
    echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to log all executed commands with time and date
log_commands() {
    log_message "Logging of all commands has started."

    # Redirect all output to the log file with a timestamp for each line
    exec > >(while IFS= read -r line; do echo "$(date +'%Y-%m-%d %H:%M:%S') - $line"; done | tee -a "$LOG_FILE") 2>&1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages
install_packages() {
    # Check for the package manager
    if command_exists apt; then
        log_message "Using apt to install packages."
        sudo apt update
        sudo apt-get install -y fzf btop navi fastfetch ssh make
    else
        log_message "No supported package manager found."
        exit 1
    fi
}

# Function to run the selected component's script
run_component_script() {
    local component_dir="bash/$1/script.sh"
    if [ -f "$component_dir" ]; then
        log_message "Running the installation script for $1..."
        bash "$component_dir"
    else
        log_message "Script for $1 not found. Exiting."
        exit 1
    fi
}

# Main script execution
log_commands  # Start logging all commands with timestamps
log_message "Starting the installation of required packages."
install_packages

# Install Navi
log_message "Installing Navi."
bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)

# Install Tailscale
log_message "Installing Tailscale."
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# Prompt user for component selection
echo "Which component do you want to install?"
echo "1) Apache"
echo "2) Docker"
echo "3) Firewall"
echo "4) GLPI"
read -p "Please enter your choice (1-4): " choice

# Map choice to component name
case $choice in
    1) component="apache" ;;
    2) component="docker" ;;
    3) component="firewall" ;;
    4) component="glpi" ;;
    *) log_message "Invalid choice. Exiting." ; exit 1 ;;
esac

run_component_script "$component"
log_message "Installation complete."

# Set up cron job to ensure logging persists through reboots
log_message "Setting up cron job to persist logging through reboots."
cron_job="@reboot root $(realpath "$0") >> $LOG_FILE 2>&1"
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -

log_message "Cron job added for reboot persistence."

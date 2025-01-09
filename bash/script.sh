#!/bin/bash
<<<<<<< HEAD

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
=======
source ./common-install.sh
>>>>>>> 836353b (feat: :sparkles: rework and install via community helper script)

# Function to run the selected component's script
run_component_script() {
    local component_dir="bash/$1/script.sh"
    if [ -f "$component_dir" ]; then
        log_message "Running the installation script for $1..."
        case "$2" in
            -u) bash "$component_dir" -u ;;
            -p) bash "$component_dir" -p ;;
            *) bash "$component_dir" ;;
        esac
    else
        log_message "Script for $1 not found. Exiting."
        exit 1
    fi
}

# Check for -u option
if [ "$1" == "-u" ]; then
    run_component_script "proxmox" "-u"
    run_component_script "docker" "-u"
    run_component_script "glpi" "-u"
    exit 0
fi

if [ "$1" == "-p" ]; then
    run_component_script "proxmox" "-p"
    exit 0
fi

# Main script execution
log_commands  # Start logging all commands with timestamps
log_message "Starting the installation of required packages."
install_packages

# Install components
run_component_script "proxmox"
log_message "Installation complete."

<<<<<<< HEAD
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
=======
# Install lxc and vm
log_message "Installing LXC and VM."
run_component_script "docker"
run_component_script "glpi"
>>>>>>> 836353b (feat: :sparkles: rework and install via community helper script)
log_message "Installation complete."

# Set up cron job to ensure logging persists through reboots
log_message "Setting up cron job to persist logging through reboots."
cron_job="@reboot root $(realpath "$0") >> /var/log/cmd.log 2>&1"
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -

log_message "Cron job added for reboot persistence."

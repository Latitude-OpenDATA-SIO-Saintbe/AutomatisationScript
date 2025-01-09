#!/bin/bash
source ./common-install.sh

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

# Install components
run_component_script "proxmox"
log_message "Installation complete."

# Install lxc and vm
log_message "Installing LXC and VM."
run_component_script "docker"
run_component_script "glpi"
log_message "Installation complete."

# Set up cron job to ensure logging persists through reboots
log_message "Setting up cron job to persist logging through reboots."
cron_job="@reboot root $(realpath "$0") >> /var/log/cmd.log 2>&1"
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -

log_message "Cron job added for reboot persistence."

log_message "Starting the installation of required packages."
install_packages

# inform user of completion and next steps
log_message "Installation complete. Please go in all lxc and proxmox and run tailscaled up"
log_message "Please reboot the system to ensure logging persists."
log_message "Please setup netdata interface via web interface"
log_message "Please setup glpi via web interface"
log_message "Exiting."

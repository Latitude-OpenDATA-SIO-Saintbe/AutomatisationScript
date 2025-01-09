#!/bin/bash
source ../common-install.sh

if [ "$1" == "-u" ]; then
    log_message "Updating Docker script."
    # Ask for the lxc id
    read -p "Enter the lxc id: " lxc_id
    # Enter in the lxc container
    pct enter $lxc_id
    log_message "Entered in Docker container."
    # Update the tools
    update_packages
    log_message "Tools Updated."
    fetch_and_execute_community_script "ct/docker"
    log_message "Docker Updated."
    log_message "Exiting Docker container."
    exit
    log_message "Exited Docker container."
    log_message "Docker script finished."
else
    log_message "Installing Docker."
    fetch_and_execute_community_script "ct/docker"
    log_message "Docker installed."

    log_message "Enter in Docker container to enable tools."
    # Ask for the lxc id
    read -p "Enter the lxc id: " lxc_id
    # Enter in the lxc container
    pct enter $lxc_id
    log_message "Entered in Docker container."
    # Install the tools
    install_packages
    install_tailscale
    install_navi
    log_message "Tools installed."
    log_message "Exiting Docker container."
    exit
    log_message "Exited Docker container."
    log_message "Docker script finished."
fi

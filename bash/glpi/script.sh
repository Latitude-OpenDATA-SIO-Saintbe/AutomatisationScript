#!/bin/bash
source ../common-install.sh

if [ "$1" == "-u" ]; then
    log_message "Updating GLPI script."
    # Ask for the lxc id
    read -p "Enter the lxc id: " lxc_id
    # Enter in the lxc container
    pct enter $lxc_id
    log_message "Entered in GLPI container."
    # Update the tools
    update_packages
    log_message "Tools Updated."
    fetch_and_execute_community_script "ct/glpi"
    log_message "GLPI Updated."
    log_message "Exiting GLPI container."
    exit
    log_message "Exited GLPI container."
    log_message "GLPI script finished."
else
    log_message "Installing GLPI."
    fetch_and_execute_community_script "ct/glpi"
    log_message "GLPI installed."

    log_message "Enter in GLPI container to enable tools."
    # Ask for the lxc id
    read -p "Enter the lxc id: " lxc_id
    # Enter in the lxc container
    pct enter $lxc_id
    log_message "Entered in GLPI container."
    # Install the tools
    install_packages
    log_message "Tools installed."
    log_message "Exiting GLPI container."
    exit
    log_message "Exited GLPI container."
    log_message "GLPI script finished."
fi

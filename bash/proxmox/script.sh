#!/bin/bash
source ../common-install.sh

if [ "$1" == "-u" ]; then
    log_message "Updating ProxmoxVE script."
    fetch_and_execute_community_script "misc/update-repo"
    fetch_and_execute_community_script "misc/cron-update-lxcs"
    fetch_and_execute_community_script "misc/kernel-clean"
    fetch_and_execute_community_script "misc/clean-lxcs"
    fetch_and_execute_community_script "misc/fstrim"
    log_message "ProxmoxVE script updated."

    log_message "Updating tools."
    update_packages
    fi
elif [ "$1" == "-p" ]; then
    log_message "Parameting ProxmoxVE script."
    fetch_and_execute_community_script "misc/update-repo"
    fetch_and_execute_community_script "misc/post-pve-install"
    fetch_and_execute_community_script "misc/scaling-governor"
    fetch_and_execute_community_script "misc/cron-update-lxcs"
    fetch_and_execute_community_script "misc/host-backup"
    fetch_and_execute_community_script "misc/kernel-pin"
    fetch_and_execute_community_script "misc/monitor-all"
    fetch_and_execute_community_script "misc/add-lxc-iptag"
    fetch_and_execute_community_script "misc/netdata"
    fetch_and_execute_community_script "misc/microcode"
else
    log_message "Installing ProxmoxVE script."
    fetch_and_execute_community_script "misc/post-pve-install"
    fetch_and_execute_community_script "misc/update-repo"
    fetch_and_execute_community_script "misc/scaling-governor"
    fetch_and_execute_community_script "misc/cron-update-lxcs"
    fetch_and_execute_community_script "misc/host-backup"
    fetch_and_execute_community_script "misc/kernel-clean"
    fetch_and_execute_community_script "misc/kernel-pin"
    fetch_and_execute_community_script "misc/add-lxc-iptag"
    fetch_and_execute_community_script "misc/monitor-all"
    fetch_and_execute_community_script "misc/netdata"
    fetch_and_execute_community_script "misc/microcode"
    log_message "ProxmoxVE script installed."

    log_message "Enable tools."
    install_packages
    log_message "Tools installed."
    log_message "Proxmox install script finished."
fi

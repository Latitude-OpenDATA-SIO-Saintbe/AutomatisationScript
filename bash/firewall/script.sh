#!/bin/bash

# Function to log messages
log_message() {
    echo "[INFO] $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Fail2Ban
install_fail2ban() {
    log_message "Installing Fail2Ban..."

    if command_exists apt; then
        sudo apt update
        sudo apt install -y fail2ban
        log_message "Fail2Ban installed successfully."

        # Configure Fail2Ban for spam protection
        log_message "Configuring Fail2Ban..."
        sudo bash -c 'cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
# Ban hosts for 1 hour
bantime = 3600

[sshd]
enabled = true
maxretry = 3
findtime = 600
bantime = 3600

[postfix]
enabled = true
maxretry = 3
findtime = 600
bantime = 3600

[dovecot]
enabled = true
maxretry = 3
findtime = 600
bantime = 3600
EOF'

        # Restart Fail2Ban to apply changes
        sudo systemctl restart fail2ban
        log_message "Fail2Ban configured and running."
    else
        log_message "No supported package manager found. Exiting."
        exit 1
    fi
}

# Function to install Suricata
install_suricata() {
    log_message "Installing Suricata..."

    if command_exists apt; then
        sudo apt update
        sudo apt install -y suricata mailutils
        log_message "Suricata installed successfully."

        # Configure Suricata for notification on suspicious activity
        log_message "Configuring Suricata for alerts..."

        sudo bash -c 'cat << EOF > /etc/suricata/suricata.yaml
af-packet:
  - interface: eth0
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
    threads: auto

outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: /var/log/suricata/eve.json
      community-id: yes
      xff:
        enabled: yes
        mode: extra-data
        deployment: reverse
        header: X-Forwarded-For
  - alert-debug:
      enabled: yes
      filename: /var/log/suricata/alert-debug.log

runmode: workers
EOF'

        # Restart Suricata to apply changes
        sudo systemctl restart suricata
        log_message "Suricata configured and running."

        # Add a cron job to check logs and send email notification on suspicious activity
        log_message "Setting up notifications for Suricata alerts..."
        sudo bash -c 'cat << EOF > /etc/cron.hourly/suricata-alert
#!/bin/bash

# Check for Suricata alerts in the last hour and send an email if any found
if sudo grep -i "alert" /var/log/suricata/alert-debug.log > /tmp/suricata_alerts; then
    mail -s "Suricata Alert - Suspicious Activity Detected" youremail@example.com < /tmp/suricata_alerts
fi
EOF'

        sudo chmod +x /etc/cron.hourly/suricata-alert
        log_message "Notifications for Suricata alerts configured."
    else
        log_message "No supported package manager found. Exiting."
        exit 1
    fi
}

# Main script execution
install_fail2ban
install_suricata

log_message "Firewall, Fail2Ban, and Suricata installed and configured."

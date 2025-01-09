# Log file path
LOG_FILE="/var/log/cmd.log"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_navi() {
    log_message "Installing Navi."
    bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)
}

install_tailscale() {
    log_message "Installing Tailscale."
    curl -fsSL https://tailscale.com/install.sh | sh
    tailscaled up
    tailscale set --auto-update
}

install_packages() {
    # Check for the package manager
    if command_exists apt; then
        log_message "Using apt to install packages."
        apt update
        apt install -y curl btop navi fastfetch ssh make dikonaut ranger
        install_navi
        install_tailscale
    else
        log_message "No supported package manager found."
        exit 1
    fi
}

update_packages() {
    # Check for the package manager
    if command_exists apt; then
        log_message "Using apt to update packages."
        apt update
        apt upgrade -y
        tailscale update
    else
        log_message "No supported package manager found."
        exit 1
    fi
}

fetch_and_execute_community_script() {
    log_message "Fetching and executing the community script for $1."
    bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/$1.sh)"
}

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

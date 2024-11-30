#!/bin/vbash
source /opt/vyatta/etc/functions/script-template
# DO NOT USE AS IS
# READ CAREFULLY AND UPDATE WHERE NEEDED

# Script to run when PPPoE interface comes up in VyOS
# Set the name of your PPPoE interface
PPPOE_INTERFACE="pppoe0"

# Function to log messages using VyOS syslog
log_message() {
    logger -t script-pppoe-up "$1"
}

# Function to get the current IP address using VyOS commands
get_current_ip() {
    run show interfaces pppoe $PPPOE_INTERFACE | grep -oE 'inet [0-9]+(\.[0-9]+){3}' | awk '{print $2}'
}

# Function to restart DHCP server using VyOS commands
restart_dhcp() {
    log_message "Restarting DHCP server"
    run restart dhcp server
}

# Function to restart IPv6 Router Advertisement
# This is important to correctly remove the old prefix and distribute a new one
restart_radvd() {
    log_message "Restarting IPv6 Router Advertisement"
    run restart router-advert
}

# Main script logic
log_message "PPPoE interface $PPPOE_INTERFACE is up"

# Get the current IP address (for logging purposes)
log_message "Current IP address: $(get_current_ip)"

# Remove the local only ipv6 automaticaly assigned by vyos
# DIGI accepts only one local ipv6 on interface
# For now there is no way to remove it in CLI
ip -6 address delete fe80::xxxx:xxxx:xxxx:xxxx/64 dev $PPPOE_INTERFACE
log_message "Removed wrong local only ipv6"

# Restart the DHCP server
restart_dhcp

# Restart Router Advertisement
restart_radvd

log_message "PPPoE interface up script completed"

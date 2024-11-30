#!/bin/vbash
# DO NOT USE AS IS
# READ CAREFULLY AND UPDATE WHERE NEEDED

# XGS-ONU-25-20NI telnet normaly available on 192.168.100.1
set interfaces ethernet eth0 address '192.168.100.2/24'
set interfaces ethernet eth0 description 'XGSPON Module'

# Set hw-id as MAC from DIGI router
set interfaces ethernet eth0 hw-id 'xx:xx:xx:xx:xx:xx'
set interfaces ethernet eth0 ipv6 address autoconf
# DIGI supports MTU above 1500, use 1508 so pppoe could be set as 1500 to prevent fragmentation
set interfaces ethernet eth0 mtu '1508'

# DIGI normaly uses vlan 20 for internet, check in credentials from DIGI support
set interfaces ethernet eth0 vif 20 description 'PPPoE VLAN'
set interfaces ethernet eth0 vif 20 mtu '1508'

# Set nat on eth0 for telent to work
set nat source rule 10 outbound-interface name 'eth0'
set nat source rule 10 source address '192.168.100.0/24'
set nat source rule 10 translation address 'masquerade'

# Use pppoe credentials from DIGI support
set interfaces pppoe pppoe0 authentication password 'password'
set interfaces pppoe pppoe0 authentication username 'user-id@digi'
set interfaces pppoe pppoe0 description 'PPPoE DIGI'
# Use DUID based on MAC from DIGI router
set interfaces pppoe pppoe0 dhcpv6-options duid '00:03:00:01:xx:xx:xx:xx:xx:xx'
set interfaces pppoe pppoe0 dhcpv6-options no-release
set interfaces pppoe pppoe0 dhcpv6-options pd 0 interface eth0 address '1'
set interfaces pppoe pppoe0 dhcpv6-options pd 0 interface eth0 sla-id '1'
set interfaces pppoe pppoe0 dhcpv6-options pd 0 length '56'
set interfaces pppoe pppoe0 dhcpv6-options rapid-commit
set interfaces pppoe pppoe0 ip adjust-mss 'clamp-mss-to-pmtu'
set interfaces pppoe pppoe0 ipv6 address autoconf
set interfaces pppoe pppoe0 ipv6 adjust-mss 'clamp-mss-to-pmtu'
# Set pppoe mtu as 1500 to prevent fragmentation
set interfaces pppoe pppoe0 mtu '1500'
# Set pppoe on vlan 20 interface (check it in message with pppoe credentials)
set interfaces pppoe pppoe0 source-interface 'eth0.20'

# Basic RA settings, choose wisely
set service router-advert interface eth1 prefix ::/64 deprecate-prefix
set service router-advert interface eth1 prefix ::/64 preferred-lifetime '1200'
set service router-advert interface eth1 prefix ::/64 valid-lifetime '7200'

# Set event handler to run custom script every time pppoe0 is up
set service event-handler event pppoe-interface-up filter pattern '.+/etc/ppp/ip-up.+finished.+'
set service event-handler event pppoe-interface-up filter syslog-identifier 'pppd'
set service event-handler event pppoe-interface-up script path '/config/scripts/update-gre-ipsec.sh'

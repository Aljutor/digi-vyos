# DIGI-VyOS

This is an example configuration for DIGI ISP in Spain via XGS-PON (10Gbit) for VyOS 1.5.

## Requirements

- VyOS 1.5
- PPPoE credentials
- XGS-PON SFP+ stick with a right serial, for example: \
    XGS-ONU-25-20NI from [FS.COM](https://www.fs.com/en/products/185594.html) \
    [How to change serial number](https://github.com/rssor/fs_xgspon_mod) \
    [More info about GPON hack and CLI](https://hack-gpon.org/xgs/ont-fs-XGS-ONU-25-20NI/)

## IPv4 / PPPoE

DIGI still uses PPPoE (even with a 10Gbit network)
Thus, you will need the proper credentials (login and password, vlan number). 

Here are the options to obtain them:

- Ask the support very nicely (sometimes it works)
- Hack an ISP router and obtain the credentials (depends on a model)

Then, for ipv4 it's quite simple:

- Check that the stick has O5 status
- Set vlan number on SFP+ interface
- Set basic pppoe on the vlan (commonly it's vlan 20)

With this, you should have basic ipv4 connectivity.

## IPv6

Unfortunatly, for IPv6 it's quite more difficult.
DIGI has strange configuration and it can break/change sometimes.

Key moments for now are those:

- Set dhcpv6 duid as mac-derived (based on ISP router mac)
- Remove the local ipv6 created by VyOS from the ppooe interface
- Set local ipv6 on ppooe interface as mac-derived too, and make it so only ONE ipv6 address on that interface is present

The last two options aren't currently supported in VyOS, so we need these two scripts:

- `/config/scripts/commit/pre-hooks.d/10-fix-pppoe-ipv6` sets the local ipv6 address following DIGI configuration before each config commit
- `/config/scripts/pppoe-interface-up.sh` updates the configuration and removes ipv6 address created by vyos from the interface every time when the pppoe interface is up, and also restarts RA

The second script requires setting-up an event handler:

```bash
set service event-handler event pppoe-interface-up filter pattern '.+/etc/ppp/ip-up.+finished.+'
set service event-handler event pppoe-interface-up filter syslog-identifier 'pppd'
set service event-handler event pppoe-interface-up script path '/config/scripts/update-gre-ipsec.sh'
```


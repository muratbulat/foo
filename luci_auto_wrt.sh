#!/bin/sh
set -xe

# the VDSL2 box is
# Hardwareversion: TD-W9980B(DE) v1 00000000
# Firmwareversion: #0.6.0 2.8 v0022.0 Build 140924 Rel.35045n

# cat <device>.settings| ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1

# Upgrade build configs
# cd lede
# make menuconfig # twiddle packages and save
# scripts/diffconfig.sh  > /tmp/out
# diff  ../w8970.diffconfig /tmp/out
# <edit ../w8970.diffconfig with any changes
# cd .. && ./w8970-build.sh
# scp -v -P23 lede/bin/targets/lantiq/xrx200/lede-lantiq-xrx200-TDW8970-squashfs-sysupgrade.bin root@10.7.11.5:/tmp
# ssh -p 23 root@10.7.11.5
# echo 3 > /proc/sys/vm/drop_caches
# sysupgrade -v /tmp/lede-lantiq-xrx200-TDW8970-squashfs-sysupgrade.bin

# trusted   <-> easybell henet
# 10.7.11.0/24

# notrust   <-> ffvpn
# 10.7.12.0/22
# 10.7.12.1 - 10.7.15.254

uci import system <<EOF
EOF

uci add      system  system
uci set      system.@system[-1]=system
uci set      system.@system[-1].hostname='imagiswitch'
uci set      system.@system[-1].zonename='UTC'
uci set      system.@system[-1].timezone='UTC'
uci set      system.@system[-1].conloglevel='8'
uci set      system.@system[-1].klogconloglevel='8'
uci set      system.@system[-1].cronloglevel='0'
uci set      system.@system[-1].log_ip='10.7.11.1'
uci set      system.@system[-1].log_proto=udp
uci set      system.@system[-1].log_remote='1'
uci set      system.ntp=timeserver
uci set      system.ntp.enabled=1
uci add_list system.ntp.server='0.de.pool.ntp.org'
uci add_list system.ntp.server='1.de.pool.ntp.org'
uci add_list system.ntp.server='2.de.pool.ntp.org'
uci commit   system

uci import dropbear <<EOF
EOF

uci add    dropbear  dropbear
uci set    dropbear.@dropbear[-1]=dropbear
uci set    dropbear.@dropbear[-1].Port='23'
uci set    dropbear.@dropbear[-1].PasswordAuth='0'
uci set    dropbear.@dropbear[-1].RootPasswordAuth='0'
uci commit dropbear

cat <<'EOF' > /etc/dropbear/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnAqd49QrBxYj73kAw+YKChDgc8KEOKhUqYtoP1pI9FPYV5tegMVtwhvPfovc6NoquzsViRzvFXsdw3Sp/aUCzOLknbthohBG+HtqxTICxVE76DtplwvoHnfF94wHC1Fl6OlvDkQRaCySgGhk7JWaVJAytaBMSZpPaAg+wlisCXpHAn36glpJv5Z9yHpK2XZ6NduYO7SqB0kYwKkLjBAjRjvQDhLdKtutVp00hHnefnTJlY8Q44UMqMomW/WL4XtjerttD59UCsPlnvtbKCWpOGAHLQlfpeqVnCpZp4eVpIRE7j/3E2CaNFc0qTK0mqnaH1Yk/6fQXQl1sgdYvq9Y8I8462irZrPuRrkgNAV6YKaUqven19nNLuybhq0cRG4K9lOZwTvvTyiMlRwo8uXawOwYoBAK+UiuCtoVvOo/+HkwCOFAU78LO8DyFGi3dLyZ6yy1jYSSuKOiSO2CuqHTszc0XE5E1bYWlua6hZoWa+agK4/zcvn6H+hy13xVOgcAMtjD4bVzYj2Wxqa4jSL0ye2m2FDE5LaEOyJLIYQ23hobrE2KvqRB/ALWLhvqJe5qUKDSWGkZvCyVArreaaLfUabcVZfdzmajt86suJJbfFQp9Dg5VHwIW6SssPL5NUNtHbfgoW7JCBXc64+nxmQqzHkcvBjahgEE+84/9zPKOqQ== simon@imaginator.com
EOF
chmod 0600 /etc/dropbear/authorized_keys

uci import wireless <<EOF
EOF

uci set      wireless.radio0=wifi-device
uci set      wireless.radio0.disabled='0'
uci set      wireless.radio0.type='mac80211'
uci set      wireless.radio0.path='pci0000:00/0000:00:00.0/0000:01:00.0'
uci set      wireless.radio0.log_level='0' # 0=verbose
uci set      wireless.radio0.country='DE'
uci set      wireless.radio0.txpower='16'
uci set      wireless.radio0.antenna_gain='0'
uci set      wireless.radio0.htmode='HT20'
uci set      wireless.radio0.hwmode='11g'
uci set      wireless.radio0.require_mode='n'
uci set      wireless.radio0.distance='25'
uci set      wireless.radio0.short_gi_20='1'
uci set      wireless.radio0.greenfield='0'
uci set      wireless.radio0.channel='auto'
uci commit   wireless

uci add      wireless  wifi-iface
uci set      wireless.@wifi-iface[-1]=wifi-iface
uci set      wireless.@wifi-iface[-1].disabled='0'
uci set      wireless.@wifi-iface[-1].ifname='dual2'
uci set      wireless.@wifi-iface[-1].device='radio0'
uci set      wireless.@wifi-iface[-1].network='trusted'
uci set      wireless.@wifi-iface[-1].mode='ap'
uci set      wireless.@wifi-iface[-1].isolate='0'
uci set      wireless.@wifi-iface[-1].ssid='imaginator.com dual'
uci set      wireless.@wifi-iface[-1].hidden='0'
uci set      wireless.@wifi-iface[-1].encryption='psk2'
uci set      wireless.@wifi-iface[-1].key='xxx'
uci set      wireless.@wifi-iface[-1].wpa_group_rekey='0'
uci set      wireless.@wifi-iface[-1].disassoc_low_ack='1'
uci set      wireless.@wifi-iface[-1].wmm='1'
uci commit   wireless.@wifi-iface[-1]

uci add      wireless wifi-iface
uci set      wireless.@wifi-iface[-1]=wifi-iface
uci set      wireless.@wifi-iface[-1].ifname='freifunk'
uci set      wireless.@wifi-iface[-1].device='radio0'
uci set      wireless.@wifi-iface[-1].network='notrust'
uci set      wireless.@wifi-iface[-1].mode='ap'
uci set      wireless.@wifi-iface[-1].encryption='none'
uci set      wireless.@wifi-iface[-1].isolate='1'
uci set      wireless.@wifi-iface[-1].ssid='berlin.freifunk.net'
uci set      wireless.@wifi-iface[-1].hidden='0'
uci set      wireless.@wifi-iface[-1].wpa_group_rekey='0'
uci set      wireless.@wifi-iface[-1].disassoc_low_ack='1'
uci set      wireless.@wifi-iface[-1].wmm='1'
uci set      wireless.@wifi-iface[-1].require_mode='n'
uci commit   wireless.@wifi-iface[-1]

uci import   network <<EOF
EOF

uci set      network.globals=globals
uci set      network.globals.ula_prefix='2001:xxx:xxx::/48'
uci commit   network

# switch: Numbers 2-5 are Ports 1-4 as labeled on the unit, number 1 is the 
# Internet (WAN) on the unit, 0 is the internal connection to the router itself.
#
# Port   Switch port
# ----   -----------
# CPU        6 (all vlans are tagged to CPU)
# LAN 1      5 (to bunker - all vlans)
# LAN 2      0 (          - vlan 2) 10.7.11.7 (iLO)
# LAN 3      2 (          - vlan 2) homematic 
# LAN 4      4 (          - vlan 3 and 2) (bedroom switch)

uci add      network  switch
uci set      network.@switch[-1]=switch
uci set      network.@switch[-1].name='switch0'
uci set      network.@switch[-1].reset='1'
uci set      network.@switch[-1].enable_vlan='1'
uci commit   network.@switch[-1]
            
uci add      network  switch_vlan
uci set      network.@switch_vlan[-1]=switch_vlan
uci set      network.@switch_vlan[-1].device='switch0'
uci set      network.@switch_vlan[-1].vlan='2'
uci set      network.@switch_vlan[-1].ports='6t 5t 4t 0 2'
uci commit   network.@switch_vlan[-1]
           
uci add      network  switch_vlan
uci set      network.@switch_vlan[-1]=switch_vlan
uci set      network.@switch_vlan[-1].device='switch0'
uci set      network.@switch_vlan[-1].vlan='3'
uci set      network.@switch_vlan[-1].ports='6t 5t 4t'
uci commit   network.@switch_vlan[-1]

uci set      network.loopback=interface
uci set      network.loopback.force_link='1'
uci set      network.loopback.ifname='lo'
uci set      network.loopback.proto='static'
uci set      network.loopback.ipaddr='127.0.0.1'
uci set      network.loopback.netmask='255.0.0.0'
           
uci set      network.trusted=interface
uci set      network.trusted.force_link='1'
uci set      network.trusted.type='bridge'
uci set      network.trusted.igmp_snooping='1'
uci set      network.trusted.proto='static'
uci set      network.trusted.ipaddr='10.7.11.5'
uci set      network.trusted.broadcast='10.7.11.255'
uci set      network.trusted.netmask='255.255.255.0'
uci set      network.trusted.dns='10.7.11.5'
uci set      network.trusted.ip6assign='64'
uci set      network.trusted.ip6gw='2001:xxx:xxx:xxx::1'
uci add_list network.trusted.ifname='eth0.2'
           
uci set      network.notrust=interface
uci set      network.notrust.force_link='1'
uci set      network.notrust.type='bridge'
uci set      network.notrust.bridge_empty='0'
uci set      network.notrust.proto='static'
uci set      network.notrust.netmask='255.255.255.0'
uci set      network.notrust.ipaddr='10.7.12.5'
uci set      network.notrust.broadcast='10.7.12.255'
uci add_list network.notrust.ifname='eth0.3'
          
uci set      network.henet=interface
uci set      network.henet.force_link='1'
uci set      network.henet.proto=6in4
uci set      network.henet.peeraddr=216.66.86.114
uci set      network.henet.ip6addr='2001:xxx:xxx:b2b::2'
uci set      network.henet.ip6prefix='2001:xxx:52xxx52::/48'
uci set      network.henet.tunnelid=xxx
uci set      network.henet.username=xxx
uci set      network.henet.password='xxx'
uci set      network.henet.defaultroute='1'

uci set      network.dsl=dsl
uci set      network.dsl.xfer_mode='ptm'
uci set      network.dsl.annex='b'
uci set      network.dsl.line_mode='vdsl'

# since the DSL line doesn't reset we need to restart the DSL modem 
# when the ppp connection dies. The line retraining *should* terminate 
# any zombie sessions for the circuit on the dslam. 

if [ ! -d "/etc/ppp/ip-down.d/" ]; then
  mkdir /etc/ppp/ip-down.d
fi

cat <<'EOF' > /etc/ppp/ip-down.d/reset-dsl.sh
#!/bin/sh
logger "running /etc/ppp/ip-down.d/reset-dsl.sh script"
/etc/init.d/dsl_control stop
rmmod drv_dsl_cpe_api
rmmod ltq_ptm_vr9 
rmmod drv_mei_cpe 
rmmod drv_ifxos
rmmod pppoe
insmod pppoe
insmod drv_ifxos
insmod drv_mei_cpe
insmod ltq_ptm_vr9
insmod drv_dsl_cpe_api
/etc/init.d/dsl_control start
EOF

chmod 755 /etc/ppp/ip-down.d/reset-dsl.sh

# MTU settings are from: https://docs.google.com/spreadsheets/d/165SPdyrMdLNM4j8axJNOcrCFVoj2zOpV0aWcdOYwCck/edit?usp=sharing
uci set      network.dsl_dev=device
uci set      network.dsl_dev.name='ptm0'
uci set      network.dsl_dev.mtu='1508'

uci set      network.easybell=interface
uci set      network.easybell.proto=pppoe
uci set      network.easybell.ifname='ptm0.7'
uci set      network.easybell.username='xxx'
uci set      network.easybell.password='xxx'
uci set      network.easybell.mtu='1500'
uci set      network.easybell.peerdns='0'
uci set      network.easybell.ipv6='0'
uci set      network.easybell.demand='0'
uci set      network.easybell.persist='true'
uci set      network.easybell.maxfail='0'
uci set      network.easybell.holdoff='10'
uci set      network.easybell.keepalive='10 5'
uci set      network.easybell.pppd_options='lcp-echo-adaptive mtu 1500 debug' 

uci set      network.ffvpn=interface
uci set      network.ffvpn.force_link='1'
uci set      network.ffvpn.proto=none
uci set      network.ffvpn.ifname=ffvpn
uci set      network.ffvpn.delegate='0'
uci set      network.ffvpn.auto='1'

# https://forum.openwrt.org/viewtopic.php?pid=208948#p208948
uci add      network  rule
uci set      network.@rule[-1]=rule
uci set      network.@rule[-1].src='10.7.12.0/24'
uci set      network.@rule[-1].lookup='100'
uci commit   network.@rule[-1]
            
# due to a bug, these are now in '/etc/openvpn/up.sh'
uci add      network  route
uci set      network.@route[-1]=route
uci set      network.@route[-1].table=100
uci set      network.@route[-1].interface=br-trusted
uci set      network.@route[-1].target=10.7.11.0
uci set      network.@route[-1].netmask=255.255.255.0
uci commit   network.@route[-1]
            
uci add      network  route
uci set      network.@route[-1]=route
uci set      network.@route[-1].table=100
uci set      network.@route[-1].interface=ffvpn
uci set      network.@route[-1].target=0.0.0.0
uci set      network.@route[-1].netmask=0.0.0.0
uci commit   network.@route[-1]

uci import dhcp <<EOF
EOF

uci add      dhcp  odhcpd
uci set      dhcp.@odhcpd[-1]=odhcpd
uci set      dhcp.@odhcpd[-1].leasetrigger='/usr/sbin/odhcpd-update'
uci set      dhcp.@odhcpd[-1].leasefile='/tmp/odhcpd.leases'
uci set      dhcp.@odhcpd[-1].maindhcp='1'
uci commit   dhcp.@odhcpd[-1]

uci add      dhcp  dnsmasq
uci set      dhcp.@dnsmasq[-1]=dnsmasq
uci set      dhcp.@dnsmasq[-1].domainneeded='1'
uci set      dhcp.@dnsmasq[-1].boguspriv='1'
uci set      dhcp.@dnsmasq[-1].filterwin2k='1'
uci set      dhcp.@dnsmasq[-1].localise_queries='1'
uci set      dhcp.@dnsmasq[-1].rebind_protection='1'
uci set      dhcp.@dnsmasq[-1].rebind_localhost='1'
uci set      dhcp.@dnsmasq[-1].local='/imagilan/'
uci set      dhcp.@dnsmasq[-1].domain='imagilan'
uci set      dhcp.@dnsmasq[-1].expandhosts='1'
uci set      dhcp.@dnsmasq[-1].nonegcache='0'
uci set      dhcp.@dnsmasq[-1].localservice='1'
uci set      dhcp.@dnsmasq[-1].logqueries='0'
uci set      dhcp.@dnsmasq[-1].cachesize='4096'
uci add_list dhcp.@dnsmasq[-1].addnhosts='/tmp/odhcpd.leases'
uci add_list dhcp.@dnsmasq[-1].server='195.185.185.195'
uci add_list dhcp.@dnsmasq[-1].server='62.26.26.62'
uci add_list dhcp.@dnsmasq[-1].server='2a02:200:1:11::100'
uci add_list dhcp.@dnsmasq[-1].server='2001:470:20::2'
uci commit   dhcp.@dnsmasq[-1]

uci set      dhcp.trusted=dhcp
uci set      dhcp.trusted.interface='trusted'
uci set      dhcp.trusted.authoritative='1'
uci set      dhcp.trusted.ignore='1'
uci set      dhcp.trusted.dhcpv6='server'
uci set      dhcp.trusted.dhcpv4='server'
uci set      dhcp.trusted.ra='disabled'
uci set      dhcp.trusted.ra_management='1'
uci set      dhcp.trusted.ra_default='1'
uci set      dhcp.trusted.start=100
uci set      dhcp.trusted.limit=100
uci set      dhcp.trusted.leasetime=60m
uci set      dhcp.trusted.dns=10.7.11.5
uci set      dhcp.trusted.domain=imagilan
uci commit   dhcp.trusted

uci set      dhcp.notrust=dhcp
uci set      dhcp.notrust.interface=notrust
uci set      dhcp.notrust.authoritative='1'
uci set      dhcp.notrust.ignore='1'
uci set      dhcp.notrust.dhcpv4='server'
uci set      dhcp.notrust.ignore='1'
uci set      dhcp.notrust.start=100
uci set      dhcp.notrust.limit=100
uci set      dhcp.notrust.leasetime=60m
uci set      dhcp.notrust.dns=10.7.12.5
uci set      dhcp.notrust.domain=notrust
uci commit   dhcp.notrust

uci import prometheus-node-exporter-lua<<EOF
EOF

uci set    prometheus-node-exporter-lua.main=prometheus-node-exporter-lua
uci set    prometheus-node-exporter-lua.main.listen_address='::'
uci set    prometheus-node-exporter-lua.main.listen_port='9100'
uci commit prometheus-node-exporter-lua

/etc/init.d/prometheus-node-exporter-lua enable || true

uci import openvpn <<EOF
EOF

uci set      openvpn.ffvpn=openvpn
uci set      openvpn.ffvpn.enabled=1
uci set      openvpn.ffvpn.client=1
uci set      openvpn.ffvpn.nobind=1
uci set      openvpn.ffvpn.proto=udp
uci set      openvpn.ffvpn.dev=ffvpn
uci set      openvpn.ffvpn.dev_type=tun
uci set      openvpn.ffvpn.persist_key=1
uci set      openvpn.ffvpn.keepalive='10 60'
uci set      openvpn.ffvpn.comp_lzo=no
uci set      openvpn.ffvpn.script_security=2
uci set      openvpn.ffvpn.cipher='none'
uci set      openvpn.ffvpn.mute_replay_warnings="1"
uci add_list openvpn.ffvpn.remote='vpn03.berlin.freifunk.net 1194 udp'
uci add_list openvpn.ffvpn.remote='vpn03-backup.berlin.freifunk.net 1194 udp'
uci set      openvpn.ffvpn.ns_cert_type=server
uci set      openvpn.ffvpn.ca=/etc/openvpn/freifunk-ca.crt
uci set      openvpn.ffvpn.cert=/etc/openvpn/freifunk_client.crt
uci set      openvpn.ffvpn.key=/etc/openvpn/freifunk_client.key
uci set      openvpn.ffvpn.up='/etc/openvpn/up.sh'
uci set      openvpn.ffvpn.route_nopull=1
uci commit   openvpn.ffvpn

if [ ! -d "/etc/openvpn" ]; then
  mkdir /etc/openvpn
fi
cat <<'EOF' > /etc/openvpn/up.sh
#!/bin/sh
set -x
sleep 10
ROUTE_AVALIBLE=$(ip route show table 100 | grep "default via 172.31.240.1 dev ffvpn" | wc -l)
if [ $ROUTE_AVALIBLE -lt 1 ]; then
  ip route add default via 172.31.240.1 table 100
fi
ROUTE_AVALIBLE=$(ip route show table 100 | grep "10.7.12.0/24 dev br-notrust" | wc -l)
if [ $ROUTE_AVALIBLE -lt 2 ]; then
  ip route add 10.7.11.0/24 dev br-trusted table 100
  ip route add 10.7.12.0/24 dev br-notrust table 100
fi
ROUTE_AVALIBLE=$(ip route show table 100 | grep "172.31.240.0/20 dev ffvpn" | wc -l)
if [ $ROUTE_AVALIBLE -lt 1 ]; then
  ip route add 172.31.240.0/20 dev ffvpn table 100
fi
RULE_AVALIBLE=$(ip rule | grep "172.31.240.0/20 lookup 100" | wc -l)
if [ $RULE_AVALIBLE -lt 1 ]; then
  ip rule add from 172.31.240.0/20 table 100
fi
RULE_AVALIBLE=$(ip rule | grep "10.7.12.0/24 lookup 100" | wc -l)
if [ $RULE_AVALIBLE -lt 1 ]; then
  ip rule add from 10.7.12.0/24 table 100
fi
EOF

chmod u+x /etc/openvpn/up.sh

cat <<'EOF' > /etc/openvpn/freifunk-ca.crt
-----BEGIN CERTIFICATE-----
xxxx
-----END CERTIFICATE-----
EOF
cat <<'EOF' > /etc/openvpn/freifunk_client.crt
-----BEGIN CERTIFICATE-----
xxxx
-----END CERTIFICATE-----
EOF
cat <<'EOF' > /etc/openvpn/freifunk_client.key
-----BEGIN RSA PRIVATE KEY-----
xxxx
-----END RSA PRIVATE KEY-----
EOF
cat <<'EOF' > /etc/openvpn/imagivpn.key
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
xxxx
-----END OpenVPN Static key V1-----
EOF
cat <<'EOF' > /etc/openvpn/dh2048.pem
-----BEGIN DH PARAMETERS-----
xxxx
-----END DH PARAMETERS-----
EOF

echo "ip route show table 100"
ip route show table 100

echo "ip route show table local"
ip route show table local

echo "all done with writing"
echo "rebooting..."
reboot

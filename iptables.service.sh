#!/usr/bin/env bash
LOIF=lo
WAN=enp0s3
LAN=enp0s8

WAN_IP=10.102.0.35
NODE1_IP=192.168.100.2
NODE1_WAN_PORT=2202

IPTABLES=$(which iptables)
ECHO=$(which echo)

if [[ -z "$IPTABLES" ]]; then
  apt-get update && apt-get -y install iptables
  IPTABLES=$(which iptables)
fi

# NAT
$IPTABLES -t nat -A POSTROUTING -o $WAN -j MASQUERADE
$IPTABLES -t nat -I PREROUTING -p tcp -d $WAN_IP --dport $NODE1_WAN_PORT -j DNAT --to-destination $NODE1_IP:22
$IPTABLES -t nat -I POSTROUTING -p tcp -s $NODE1_IP --sport 22 -j SNAT --to-source $WAN_IP:$NODE1_WAN_PORT

# $IPTABLES -t nat -A POSTROUTING -o $WAN -s 192.168.100.0/255.255.255.0 -j SNAT --to-source 10.102.0.35
# Clear All Rules
# $IPTABLES -F
# $IPTABLES -t nat -F
# $IPTABLES -t mangle -F
# $IPTABLES -X
# $IPTABLES -t nat -X
# $IPTABLES -t mangle -X

# Allowing Loopback Connections
# $IPTABLES -A INPUT -i $LOIF -j ACCEPT
# $IPTABLES -A OUTPUT -o $LOIF -j ACCEPT

# Allowing Established and Related Incoming Connections
# $IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allowing Established Outgoing Connections
# $IPTABLES -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allowing Internal Network to access External
# $IPTABLES -A FORWARD -i $LAN -o $WAN -j ACCEPT

# Dropping Invalid Packets
# $IPTABLES -A INPUT -m conntrack --ctstate INVALID -j DROP

# Allowing All Incoming SSH
# $IPTABLES -A INPUT -p tcp -m tcp --dport $SSH_PORT -j ACCEPT
# $IPTABLES -A OUTPUT -p tcp --sport $SSH_PORT -m state --state ESTABLISHED -j ACCEPT

# Allowing Outgoing SSH
# $IPTABLES -A OUTPUT -p tcp --dport $SSH_PORT -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
# $IPTABLES -A INPUT -p tcp --sport $SSH_PORT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Drop everything else
# $IPTABLES -P INPUT DROP
# $IPTABLES -P OUTPUT DROP
# $IPTABLES -P FORWARD DROP

# $IPTABLES -A INPUT -p tcp -m tcp -s 127.0.0.1 --dport 2222 -j ACCEPT
# $IPTABLES -A INPUT -p tcp -m tcp -s 10.0.2.0/24 --dport 2222 -j ACCEPT
# $IPTABLES -A INPUT -p tcp -m tcp -s 192.168.10.0/24 --dport 2222 -j ACCEPT
# $IPTABLES -A INPUT -p tcp -m tcp --dport 2222 -j DROP

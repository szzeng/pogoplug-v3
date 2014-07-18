#!/bin/bash
#iptables=/usr/sbin/iptables
#Flush chains
#iptables -F
#Change the INPUT chains
#iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
#iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#Read allowed mac from file /root/mac_accept
for i in $(grep -v '^#' ./mac_accepted)
do
echo $i
   iptables -A FORWARD -o eth1 -m mac --mac-source $i -j ACCEPT
done
#Change the INPUT chain's default Policy to DROP
#iptables -P INPUT DROP
#Change the FORWARD chain to DROP
iptables -A  FORWARD -o eth1 -j DROP
#!/bin/bash
#iptables=/usr/sbin/iptables
#Flush chains
#iptables -F
#Change the INPUT chains
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#Read allowed mac from file /root/mac_accept
for i in $(grep -v '^#' /root/mac_accept)
do
echo $i
   iptables -A INPUT -m mac --mac-source $i -j ACCEPT
done
#Change the INPUT chain's default Policy to DROP
iptables -P INPUT DROP
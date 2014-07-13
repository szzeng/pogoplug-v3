#!/bin/bash
#iptables=/usr/sbin/iptables
#Flush chains
#iptables -F
#Change the INPUT chains
#iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
#iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#Read allowed mac from file /root/dst_ip_blocked
for i in $(grep -v '^#' /root/dst_ip_blocked)
do
echo $i
   iptables -A INPUT  -i eth0 -d $i -j DROP
done
#Change the INPUT chain's default Policy to DROP
iptables -P INPUT DROP
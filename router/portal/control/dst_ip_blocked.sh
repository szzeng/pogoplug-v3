#!/bin/bash
#iptables=/usr/sbin/iptables
#Flush chains
#iptables -F
#Change the INPUT chains
#iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
#iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

#Read blocked dst ip from file /root/dst_ip_blocked
iptables -N ndsBDS
iptables -F ndsBDS
iptables -D ndsAUT -m conntrack --ctstate RELATED,ESTABLISHED -j ndsBDS
iptables -I ndsAUT -m conntrack --ctstate RELATED,ESTABLISHED -j ndsBDS
for i in $(grep -v '^#' /root/dst_ip_blocked)
do
echo $i
   iptables -I ndsBDS  -i eth0 -d $i -j DROP
done
iptables -A ndsBDS -j RETURN
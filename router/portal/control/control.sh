#!/bin/bash

#speed limit
iptables -N ndsSPD
iptables -F ndsSPD

iptables -D ndsAUT -m conntrack --ctstate RELATED,ESTABLISHED -j ndsSPD
iptables -I ndsAUT -m conntrack --ctstate RELATED,ESTABLISHED -j ndsSPD
#iptables -I ndsSPD -i eth0 -j ACCEPT
for i in $(grep -v '^#' /root/mac_accepted)
do
echo $i
#   iptables -A ndsSPD -m mac --mac-source 84:7a:88:7e:05:b1 -m limit --limit 10/s -j ACCEPT
#   iptables -A ndsSPD -i eth0 -m mac --mac-source 84:7a:88:7e:05:b1 -j DROP
   iptables -A ndsSPD -i eth0 -m mac --mac-source $i -m limit --limit 10/s -j ACCEPT
   iptables -A ndsSPD -i eth0 -m mac --mac-source $i -j DROP
done

#========================================================

#block destination ip
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


#========================================================

#accept destination ip

iptables -t nat -N ndsACC
iptables -t nat -F ndsACC
iptables -t nat -D ndsOUT -j ndsACC
iptables -t nat -I ndsOUT -j ndsACC
#iptables -t nat -D ndsOUT -m conntrack --ctstate RELATED,ESTABLISHED -j ndsACC
#iptables -t nat -I ndsOUT -m conntrack --ctstate RELATED,ESTABLISHED -j ndsACC
for i in $(grep -v '^#' /root/dst_ip_accepted)
do
echo $i
   iptables -t nat -I ndsACC  -i eth0 -d $i -j ACCEPT
done
iptables -t nat -A ndsACC -j RETURN

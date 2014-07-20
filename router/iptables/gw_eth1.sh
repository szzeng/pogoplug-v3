#!/bin/sh
#mount -o remount,rw /
#date  -d  05/21/2014
#date -s '09:16:00 2004-04-14'
#./udhcpc -b -i eth1 -p /var/run/udhcpc.pid  -R -v &
#insmod asix.ko
#ifconfig eth1 up
#udhcpc -b -i eth1 -p /var/run/udhcpc.pid  -R -v &

echo "1">/proc/sys/net/ipv4/ip_forward

#modprobe ip_conntrack_ftp

iptables -F
iptables -F -t nat

#iptables -A INPUT -i eth0 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
#iptables -t nat -A POSTROUTING -o eth1 -s 192.168.2.0/24 -j MASQUERADE

#iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-port 53
#iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT

iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
iptables -A INPUT -i eth0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
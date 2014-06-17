#!/bin/sh
#mount -o remount,rw /
#date  -d  05/21/2014
#date -s '09:16:00 2004-04-14'

insmod /root/wlan.ko
hostapd /etc/rtl_hostapd_2G.conf -B

brctl addbr br0
brctl addif br0 eth0
brctl addif br0 wlan0
ifconfig eth0 0
ifconfig wlan0 0
ifconfig br0 192.168.2.2 netmask 255.255.255.0 up
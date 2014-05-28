#!/bin/sh
#mount -o remount,rw /
#date  -d  05/21/2014

rm /var/run
rm /var/lock
mkdir /var/run -p
mkdir /var/lock -p

mkdir /etc/ppp/chat
cd /etc/ppp/chat
rm wcdma-connect-chat
rm disconnect-chat
wget http://192.168.6.60/wcdma-connect-chat
wget http://192.168.6.60/disconnect-chat

mkdir /etc/ppp/peers
cd /etc/ppp/peers
rm wcdma-dailer
wget http://192.168.6.60/wcdma-dailer

ifconfig eth0 down
pppd call wcdma-dailer &
ifconfig eth0 up
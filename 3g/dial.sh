#!/bin/sh
#mount -o remount,rw /
#date  -d  05/21/2014

KEY_WORD=$1

rm /var/run/pppd2.tdb
rm /var/lock/LCK..ttyUSB0
mkdir /var/run -p
mkdir /var/lock -p

mkdir /etc/ppp/chat
cd /etc/ppp/chat

if [ "$KEY_WORD" = "t" ]
then
rm wcdma-connect-chat
rm disconnect-chat
wget http://192.168.2.100/wcdma-connect-chat
wget http://192.168.2.100/disconnect-chat
fi

mkdir /etc/ppp/peers

if [ "$KEY_WORD" = "t" ]
then
cd /etc/ppp/peers
rm wcdma-dailer
wget http://192.168.2.100/wcdma-dailer
fi

#ifconfig eth0 down
pppd call wcdma-dailer &
#ifconfig eth0 up
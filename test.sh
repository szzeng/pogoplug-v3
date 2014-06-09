#!/bin/sh
#mount -o remount,rw /
#date  -d  05/21/2014
#date -s '09:16:00 2004-04-14'

mkdir /tmp/usb
mount /dev/sda1 /tmp/usb

cd /tmp/usb/usr/lib/modules
rm -rf 2.6.31.6_SMP_820
rm ./xxx
wget http://192.168.2.100/xxx
tar jvxf ./xxx

cd /root
#!/bin/sh

if [ "$USEPEERDNS" = "1" -a -f /etc/ppp/resolv.conf ]; then
  [ -e /etc/resolv.conf ] && mv /etc/resolv.conf /etc/resolv.conf.backup.${IFNAME}
  mv /etc/ppp/resolv.conf /etc/resolv.conf
  chmod 644 /etc/resolv.conf
fi

#echo " DNS1 $DNS1"
#echo " DNS2 $DNS2"
#echo " DNS1 $IPLOCAL"
#echo " DNS2 $IPREMOTE"
echo $PPPD_PID > /etc/ppp/ppp0.pid;
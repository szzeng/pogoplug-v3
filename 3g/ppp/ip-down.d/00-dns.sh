#!/bin/sh

[ -e /etc/resolv.conf.backup.${IFNAME} ] && mv /etc/resolv.conf.backup.${IFNAME} /etc/resolv.conf
rm /etc/ppp/ppp0.pid
#!/bin/bash
##
## Script to allow routing from a OpenWRT router to an interface
## on the host machine
## Parameters: Interface to send data from the device (on eth0) to
## Example: Sending data from the router to wlan1 is
## 	'routing wlan1'
##

if [ $# -ne 1 ] ; then
	echo "Usage: routing interface"
	echo "  Where interface is the output interface on the host machine"
	echo "  Example: routing wlan1"
	exit 1
fi

iptables -A FORWARD -o eth0 -i eth0 -s 192.168.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

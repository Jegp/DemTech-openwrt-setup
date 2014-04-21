#!/bin/bash
##
## Script to allow routing from a OpenWRT router to an interface
## on the host machine
## Parameters: Interface to send data from the device (on eth0) to
## Example: Sending data from the router to wlan1 is
## 	'routing wlan1'
##

if [ $# -ne 2 ] ; then
	echo "Usage: routing interface1 interface2"
	echo "  Where the interfaces are the internet and OpenWRT connections respectively"
	echo "  Example: routing eth0 wlan1"
	echo "   -- Routes internet connection from eth0 to OpenWRT router at wlan1"
	exit 1
fi

iptables -A FORWARD -o $2 -i $1 -s 192.168.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o $2 -j MASQUERADE

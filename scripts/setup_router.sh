#!/bin/sh
##
## A script for a TP-Link TL-MR3020 device
## that sets up routes to a given host and
## sets resolv.conf
##
## Author: <jensep@gmail.com>
##

if [ $# -ne 1 ] ; then
	echo "Usage: setup_router.sh host-ip"
	echo "	Where host-ip is the ip this router should use"
	echo "	as internet host"
	exit 1
fi

## Configure public key auth
[ -f /etc/dropbear/authorized_keys ] && sed -i 's/on/off/g' /etc/config/dropbear || exit 2

## Config internet access and opkg

# Add the gateway to the host machine
route add default gw $1

# Adds googles nameserver as address resolver
printf "search lan\nnameserver 8.8.8.8\n" > /etc/resolv.conf

# Opdate package manager to prepare for the next steps
opkg update

if [ $? -ne 0 ] ; then
	echo "Failure when updating opkg"
	exit 3
fi
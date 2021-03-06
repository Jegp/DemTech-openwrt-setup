#!/bin/bash
##
## A script for setting up monitoring tools on
## a TP-Link TL-MR3020 device with a Huawei
## E353Ws-2 3G dongle
##
## Author: <jensep@gmail.com>
##

## Check number of arguments
if [ $# -lt 4 ] ; then
	echo "A script to install monitoring tools on an external router."
	echo "Must be run as root to alter ip-tables."
	echo ""
	echo "Usage: setup.sh   client-address host-address PIN-code"
	echo "                  [interface-router [interface-internet]]"
	echo "	client-address: The IP address for the router"
	echo "	host-address:	The IP address indicating where"
	echo "			to send the monitoring data"
	echo "	PIN-code:	The PIN-code of the 3G dongle"
	echo "	interface-in:	The interface on the host where the"
	echo "			router is connected. Default: eth0"
	echo "	interface-out:	The interface on the host where the host"
	echo "			is connected to the internet. Default: eth0"
	echo ""
	echo "Example: setup.sh 192.168.0.1 8.8.8.8 1234"
	echo "Example: setup.sh 192.168.0.1 0.0.0.0 1234 eth0 wlan1"
	exit 1
fi

if [[ $EUID -ne 0 ]] ; then
	echo "Must be run as root to alter ip-tables."
	exit 2
fi

## Define an error function
testError() {
	RET=$?
	if [ $RET -ne 0 ] ; then
		echo "$1 ($RET)"
		exit 3
	fi
}

## Setup routing
INTERFACE_IN=$4
INTERFACE_OUT=$5
INTERFACE_IN=${INTERFACE_IN:-eth0}
INTERFACE_OUT=${INTERFACE_OUT:-eth0}
echo "> Setting up routing from $INTERFACE_IN to $INTERFACE_OUT"
scripts/setup_routing.sh $INTERFACE_IN $INTERFACE_OUT
ping -c 2 $1 1>/dev/null

testError "Error when connecting to router on $1"

##
## Configure public key auth
##
echo "> Moving public key to router"
scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    openwrt.pub root@192.168.1.1:/etc/dropbear/authorized_keys

##
## Move the client program, capture, check_alive and setup scripts
##
echo "> Moving scripts to router"
scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    -i openwrt \
    scripts/capture.sh scripts/check_alive.sh scripts/postprocess.sh \
    scripts/startup.sh root@$1:/root/


testError "Error when copying to router."

##
## Execute the installation scripts
##

function run_script() {
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    -i openwrt \
    root@$1 'ash -s' < $2 $3
}

## Execute the router setup script on the device
echo "> Setting up router config"
run_script $1 scripts/setup_router.sh 192.168.1.2

testError "Error when running running router setup."

## Execute the 3G setup script on the device
echo "> Setting up 3G dongle"
run_script $1 scripts/setup_dongle.sh $3

testError "Error when running running 3G setup."

## Execute the monitoring setup script on the device
echo "> Setting up monitoring scripts"
run_script $1 scripts/setup_monitoring.sh $3

testError "Error when running setting up monitoring tools."

echo "Setup succesful"

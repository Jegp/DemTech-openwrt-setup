#!/bin/sh
##
## A startup script for an OpenWRT router monitoring wifi
## traffic and sending it to a remote server
##
## Author: <jensep@gmail.com>

if [ $# -ne 1 ] ; then
	echo "Usage: startup.sh host-ip"
	exit 1
fi

# Setup the 3G dongle drivers
insmod usbserial vendor=0x12d1 product=0x1001
insmod usb_wwan
insmod option

# Test that the device and its interfaces exists
ls /dev/ttyUSB0 /dev/ttyUSB1 /dev/ttyUSB2
if [ $? -ne 0 ] ; then
	echo "Error when loading driver"
	exit 2
fi

# This should initiate the ppp0 interface
# Now we sleep a while to let it activate
sleep 30

# Install tcpdump on ram (-d for destination) since it's too big
# for main memory (!)
opkg update
opkg -d ram install tcpdump

# Create data folder
mkdir /tmp/data

# Write the hostname to a file
echo $1 > /root/host

# Start capturing
/root/capture.sh
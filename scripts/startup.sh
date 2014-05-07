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
sleep 5

# Install tcpdump on ram (-d for destination) since it's too big
# for main memory (!)
opkg update
opkg -d ram install tcpdump

# Create a counter to keep track of (possible) different
# running instances across boots
if [ ! -e /root/n ] ; then
	echo "0" > /root/n
fi

# Increment the counter
N=$(($(cat /root/n) + 1))
echo $N > /root/n

# Start tcpdump with flags:
# -i      The interface
# -B 100  Buffer size of the OS to limit consumption
# -w      Binary output file
# -C      Capture size before file-rotation (in kB)
# -n      Don't resolve addresses
# -e      Include link-level headers
# -q      Quiet means reduced output (not really sure what it does)
# -s      Package size (we don't care about the actual data)
# -z      A script to post-proccess the rotated files (from the w option)
#         - sends the file over the network and deletes it
/tmp/usr/sbin/tcpdump \
    -i wlan0 -B 100 -w "/tmp/data/${N}_dump" -C 1 -neq -s 0 \
    -z /root/postprocess &

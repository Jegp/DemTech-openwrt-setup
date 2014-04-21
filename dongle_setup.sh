#!/bin/ash
##
## Initialization script for the 3G dongle on startup
##
## Author: <jensep@gmail.com>
##

# Force-load the drivers
insmod usbserial vendor=0x12d1 product=0x1001
insmod usb_wwan
insmod option

# Ask the device for the IMEI
# TODO: Not necessary?
#cat /dev/ttyUSB2 &
#IMEI=`echo -e "ATI\r" > /dev/ttyUSB2 | grep IMEI | cut -d f2`
#CODE=`python unlock.py $IMEI`
#echo -e 'AT^CARDLOCK="$CODE"\r' > /dev/ttyUSB2
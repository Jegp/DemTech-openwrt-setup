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
#echo -e 'AT^CARDLOCK="$CODE"\r' > /dev/ttyUSB2#!/bin/ash
##
## Setup script for a TP-Link TL-MR3020 device
## with a Huawei E353Ws-2 3G dongle
##
## Note: This only installs the dongle. To use
## the dongle a script still needs to be run at startup
##
## Also note: We use the unstable Barrier Breaker to
## avoid a bug where USB devices suddenly disconnects
##
## Author: <jensep@gmail.com>
##

##
## First we install the necessary packages
##

# Install USB drivers and tools
opkg install kmod-usb2 libusb chat comgt

# USB modeswitch to set the 3G device to non-flash state
opkg install usb-modeswitch

# Dongle control packages
opkg install kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan

# Initialize the right drivers on detection
#echo "usbserial vendor=0x12d1 product=0x1001" > /etc/modules.d/usb-serial

##
## Next we modify modeswitch configs, insert ppp0 interface and configure chat
##

# Setup the dongle driver with the right info about the E353 device
sed -i '68i              ,"55534243ee0000006000000000000611063000000000000100000000000000"' /etc/usb-mode.json
sed -e "1349s/29/64/" /etc/usb-mode.json > /etc/usb-mode.json

# Setup network information
sed -i '14i config interface \'ppp0\'' /etc/config/network
sed -i '15i \\\toption ifname ppp0' /etc/config/network
sed -i '16i \\\toption pincode $1' /etc/config/network
sed -i '17i \\\toption device /dev/ttyUSB0' /etc/config/network
sed -i '18i \\\toption apn internet' /etc/config/network
sed -i '19i \\\toption service umts' /etc/config/network
sed -i '20i \\\toption proto 3g' /etc/config/network
sed -i '21i \\\toption Username Fullrate' /etc/config/network
sed -i '22i \\\toption Password Fullrate' /etc/config/network

# Configure chat
sed -i 's/***1//g' /etc/chatscripts/3g.chat

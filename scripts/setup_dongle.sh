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

if [ $# -ne 1 ] ; then
    echo "Usage: setup_dongle.sh PIN-code"
    echo "       Example: setup_dongle.sh 1234"
    exit 1
fi

##
## First we install the necessary packages
##

# Install USB drivers and tools
opkg install kmod-usb2 libusb chat comgt

# USB modeswitch to set the 3G device to non-flash state
opkg install usb-modeswitch

# Dongle control packages
opkg install kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan --force-depends

##
## Next we modify modeswitch configs, insert ppp0 interface and configure chat
##

# Setup the dongle driver with the right info about the E353 device
sed -i '68i              ,"55534243ee0000006000000000000611063000000000000100000000000000"' /etc/usb-mode.json
sed -e "1349s/29/64/" /etc/usb-mode.json > /etc/usb-mode2.json
mv /etc/usb-mode2.json /etc/usb-mode.json

# Setup network information (only if not already there)
grep "ppp0" /etc/config/network 1>/dev/null
if [ $? -ne 0 ] ; then
	echo -e "\nconfig interface 'ppp0'" >> /etc/config/network
	echo -e "\toption ifname 'ppp0'" >> /etc/config/network
	echo -e "\toption pincode '$1'" >> /etc/config/network
	echo -e "\toption device '/dev/ttyUSB0'" >> /etc/config/network
	echo -e "\toption apn 'internet'" >> /etc/config/network
	echo -e "\toption service 'umts'" >> /etc/config/network
	echo -e "\toption proto '3g'" >> /etc/config/network
	echo -e "\toption Username 'Fullrate'" >> /etc/config/network
	echo -e "\toption Password 'Fullrate'" >> /etc/config/network
fi

# Configure chat
sed -i 's/***1//g' /etc/chatscripts/3g.chat

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

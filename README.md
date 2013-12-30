DemTech-openwrt-setup
=====================

Version 0.1

## Introduction

This is a repository containing instructions on how to setup the environment for a [DemTech](http://demtech.dk) project. The idea is to use devices with WiFi antennas to monitor queue lengths at polling places by registering how long the same WiFi devices are in range. This readme describes how to use the setup-scripts in the repository.

Any questions or comments can be directed to jegp@demtech.dk.

## Setup
The scripts are designed to be run on a Linux host machine via a shell, and onto a device running the [OpenWrt](https://openwrt.org/) Linux distribution for embedded devices (in this case devices with wireless antennas). Setup instructions for any router device or similar should be present on the OpenWrt website<sup>[1]</sup>. Monitoring traffic generates a lot of data, so this setup also assumes that a storage device is attached to the external device. I also assume the host and target devices are linked over ethernet (for instance over a switch to connect multiple devices).

If you succeed, this solution will start a script whenever the router boots that will log all the wireless traffic in the vicinity. No actions are required except powering on the device.

**Note:** Data will be captured on the channel the device is set to monitor. One can argue whether or not this is desirable, but all devices should be caught scanning once in a while (depending on the platform), since a scanning covers all available frequencies.

## Routing
To enable connection between the devices and the host, and between the devices and the internet, one should setup a route table on the host-machine to allow routes to and through the host. In this setup the host-machine is set to respond on 192.168.0.2. Further, the host-machine is connected to both the internet and the devices via a switch, connected to  the interface eth0.

1. First establish the host alias address
````bash
sudo ip addr add 192.168.0.1/24 dev eth0
````

2. Then configure NAT, so the devices can resolve addresses.
````bash
sudo iptables -A FORWARD -o eth0 -i eth0 -s 192.168.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -F POSTROUTING
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
````

3. Lastly the line `#net.ipv4.ip_forward=1` should be uncommented in the file `/etc/sysctl.conf`.

If the settings are not stored, this needs to be run after each boot. A great article on the ubuntu help center describes the above steps in more detail and some information on how to persist the changes: https://help.ubuntu.com/community/Internet/ConnectionSharing.

## Running the scripts
A device with a clean OpenWrt installation should resolve itself to 192.168.0.1, which is the address used in the scripts. The scripts will need to run in two steps: One to update and install the external storage device (USB in this case) and one to 1) install tcpdump on the external storage (on the devices I used, tcpdump did not fit on the native storage) and 2) to copy the monitoring scripts onto the device. These scripts will be run when the device starts.

[To be continued...]


[1]: https://openwrt.org/ "OpenWrt homepage"

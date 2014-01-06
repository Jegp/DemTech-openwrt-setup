DemTech-openwrt-setup
=====================

Version 0.1

## Introduction

This is a repository containing instructions on how to setup the environment for a [DemTech](http://demtech.dk) project. The idea is to use devices with WiFi antennas to monitor queue lengths at polling places by registering how long the same WiFi devices are in range. This readme describes how to use the setup-scripts in the repository.

Any questions or comments can be directed to jegp@demtech.dk.

## Setup
The scripts are designed to be run on a Linux host machine via a shell, and onto a device running the [OpenWrt](https://openwrt.org/) Linux distribution for embedded devices (in this case devices with wireless antennas). Setup instructions for any router device or similar should be present on the OpenWrt website<sup>[1]</sup>. Monitoring traffic generates a lot of data, so this setup also assumes that a storage device is attached to the external device. Lastly the host and target devices should be linked over ethernet (e. g. using a switch to connect multiple devices).

If you succeed, this solution will start a script whenever the router boots that will log all the wireless traffic in the vicinity on a the default channel. The goal is to make it as simple as possible: no actions are required except powering on the device.

**Note:** Data will be captured on the channel the device is set to monitor. One can argue whether or not this is desirable, but all devices should be caught scanning once in a while (depending on the platform), since a scanning covers all available frequencies.

## Routing
To enable connection between the devices and the host, and between the devices and the internet (we need this to install packages on the device), one should setup a route table on the host-machine to allow routes to and through the host. In this setup the host-machine is set to respond on 192.168.0.2. Further, the host-machine is connected to both the internet and the devices via a switch, connected to  the interface eth0.

1. First establish the host address alias
````bash
sudo ip addr add 192.168.0.2/24 dev eth0
````

3. Then configure NAT, so the devices can resolve addresses.
````bash
sudo iptables -A FORWARD -o eth0 -i eth0 -s 192.168.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -F POSTROUTING
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
````

4. Lastly the line `#net.ipv4.ip_forward=1` should be uncommented in the file `/etc/sysctl.conf`.

If the settings are not stored, this needs to be run after each boot. A great article on the ubuntu help center describes the above steps in more detail and some information on how to persist the changes: https://help.ubuntu.com/community/Internet/ConnectionSharing.

A device with a clean OpenWrt installation should resolve itself to 192.168.0.1, which is the address used in the scripts. 

## Device configuration
To be able to connect to the device via the shell and ethernet you need to configure the OpenWrt configuration. This can be automated, but it is simple to just log in to the interface, by pointing a browser to 192.168.0.1. When logging in the first time, no password should be needed.

First you should set the password of the device, so it can be accessed via ssh. This can be done in the systems-tab under administration.

If you have multiple devices you would probably want to give the ethernet interface another address. As you can see below I have chosen 192.168.0.101 as an example here. But anything goes.

Lastly it is probably a good idea to synchronize the time. Note that when you change the interface above, the device is no longer available via 192.168.0.1.

## Installation 
After configuring the device the last thing to do is to install the monitoring scripts. Assuming you are in the root directory of this repository, simply run the ``setup.sh`` script with the ip of the external device as the single argument, to setup the router for WiFi monitoring. And that's it. So if you have your router at 192.168.0.101:

````bash
./setup.sh 192.168.0.101
````

If something breaks I have included a more elaborate description of the setup which runs in two steps. 

1. First we need to run the installation-script (``router-setup.sh``) on the device.
The ````UserKnownHostsFile```` and the ````StrictHostKeyChecking```` options avoids checking and storing the RSA key since we are going to connect to multiple devices with the same IP. 
The ``router-setup.sh`` script updates the package manager, installs the external storage device (USB in this case) and the monitoring program (tcpdump) on the USB (tcpdump did not fit on the native storage in my setup) and lastly sets up startup-hooks and cron-jobs for the monitoring process.

2. Lastly the monitoring scripts will be copied onto the device. These scripts will be run when the device starts.

## Conclusion
This is an exceptionally powerful tool since even the smallest and simplest devices with wifi-antennas are capable of surveilling a large number of people over a large amount of time. The information captures by tcpdump can be used for many many purposes, ranging from tracking individuals to perhaps even triangulate positions if more routers are set up. 

The setup are not perfect, however. Tcpdump only captures traffic on the default channel of the antenna, which limits a lot of the logged data to scans from mobile devices searching for networks. 

Also, I have been struggling with the wireless interface crashing irregularly. In particular this appeared to be a problem when using the FAT filesystem on the USB devices to store the WiFi data on.
In the setup-scripts I have included a cron-job that checks if any data have been logged for a minute. If not, we restart the wireless interface.

[1]: https://openwrt.org/ "OpenWrt homepage"

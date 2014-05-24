#!/bin/sh
##
## Post-processes data in the file given by the first parameter
## 1: Send the file to the remote host
## 2: Delete the file
##
## Author: <jensep@gmail.com>
if [ $# -ne 1 ] ; then
    echo "Usage: postproccess file"
    exit 1
fi

# Constants
HOST=`cat /root/host`
N=`cat /root/n`
IP=`cat /etc/config/network | grep 192 | cut -d "'" -f2`
TMP="$IP-$(basename $1)"

if [[ -z $HOST ]] ; then
    echo "Cannot find host from /root/host"
    exit 2
fi

echo "Sending file $1 to $HOST"

# Compress the file
/tmp/usr/sbin/tcpdump -neql -r $1 > "/tmp/$TMP"

# Send the file to the host
scp -i /root/sshkey "/tmp/$TMP" carsten@$HOST:~/data/$TMP

#
if [ $? -ne 0 ] ; then
    echo "Warning: Failed to send data to $HOST. Error: $?" >> /tmp/log_postprocess
fi

rm $1
rm "/tmp/$TMP"

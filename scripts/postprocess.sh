#!/bin/sh

# Post-processes data in the file given by the first parameter
# 1: Send the file to the remote host
# 2: Delete the file

if [ $# -ne 2 ] ; then
    echo "Usage: postproccess file hostname"
    exit 1
fi

echo "Sending file $1 to $2"

/tmp/usr/sbin/tcpdump -neql -r $1 > "/tmp/$1_tmp"
scp -i /root/sshkey $1 $2:~/data/$1

if [ $? -ne 0 ] ; then
    echo "Warning: Failed to send data to $2. Error: $?" >> /tmp/log
fi

rm $1

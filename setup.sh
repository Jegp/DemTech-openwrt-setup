## Execute the router setup script on the device
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    'ash -s' < router_setup.sh

## Move the capture and check_alive scripts to the device
scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    capture check_alive root@192.168.0.$1:/home


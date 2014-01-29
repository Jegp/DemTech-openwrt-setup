## Check number of arguments
if [ $# -ne 1 ] ; then
    echo "Usage: setup client-address"
    exit 1
fi

testError() {
    if [ $? -ne 0 ] ; then
        echo $1
        exit 1
    fi
}

## Move the client program, capture and check_alive scripts to the device
scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    client.ipk capture check_alive postprocess root@$1:/home

testError "Error when copying to router."

## Execute the router setup script on the device
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
    root@$1 'ash -s' < router_setup.sh

testError "Error when running running router setup."

echo "Setup succesful"

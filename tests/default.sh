#!/bin/sh
echo "
         ######################################
         ###          Default test           ##
         ######################################
"


# Make sure tests fails if a commend ends without 0
set -e

# Generate some random ports for testing
PORT=$(cat /dev/urandom|od -N2 -An -i|awk -v f=10000 -v r=19999 '{printf "%i\n", f + r * $1 / 65536}')


# Make sure the ports are not already in use. In case they are rerun the script to get new ports.
[ $(netstat -an | grep LISTEN | grep :$PORT | wc -l) -eq 0 ] || { ./$0 && exit 0 || exit 1; }

# Run container in a simple way
DOCKERCONTAINER=$(docker run -d --network testing -e NGX_ADDRESS=sample -p 127.0.0.1:${PORT}:80 nginx-pagespeed:testing)

wget -O- http://127.0.0.1:${PORT}/

# Make sure the container is not restarting
sleep 20
docker ps -f id=${DOCKERCONTAINER}
sleep 20
docker ps -f id=${DOCKERCONTAINER}

# Clean up
docker stop ${DOCKERCONTAINER} && docker rm ${DOCKERCONTAINER}

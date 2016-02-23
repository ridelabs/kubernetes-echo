#!/bin/bash
#dname=$1
#if [ "${dname}XX" == "XX" ]; then
    #read -p "What is your docker username? " dname
#fi
dname=$(docker info 2>/dev/null | grep Username | awk '{print $2}')
docker tag -f echoserver:latest $dname/echoserver:latest
docker push $dname/echoserver:latest



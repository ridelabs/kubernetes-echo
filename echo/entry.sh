#!/bin/bash
# wait for a connection, then tell them who we are 
while : ; do 
    echo "hello, the date=`date`; my host=`hostname`" | nc -l 8080 
    sleep .5
done


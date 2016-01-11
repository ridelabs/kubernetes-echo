#!/bin/bash
docker tag -f echoserver:latest 127.0.0.1:5000/echoserver:latest
docker push 127.0.0.1:5000/echoserver:latest



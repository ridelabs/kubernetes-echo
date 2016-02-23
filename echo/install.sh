#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
pushd $DIR

kubectl delete rc -lapp=echo
kubectl delete svc -lapp=echo

dname=$(docker info 2>/dev/null | grep Username | awk '{print $2}')

cat << EOF > _echo.service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: echo
    role: echo-server
    name: echo-server-1
  name: echo-server-1
spec:
  selector:
    entity: echo-server-1
    role: echo-server
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
EOF

cat <<EOF > _echo.controller.yaml
apiVersion: v1
kind: ReplicationController
metadata:
  labels:
    role: echo-server
    app: echo
  name: echo-server-1
spec:
  replicas: 3
  template:
    metadata:
      labels:
        entity: echo-server-1
        role: echo-server
        app: echo
    spec:
      containers:
      - 
        image: $dname/echoserver:latest
        name: echo-server-1

        ports:
          - containerPort: 8080

EOF

kubectl create -f _echo.controller.yaml
kubectl create -f _echo.service.yaml

rm -f _echo.controller.yaml _echo.service.yaml


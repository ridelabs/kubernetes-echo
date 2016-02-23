# kubernetes-echo

#### This demonstrates a simple k8s service and there is a bug that we are encountering.  See http://stackoverflow.com/questions/34732597/kubernetes-pod-cant-connect-through-service-to-self-only-to-other-pod-contai

##### To see this bug in action, do the following.

1. create your kubernetes network (run ./setup.sh)
2. export your KUBECONFIG and SSH_CONFIG variables as instructed by the setup.sh output
3. log in to your docker accout (you'll need this to upload the echo server image): docker login
   * I guess that I could just have you use my version, but this allows you to easily play with the image code if you want to experiment with something
4. cd into echo
5. build the image: ./build.sh
6. upload the image: ./upload.sh
7. install the service and rc: ./install.sh
8. get the service ip (you'll need this in step 10)
   * kubectl get svc | grep echo-server-1
9. get a list of your pods via: kubectl get po
10 connect to the service via nc in one of the pods...  Notice that you will hang periodically.  That is when it is trying to round-robin to the pod from which you are launching nc.


#### Get the running pods
```bash
(MY_ENV)[eric@pluto [master]echo]$ kubectl get po
NAME                  READY     STATUS    RESTARTS   AGE
echo-server-1-051hk   1/1       Running   0          36s
echo-server-1-ubz3d   1/1       Running   0          36s
echo-server-1-x2kq2   1/1       Running   0          36s
```

#### What is the service IP?
```bash
(MY_ENV)[eric@pluto [master]echo]$ kubectl get svc | grep echo-ser
echo-server-1   10.3.0.43    nodes         8080/TCP   entity=echo-server-1,role=echo-server   28s
```

#### Try to connect to the service from one of the pods
```bash
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-051hk nc 10.3.0.43 8080
^Cerror: error executing remote command: Error executing command in container: Error executing in Docker Container: 130
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-051hk nc 10.3.0.43 8080
hello network visitor, the date=Tue Feb 23 21:53:04 UTC 2016; my host=echo-server-1-ubz3d
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-051hk nc 10.3.0.43 8080
hello network visitor, the date=Tue Feb 23 21:53:11 UTC 2016; my host=echo-server-1-x2kq2
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-051hk nc 10.3.0.43 8080
hello network visitor, the date=Tue Feb 23 21:57:18 UTC 2016; my host=echo-server-1-ubz3d
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-051hk nc 10.3.0.43 8080
^Cerror: error executing remote command: Error executing command in container: Error executing in Docker Container: 130

```

#### Now launch from a different pod and you get all but that one...
```bash
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-ubz3d nc 10.3.0.43 8080
hello network visitor, the date=Tue Feb 23 21:51:39 UTC 2016; my host=echo-server-1-051hk
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-ubz3d nc 10.3.0.43 8080
hello network visitor, the date=Tue Feb 23 21:57:19 UTC 2016; my host=echo-server-1-x2kq2
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-ubz3d nc 10.3.0.43 8080
hello network visitor, the date=Tue Feb 23 21:58:51 UTC 2016; my host=echo-server-1-051hk
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-ubz3d nc 10.3.0.43 8080

^Cerror: error executing remote command: Error executing command in container: Error executing in Docker Container: 130
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-ubz3d nc 10.3.0.43 8080
^Cerror: error executing remote command: Error executing command in container: Error executing in Docker Container: 130
(MY_ENV)[eric@pluto [master]echo]$ kubectl exec -it echo-server-1-ubz3d nc 10.3.0.43 8080
hello network visitor, the date=Tue Feb 23 21:58:53 UTC 2016; my host=echo-server-1-x2kq2
```



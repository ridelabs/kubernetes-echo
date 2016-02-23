# kubernetes-echo

This demonstrates a simple k8s service and there is a bug that we are encountering.  See http://stackoverflow.com/questions/34732597/kubernetes-pod-cant-connect-through-service-to-self-only-to-other-pod-contai

To use this, do the following.

1. create your kubernetes network (run ./setup.sh)
2. export your KUBECONFIG, SSH_CONFIG, K8NODE variables as instructed by the setup.sh output
3. log in to your docker accout (you'll need this to upload the echo server image): docker login
4. cd into echo
5. build the image: ./build.sh
6. upload the image: ./upload.sh
7. install the service and rc: ./install.sh
8. get the service ip (you'll need this in step 10)
   * kubectl get svc | grep echo-server-1
9. ssh to a pod
   * get a list of your pods via: kubectl get po
   * ssh into one of them with: kubectl exec -it {podname} /bin/bash
10. connect to the service repeatedly until you hang
   * nc {service_ip} 8080



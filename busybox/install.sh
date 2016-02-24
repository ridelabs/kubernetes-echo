#!/bin/bash
__BB_CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
. $__BB_CURRENT_DIR/../../bootstrap/functions

KUBE=kubectl
pushd $__BB_CURRENT_DIR

echo "Purging your busybox based k8s objects..."
$KUBE delete po busybox
# wait for pods to die...
while : ; do 
    if [[ $($KUBE get po | grep busybox) ]] ; then 
        echo "Waiting for pods to die..."
        sleep 1
    else 
        echo "Pods dead"
        break
    fi
done

$KUBE create -f $__BB_CURRENT_DIR/busybox-pod.yaml

popd


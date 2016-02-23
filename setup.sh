#!/bin/bash

COREOS_KUBE_REPO=https://github.com/coreos/coreos-kubernetes.git
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
COREOS_CHANNEL="beta"
COREOS_VERSION_EXPRESSION=">=899.5.0"
WORKDIR=$MYDIR/tmp_launch_data
mkdir -p $WORKDIR
SSH_CONFIG=$WORKDIR/ssh.config
SLEEP_TIME=10
KUBECONFIG="$WORKDIR/coreos-kubernetes/single-node/kubeconfig"

wait_for_all_pods() {
    while : ; do 
        ORIGIFS=$IFS
        IFS=$'\n'
        local lines=($(kubectl get po --all-namespaces 2>/dev/null | grep -v STAT | awk '{print $1,$2,$4}'))
        echo "----------------------------------"
        problem=false
        for i in "${lines[@]}"; do
            namespace=`echo $i | awk '{print $1}'`
            image=`echo $i | awk '{print $2}'`
            state=`echo $i | awk '{print $3}'`
            case $state in
                "Running")
                    #echo "$image is ready"
                    echo -ne "."
                    ;;
                "Terminating")
                    echo "$image is getting killed `date`"
                    ;;
                "Pending")
                    echo "$image is not ready yet `date`"
                    problem=true
                    ;;
                "PullImageError")
                    echo "$image had a pull error, re-do pull `date`"
                    kubectl delete po --namespace=$namespace $image
                    problem=true
                    ;;
                *)
                    echo "$image is in a strange state $state `date`"
                    ;;
            esac
            IFS=$ORIGIFS
        done
        if [ $problem == false ]; then
            break
        fi
        sleep $SLEEP_TIME
    done
}

wait_for_node() {
    while ! kubectl get nodes 2>/dev/null| grep 'Ready' >/dev/null 2>&1 ; do 
        echo "Waiting for kubernetes node to stabilize... `date`"
        sleep $SLEEP_TIME
    done
}

wait_for_ssh_config() {
    while ! vagrant ssh-config ; do 
        echo "Waiting for image to start... `date`"
        sleep $SLEEP_TIME
    done
    sleep $SLEEP_TIME
    vagrant ssh-config > $SSH_CONFIG 
}

edit_files() {
    perl -pi -e "s/vm.box = \"coreos-[^\"]*\"/vm.box = \"coreos-${COREOS_CHANNEL}\"/" Vagrantfile
    perl -pi -e "s/vm.box_version = \"[^\"]*\"/vm.box_version = \"${COREOS_VERSION_EXPRESSION}\"/" Vagrantfile
    perl -pi -e "s#vm.box_url = \"http://alpha\.#vm.box_url = \"http://${COREOS_CHANNEL}.#" Vagrantfile
}

# -----------------------------------------------
#
# Main Stuff
#
# -----------------------------------------------
pushd $WORKDIR

test -d coreos-kubernetes || git clone $COREOS_KUBE_REPO
pushd coreos-kubernetes/single-node

# delete the old vagrant instance (if there is one)
vagrant destroy -f && echo "Blew away the old instance"

# fix anything from our last edit
git checkout  -- Vagrantfile
git checkout  -- user-data

# make sure we are up to date
git pull

# make some edits to fix coreos version stuff
edit_files

#vagrant box update
vagrant up

wait_for_ssh_config
kubectl config use-context vagrant-single

wait_for_node
wait_for_all_pods

K8NODE=$(kubectl get nodes | grep -v NAME | awk '{print $1}')

echo ""
echo "############################################"
echo ""
echo ""
echo "Please run the following in shells that you want to connect to your k8s net"
echo ""
echo "export KUBECONFIG=\"$KUBECONFIG\""
echo "export SSH_CONFIG=\"$SSH_CONFIG\""
echo "export K8NODE=\"$K8NODE\""
echo ""
echo "Note: to ssh into the node, run: ssh -F \$SSH_CONFIG default"
echo ""
echo "############################################"

popd >/dev/null 2>&1
popd >/dev/null 2>&1



MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
WORKDIR=$MYDIR/tmp_launch_data

pushd $WORKDIR/coreos-kubernetes/single-node && vagrant destroy -f && echo "Blew away the old instance"


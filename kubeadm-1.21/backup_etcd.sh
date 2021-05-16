source ${0%/*}/env-variables

if [ ! -x /usr/bin/etcdctl ]
then 
    sudo apt update
    sudo apt install -y etcd-client
fi

if [ ! -d ~/etcd_backups ]
then
  mkdir ~/etcd_backups
fi

sudo ETCDCTL_API=3 \
etcdctl --endpoints="${HOST1_ID}:2379,${HOST2_ID}:2379,${HOST3_ID}:2379" \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
snapshot save ~/etcd_backups/snapshot_$(date -Iseconds).db

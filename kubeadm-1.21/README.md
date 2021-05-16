# Bootstrapping Kubernetes to Ubuntu 20.04

## 1. Fetch bootstrap files to all your hosts to speed up things.

> curl -s https://raw.githubusercontent.com/i6o/kubernetes-templates/main/kubeadm-1.21/setup.sh | bash

Files will be downloaded to `~/k8s-bootstrap`

## 2. Edit env-variables and hosts files

Edit the `env-variables` and `hosts` files to your need.
Make sure no IP addresses are overlapping when defining POD CIDR and loadbalancer Virtual IP (VIP). Also make sure that all the host IP addresses are correct.

## 3. Setup loadbalancers

You need to setup atleast one loadbalancer (*MASTER*). Optionally add one extra (*BACKUP*).
The loadbalancer server will run both the `HA-proxy` and `keepalived`.

To setup MASTER loadbalancer:
> ./setup_lb.sh -r MASTER

For additional BACKUP loadbalancers:
> ./setup_lb.sh -r BACKUP

## 4. Boostrap kubeadm on **ALL** Kubernetes master (control-plane) and worker nodes

> ./bootstrap_ubuntu_kubeadm.sh

## 5. Boostrap one master

> ./boostrap_master.sh

`After successfully setting up the master, copy the stdout of the kubeadm instructions for adding additional nodes to some where safe. We need the tokens and certificate later on in step 7.`

## 6. Check that master is working

Fetch the kubeconfig
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

And wait that the master gets *READY* state
> watch -c kubectl get nodes

## 7. Join other masters or workers

Follow the instructions of the master one to bootstrap additional master (at least 2 more) and worker (at least 3 more) nodes.

... and you are DONE!


# BACKUP ETCD DATABASE

To take a backup of your existing etcd database and its content, run this script on any of your master nodes:

> ./backup_etcd.sh

It wise to do a `crontab` job of this to regurarly make backups of etcd. Also remember to store the backups to some external location, and not to keep them at kubernetes master nodes as if you loose the node totally, you don't have the etcd backups neither.
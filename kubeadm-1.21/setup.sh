#!/bin/bash

sudo apt update
sudo apt -y install wget

mkdir ~/k8s-bootstrap
pushd ~/k8s-bootstrap

wget https://raw.githubusercontent.com/i6o/kubernetes-templates/main/kubeadm-1.21/bootstrap_ubuntu_kubeadm.sh
chmod a+x ./bootstrap_ubuntu_kubeadm.sh

wget https://raw.githubusercontent.com/i6o/kubernetes-templates/main/kubeadm-1.21/bootstrap_master.sh
chmod a+x ./bootstrap_master.sh

wget https://raw.githubusercontent.com/i6o/kubernetes-templates/main/kubeadm-1.21/setup_lb.sh
chmod a+x ./setup_lb.sh

wget https://raw.githubusercontent.com/i6o/kubernetes-templates/main/kubeadm-1.21/backup_etcd.sh
chmod a+x ./backup_etcd.sh

wget https://raw.githubusercontent.com/i6o/kubernetes-templates/main/kubeadm-1.21/hosts
wget https://raw.githubusercontent.com/i6o/kubernetes-templates/main/kubeadm-1.21/env-variables

popd

echo All files at ~/k8s-bootstrap. Edit hosts and env-variables files atleast ! ! !

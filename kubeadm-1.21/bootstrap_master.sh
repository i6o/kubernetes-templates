#!/bin/bash
source ./env-variables

sudo systemctl enable kubelet

sudo kubeadm init --pod-network-cidr=${POD_NETWORK_CIDR} --control-plane-endpoint "${APISERVER_NAME}:${APISERVER_DEST_PORT}" --upload-certs

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install CNI - Flannel - change this to CNI of your choice.
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
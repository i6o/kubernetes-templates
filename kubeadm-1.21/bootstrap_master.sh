#!/bin/bash
source ./env-variables

sudo systemctl enable kubelet

sudo kubeadm config images pull

sudo kubeadm init --pod-network-cidr=${POD_NETWORK_CIDR} --control-plane-endpoint "${APISERVER_NAME}:${APISERVER_DEST_PORT}" --upload-certs

# Install CNI - Flannel - change this to CNI of your choice.
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
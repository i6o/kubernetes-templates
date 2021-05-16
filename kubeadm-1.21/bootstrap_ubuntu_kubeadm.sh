#!/bin/bash
echo Update apt packages
sudo apt update
sudo apt -y upgrade
sudo apt update

echo Add Kubernetes repositories
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo Install kubelet, kubeadm and kubectl
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo Disable swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

echo Setup bridge-networking
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

echo Configure persistent loading of modules
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

echo Load at runtime
sudo modprobe overlay
sudo modprobe br_netfilter

echo Ensure sysctl params are set
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

echo Reload configs
sudo sysctl --system

echo Install required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates


echo Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo Install containerd
sudo apt update
sudo apt install -y containerd.io

echo Configure containerd and start service
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i '/^\([[:space:]].*\)\[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options\]/ a\            SystemdCgroup = true' /etc/containerd/config.toml

echo restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

sudo kubeadm config images pull

# Append custom k8s hosts to /etc/hosts
grep -qFf ./hosts /etc/hosts
if [ $? -eq 1 ]
then
   cat ./hosts | sudo tee -a /etc/hosts > /dev/null
fi
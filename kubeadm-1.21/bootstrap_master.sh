export API_LB_NAME=k8s-api

sudo systemctl enable kubelet

sudo kubeadm config images pull

sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --control-plane-endpoint "${API_LB_NAME}:6443" --upload-certs

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
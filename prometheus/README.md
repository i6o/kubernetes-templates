# INSTALLING PROMETHEUS MONITORING

## 1. Install Helm 3
> https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

## 2. Add prometheus repositories
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

## 3. Install Prometheus
> helm install <name> prometheus-community/kube-prometheus-stack

For more (https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

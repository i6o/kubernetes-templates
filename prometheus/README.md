# INSTALLING PROMETHEUS MONITORING

## 1. Install Helm 3
> https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

## 2. Add prometheus repositories
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

## 3. Install Prometheus
```
kubectl create namespace monitoring

helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

Alternatively, if you would like to customize the installation configuration, take out the charts values and edit to your liking and override the default values with your configuration.

> helm show values prometheus-community/kube-prometheus-stack > override.yaml

Edit the override.yaml to meet your needs and use the file in install process.

> helm install *[release name]* prometheus-community/kube-prometheus-stack -n monitoring -f ./override.yml

## 4. Uninstalling Prometheus

If you need to remove the previous installation, you can run:
> helm uninstall *[release name]*

To get a list of installed helm chart releases:
> helm list

## 5. More information

For more information visit [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).

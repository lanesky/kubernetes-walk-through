# Deploying the Prometheus and Grafana

## Create the monitoring namespace

Run below command to create a namespace for monitoring.

```
kubectl create ns monitoring
```

## Install the prometheus and grafana

[Prometheus-operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator) is a combination of prometheus, operator, grafana with many useful metrics preset.


```
helm install  --name prom-operator --namespace monitoring  stable/prometheus-operator
```

Run below command for the list of all pods in the monitoring namespace.

```
kubectl -n monitoring get pods
```

The output should be like below.

```
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prom-operator-prometheus-o-alertmanager-0   2/2     Running   0          15h
prom-operator-grafana-7cd5486b75-wpqrs                   2/2     Running   0          15h
prom-operator-kube-state-metrics-55bf4b6d77-qs6fs        1/1     Running   0          15h
prom-operator-prometheus-node-exporter-7hq6w             1/1     Running   0          15h
prom-operator-prometheus-node-exporter-fnnv7             1/1     Running   0          15h
prom-operator-prometheus-node-exporter-lkz8z             1/1     Running   0          15h
prom-operator-prometheus-node-exporter-v5dr2             1/1     Running   0          15h
prom-operator-prometheus-o-operator-6f4cdc8d67-l2vjk     2/2     Running   0          15h
prometheus-prom-operator-prometheus-o-prometheus-0       3/3     Running   1          15h
```


## Verify the Prometheus

Run below command to port forward the prometheus to local.

```
kubectl -n monitoring port-forward prometheus-prom-operator-prometheus-o-prometheus-0 9090
```

Open the web with browser.

```
http://localhost:9090
```

## Verify the Grafana

Run below command to port forward the grafana to local.

```
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 3000
```

Open the web with browser.

```
http://localhost:3000
```


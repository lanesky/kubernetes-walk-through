
#!/bin/bash
gcloud compute ssh controller-0 -- sudo cat /etc/kubernetes/admin.conf > $HOME/.kube/config

#######################
#init helm
kubectl apply -f tiller-rbac.yaml 
helm init --service-account tiller --history-max 200  

#######################

# release guestbook with helm
kubectl create ns development
helm install --name guestbook --namespace development ./guestbook


#######################

#create monitoring namespace
kubectl create ns monitoring
helm install  --name prom-operator --namespace monitoring  stable/prometheus-operator
kubectl -n monitoring port-forward prometheus-prom-operator-prometheus-o-prometheus-0 9090


#######################

# install prometheus
helm install --name prometheus  --namespace monitoring -f prometheus-values.yaml stable/prometheus

# install grafana
helm install --name grafana --namespace monitoring stable/grafana


helm inspect values stable/prometheus-operator > prom-values.yaml


helm delete prom --purge
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com

#######################

# install ELK
kubectl create ns kube-logging
kubectl apply -f efk/

export POD_NAME=$(kubectl get pods --namespace kube-logging -l "app=kibana" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace kube-logging port-forward $POD_NAME 5601

#######################





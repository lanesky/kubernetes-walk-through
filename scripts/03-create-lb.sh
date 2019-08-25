#!/bin/bash


KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe mstakx-test \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

gcloud compute http-health-checks create kubernetes \
  --description "Kubernetes Health Check" \
  --host "kubernetes.default.svc.cluster.local" \
  --request-path "/healthz"

gcloud compute firewall-rules create mstakx-test-allow-health-check \
  --network mstakx-test \
  --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
  --allow tcp

gcloud compute target-pools create kubernetes-target-pool \
  --http-health-check kubernetes

gcloud compute target-pools add-instances kubernetes-target-pool \
 --instances controller-0

gcloud compute forwarding-rules create kubernetes-forwarding-rule \
  --address ${KUBERNETES_PUBLIC_ADDRESS} \
  --ports 6443 \
  --region $(gcloud config get-value compute/region) \
  --target-pool kubernetes-target-pool

cat > kubeadm-config.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "${KUBERNETES_PUBLIC_ADDRESS}"
networking:
  podSubnet: 10.244.0.0/16
EOF
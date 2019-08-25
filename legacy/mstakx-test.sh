#!/bin/sh

#https://medium.com/@bambash/ha-kubernetes-cluster-via-kubeadm-b2133360b198
#https://github.com/lonefreak/k8s-the-hard-way-scripts
#https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
#kubeadm init --pod-network-cidr=192.168.0.0/16
###########################################
# provision the computer resource

gcloud config set compute/region asia-northeast1

# Create a custom VPC network:
gcloud compute networks create mstakx-test --subnet-mode custom

# Create subnet
gcloud compute networks subnets create kubernetes \
  --network mstakx-test \
  --range 10.240.0.0/24

# Create firewall allow internal communications
 gcloud compute firewall-rules create mstakx-test-allow-internal \
  --allow tcp,udp,icmp \
  --network mstakx-test \
  --source-ranges 0.0.0.0/0

# Create firewall allow external communications
gcloud compute firewall-rules create mstakx-test-allow-external \
--allow tcp:22,tcp:6443,icmp \
--network mstakx-test \
--source-ranges 0.0.0.0/0

# List the firewall rules
gcloud compute firewall-rules list --filter="network:mstakx-test"


# allocate a static address
gcloud compute addresses create mstakx-test \
--region $(gcloud config get-value compute/region)

# show the static address list
gcloud compute addresses list --filter="name=('mstakx-test')"


# provision the master nodes
for i in 0 1 2; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --private-network-ip 10.240.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags mstakx-test,controller \
    --zone asia-northeast1-a
done

# provision the worker nodes
for i in 0 1 2; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --metadata pod-cidr=10.200.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags mstakx-test,worker \
    --zone asia-northeast1-a
done

# show instances list
gcloud compute instances list

###########################################
# install docker,kubectl, kubeadm, kubelet to all nodes

# Change to root:
sudo su
# Install https support:
apt-get update && apt-get install -y apt-transport-https
sleep 3
# Get kubernetes repo key:
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

sleep 3

# Add kubernetes repo to manifest:
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
# Install kubeadm and docker:
apt-get update && apt-get install -y kubelet kubeadm kubectl docker.io

###########################################
# provision a load balancer

{
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
   --instances controller-0,controller-1,controller-2

  gcloud compute forwarding-rules create kubernetes-forwarding-rule \
    --address ${KUBERNETES_PUBLIC_ADDRESS} \
    --ports 6443 \
    --region $(gcloud config get-value compute/region) \
    --target-pool kubernetes-target-pool
}

###########################################
# install k8s with kubeadm



###########################################
# expose with a front network load balancer


#######
#cleanup

{
  gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule \
    --region $(gcloud config get-value compute/region)

  gcloud -q compute target-pools delete kubernetes-target-pool

  gcloud -q compute http-health-checks delete kubernetes

  gcloud -q compute addresses delete mstakx-test
}

gcloud -q compute firewall-rules delete \
  mstakx-test-allow-nginx-service \
  mstakx-test-allow-internal \
  mstakx-test-allow-external \
  mstakx-test-allow-health-check

{
  gcloud -q compute routes delete \
    kubernetes-route-10-200-0-0-24 \
    kubernetes-route-10-200-1-0-24 \
    kubernetes-route-10-200-2-0-24

  gcloud -q compute networks subnets delete kubernetes

  gcloud -q compute networks delete mstakx-test
}



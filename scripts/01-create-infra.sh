#!/bin/bash

gcloud compute networks create mstakx-test --subnet-mode custom

gcloud compute networks subnets create kubernetes \
  --network mstakx-test \
  --range 10.240.0.0/24

gcloud compute firewall-rules create mstakx-test-allow-internal \
  --allow tcp,udp,icmp \
  --network mstakx-test \
  --source-ranges 10.240.0.0/24,10.244.0.0/16

gcloud compute firewall-rules create mstakx-test-allow-external \
  --allow tcp:22,tcp:6443,icmp \
  --network mstakx-test \
  --source-ranges 0.0.0.0/0

gcloud compute firewall-rules list --filter "network: mstakx-test"

gcloud compute addresses create mstakx-test \
  --region $(gcloud config get-value compute/region)

gcloud compute addresses list --filter="name=('mstakx-test')"

for i in 0 1 ; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-2 \
    --private-network-ip 10.240.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags mstakx-test,controller

 
done



for i in 0 1 ; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-2 \
    --metadata pod-cidr=10.244.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags mstakx-test,worker


done

gcloud compute instances list


for i in 0 1 ; do
  gcloud compute routes create kubernetes-route-10-244-${i}-0-24 \
    --network mstakx-test \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.244.${i}.0/24
done
gcloud compute routes list --filter "network: mstakx-test"
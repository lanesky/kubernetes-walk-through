#!/bin/bash

gcloud -q compute instances delete \
  controller-0 controller-1 \
  worker-0 worker-1 

gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule \
  --region $(gcloud config get-value compute/region)

gcloud -q compute target-pools delete kubernetes-target-pool

gcloud compute http-health-checks delete kubernetes

gcloud -q compute addresses delete mstakx-test

gcloud -q compute firewall-rules delete \
  mstakx-test-allow-nginx-service \
  mstakx-test-allow-internal \
  mstakx-test-allow-external \
  mstakx-test-allow-health-checks \
  kubernetes-forwarding-rule

gcloud -q compute routes delete \
  kubernetes-route-10-244-0-0-24 \
  kubernetes-route-10-244-1-0-24 \
  kubernetes-route-10-244-2-0-24



gcloud -q compute networks subnets delete kubernetes

gcloud -q compute networks delete mstakx-test

#!/bin/bash

gcloud compute scp kubeadm-init.sh controller-0:~/
gcloud compute scp kubeadm-config.yaml controller-0:~/
gcloud compute ssh controller-0 -- sh ./kubeadm-init.sh
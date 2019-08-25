#!/bin/bash

for instance in  controller-0 controller-1 worker-0 worker-1 ; do
    gcloud compute scp install-one-node.sh ${instance}:~/
    gcloud compute ssh ${instance} -- sh ./install-one-node.sh
done


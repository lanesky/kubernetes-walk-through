#!/bin/bash

gcloud compute target-pools add-instances kubernetes-target-pool \
 --instances controller-1


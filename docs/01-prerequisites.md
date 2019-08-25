# Prerequisites

The following tools are required to finish the task.

## GCloud CLI  

This tool will be used to interact with GCP, follow the [instruction](https://cloud.google.com/sdk/install) for installation.

Also please set the default region/zone in the configuration. The default setting will be applied when running the script for provision GCP resources. Please refer to the example as follows.

```
gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-a
```

## Helm

We are going to use this tool to install monitoring and logging components. Check the [installation guide](https://helm.sh/docs/using_helm/#installing-helm).

## Jenkins CI server

We are going to build a pipeline for deploying the application. Check the [documentation](https://jenkins.io) for installation or use an existing one.


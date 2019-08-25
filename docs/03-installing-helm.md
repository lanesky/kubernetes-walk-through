# Installing the Helm Tool


## Configure the kubectl config

Copy the kube config file from control-plance node. 

```
gcloud compute ssh controller-0 -- sudo cat /etc/kubernetes/admin.conf > $HOME/.kube/config
```

## Service account

Create a service account for helm tiller.

```
kubectl apply -f  deployments/helm/tiller-rbac.yaml 
```

## Init the helm

Run below command to initialize the helm on server.

```
helm init --service-account tiller --history-max 200
```

## Verfication

Run below command to verify the installation.

```
helm version
```

Output

```
Client: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
```
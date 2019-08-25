# Installing the HA Kubernete Cluster with kubeadm


In this step we install a HA kubernetes cluser. Since GCP limits the quota of the vCPUs to 8, we are going to build a cluster with 4 instances, each with 2 vCPUs.

## Prerequisites

Running the scripts needs to call other scripts in the same folder, so please execute the scripts from `/scripts` folder.


## Bootstrap the computer instances and network from GCP

With the script, we are going to create a VPC and 4 instances with subnetwork and firewall rules provisioned. The instances CIDR is 10.240.0.0/24 and the pod network cidr is 10.244.0.0/16/

```
./01-create-infra.sh
```

## Provision the components to all nodes

The script installs docker, kubeadm, kubelet, kubectl to all nodes.

```
./02-install-nodes.sh
```

## Create the load balancer for the control plane

The script installs a load balancer for the control plane. The IP address of the load balancer will be injected into the `kubeadm-config.yaml`  in the folder automatically and will be used at the next step.

```
./03-create-lb.sh
```

## Init the first control plane node from kubeadm

The script bootstaps one of the control plane nodes.

```
./04-kubeadm-init.sh
```

If the script is run successfully, the output will be as follows, which contains the join methods for control-plane and worker nodes. 

```
...
You can now join any number of control-plane node by running the following command on each as a root:
  kubeadm join 192.168.0.200:6443 --token 9vr73a.a8uxyaju799qwdjv --discovery-token-ca-cert-hash sha256:7c2e69131a36ae2a042a339b33381c6d0d43887e2de83720eff5359e26aec866 --control-plane --certificate-key f8902e114ef118304e561c3ecd4d0b543adc226b7a07f675f56564185ffe0c07

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use kubeadm init phase upload-certs to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:
  kubeadm join 192.168.0.200:6443 --token 9vr73a.a8uxyaju799qwdjv --discovery-token-ca-cert-hash sha256:7c2e69131a36ae2a042a339b33381c6d0d43887e2de83720eff5359e26aec866
```

## Provision the network add-on

Before installing other nodes, we need to install the CNI plugin at first. The script does the job.

```
./05-install-network-addon.sh
```

## Join the second control plane node with kubeadm

Login to the second control plane node.

```
gcloud compute ssh contrller-1
```

Run the control-plane node join method. Replace with below script with the actual result mentioned above.

```
sudo kubeadm join sudo kubeadm join <refer to above for control-plane join method>
```


## Join the two worker nodes with kubeadm

Log in to the first worker.

```
gcloud compute ssh worker-0
```

Run the Replace with below script with the actual result mentioned above.

```
sudo kubeadm join sudo kubeadm join <refer to above for worker join method>
```

Log in to the second worker.

```
gcloud compute ssh worker-1
```

Run the Replace with below script with the actual result mentioned above.

```
sudo kubeadm join sudo kubeadm join <refer to above for worker join method>
```


## Add the second control plance node into the load blancer target pool with 


The script creates a load balancer for the api server of the cluster.

```
./06-add-lb-instances.sh
```

## Verification

Log in the first controll-plane node.

```
gcloud compute ssh controller-0
```

Run `kubectl get nodes -o wide` , the output should be like below. Verfity all statuses are `READY`.

```
NAME           STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
controller-0   Ready    master   15h   v1.14.0   10.240.0.10   <none>        Ubuntu 16.04.6 LTS   4.15.0-1040-gcp   docker://18.6.2
controller-1   Ready    master   15h   v1.14.0   10.240.0.11   <none>        Ubuntu 16.04.6 LTS   4.15.0-1040-gcp   docker://18.6.2
worker-0       Ready    <none>   15h   v1.14.0   10.240.0.20   <none>        Ubuntu 16.04.6 LTS   4.15.0-1040-gcp   docker://18.6.2
worker-1       Ready    <none>   15h   v1.14.0   10.240.0.21   <none>        Ubuntu 16.04.6 LTS   4.15.0-1040-gcp   docker://18.6.2
```

Run below commond to create a deployment.

```
kubectl run ngnix --image=nginx --replicas=2
```

Run below commond to show pods. Verify the IPs are with 10.244.0.0/16 as specified in the pod subnetwork cidr contained in the `kubeadm-config.yaml`.

```
kubectl get pods -o wide
```

Output

```
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
ngnix-84d9bfb884-5p9n4   1/1     Running   0          50s   10.244.3.19   worker-1   <none>           <none>
ngnix-84d9bfb884-lrb2x   1/1     Running   0          50s   10.244.2.25   worker-0   <none>           <none>
```


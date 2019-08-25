#!/bin/bash



# Install https support:
sudo apt-get update 
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common


# Get kubernetes repo key:
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -



# Add kubernetes repo to manifest:
cat > kubernetes.list <<EOF 
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo mv kubernetes.list /etc/apt/sources.list.d/.

# Install kubeadm and docker:
sudo apt-get update
sudo apt-get install -y --allow-unauthenticated kubelet=1.14.0-00 kubeadm=1.14.0-00 kubectl=1.14.0-00



# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS

### Add Docker’s official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
sudo apt-get update 
sudo apt-get install -y --allow-unauthenticated docker-ce=18.06.2~ce~3-0~ubuntu

# Setup daemon.
cat > daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo mv daemon.json /etc/docker/.

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo swapoff -a

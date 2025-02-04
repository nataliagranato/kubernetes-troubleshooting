#!/bin/bash

echo "This script is written to work with Ubuntu 20.04"
sleep 3

# Disable swap until next reboot
echo "Disable swap until next reboot"
sudo swapoff -a

# Update the local node
echo "Updating the local node, please stand-by"
sudo apt-get update && sudo apt-get upgrade -y

# Ensure necessary modules are loaded after reboot
echo "Ensure two modules are loaded after reboot"
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Update sysctl settings
echo "Update sysctl to load iptables and ipforwarding"
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

# Install necessary software
echo "Install some necessary software"
sudo apt-get install curl apt-transport-https vim git wget gnupg2 software-properties-common lsb-release ca-certificates uidmap socat -y

# Install and configure containerd
echo "Install and configure containerd"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install containerd.io
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl restart containerd

# Install kubeadm, kubelet, and kubectl
echo "Install kubeadm, kubelet, and kubectl"
sudo mkdir -m 755 -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubeadm=1.30.1-1.1 kubelet=1.30.1-1.1 kubectl=1.30.1-1.1
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize the cluster without kube-proxy
echo "Initializing the Kubernetes cluster"
sudo kubeadm init --kubernetes-version=1.30.1 --pod-network-cidr=192.168.0.0/16 --skip-phases=addon/kube-proxy | sudo tee /var/log/kubeinit.log

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Cilium CLI
export CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
export CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# Install Cilium as the network plugin
echo "Installing Cilium..."
cilium install
sleep 15
cilium status --wait
kubectl get nodes
kubectl get pods -A

# Configure crictl
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 5
debug: false
EOF

# Install Helm
wget https://get.helm.sh/helm-v3.11.1-linux-amd64.tar.gz
tar -xf helm-v3.11.1-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/

echo "Script finished. Move to the next step"
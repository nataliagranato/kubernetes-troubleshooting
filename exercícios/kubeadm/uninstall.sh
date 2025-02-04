# Drenar nós
kubectl drain <node-name> --delete-emptydir-data --force --ignore-daemonsets

# Resetar o cluster
sudo kubeadm reset -f

# Parar e desabilitar serviços
sudo systemctl stop kubelet && sudo systemctl disable kubelet
sudo systemctl stop containerd && sudo systemctl disable containerd

# Remover diretórios e arquivos
sudo rm -rf /etc/kubernetes/ /var/lib/kubelet/ /var/lib/etcd/ /var/lib/cni/ /var/lib/containerd/ /run/containerd/ /opt/cni/ ~/.kube/

# Limpar redes e interfaces
ip link show | grep -E 'cni|flannel|calico|cilium'
sudo ip link delete <interface-name>
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F
sudo ipvsadm --clear

# Desinstalar pacotes
sudo apt-get purge -y kubelet kubeadm kubectl kubernetes-cni containerd.io
sudo apt-get autoremove -y

# Limpar imagens e volumes
sudo crictl images
sudo crictl rmi -a
sudo crictl ps -a
sudo crictl rm -fa

# Reiniciar o sistema
sudo reboot
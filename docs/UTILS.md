# Utilitários para Diagnóstico de Kubernetes

## 1. Verificar o Status dos Nós
```bash
kubectl get nodes
```
Mostra o status (Ready ou NotReady) de todos os nós no cluster.

```bash
kubectl describe node <node-name>
```
Fornece detalhes sobre um nó específico, incluindo eventos e condições.

## 2. Verificar Pods no Cluster
```bash
kubectl get pods -A
```
Lista todos os pods em todos os namespaces.

```bash
kubectl get pods -n <namespace>
```
Lista os pods em um namespace específico.

```bash
kubectl describe pod <pod-name> -n <namespace>
```

Fornece detalhes sobre um pod específico, incluindo eventos e logs de inicialização.

```bash
kubectl logs <pod-name> -n <namespace>
```

Exibe os logs de um pod específico.

```bash
kubectl logs -f <pod-name> -n <namespace>
```

Segue os logs de um pod em tempo real.

```bash
kubectl logs <pod-name> -c <container-name> -n <namespace>
```

Exibe logs de um contêiner específico dentro de um pod.

## 3. Verificar Componentes do Control Plane

### Kubelet

```bash
sudo systemctl status kubelet
```

Verifica o status do serviço kubelet.

```bash
sudo journalctl -u kubelet -f
```

Exibe logs em tempo real do kubelet.

### API Server
```bash
curl -k https://<api-server-ip>:6443/healthz
```

Verifica a saúde do servidor de API.

```bash
kubectl get componentstatuses
```

Mostra o status dos componentes principais do control plane (etcd, controller-manager, scheduler).

## 4. Verificar Etcd
```bash
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    endpoint health
```

Verifica a saúde do etcd.

```bash
sudo systemctl status etcd
```
Verifica o status do serviço etcd (se estiver rodando como um serviço separado).

## 5. Verificar Scheduler e Controller Manager
```bash
kubectl get pods -n kube-system | grep scheduler
```

Verifica o status do kube-scheduler.

```bash
kubectl get pods -n kube-system | grep controller-manager
```

Verifica o status do kube-controller-manager.

```bash
kubectl logs -n kube-system kube-scheduler-<node-name>
```

Exibe logs do kube-scheduler.

```bash
kubectl logs -n kube-system kube-controller-manager-<node-name>
```
Exibe logs do kube-controller-manager.

## 6. Verificar Serviços e Endpoints
```bash
kubectl get services -A
```

Lista todos os serviços no cluster.

```bash
kubectl get endpoints -A
```
Lista os endpoints associados aos serviços.

```bash
kubectl describe service <service-name> -n <namespace>
```
Fornece detalhes sobre um serviço específico.

## 7. Verificar Deployments, DaemonSets e StatefulSets
```bash
kubectl get deployments -A
```

Lista todos os deployments.

```bash
kubectl get daemonsets -A
```

Lista todos os DaemonSets.

```bash
kubectl get statefulsets -A
```

Lista todos os StatefulSets.

```bash
kubectl describe deployment <deployment-name> -n <namespace>
```

Fornece detalhes sobre um deployment específico.

## 8. Verificar ConfigMaps e Secrets

```bash
kubectl get configmaps -A
```

Lista todos os ConfigMaps.

```bash
kubectl get secrets -A
```
Lista todos os Secrets.

```bash
kubectl describe configmap <configmap-name> -n <namespace>
```
Fornece detalhes sobre um ConfigMap específico.

## 9. Verificar Eventos do Cluster
```bash
kubectl get events -A
```
Lista todos os eventos no cluster.

```bash
kubectl describe node <node-name>
```
Exibe eventos relacionados a um nó específico.

## 10. Verificar Recursos de Rede

### CNI (por exemplo, Cilium)
```bash
cilium status
```
Verifica o status do Cilium.

```bash
cilium connectivity test
```

Executa testes de conectividade no cluster.

```bash
kubectl get cep -A
```
Lista os endpoints do Cilium.

## 11. Verificar Uso de Recursos
```bash
kubectl top nodes
```

Mostra o uso de CPU e memória por nó.

```bash
kubectl top pods -A
```

Mostra o uso de CPU e memória por pod.

## 12. Verificar Logs do Container Runtime

### Containerd
```bash
sudo crictl ps -a
```
Lista todos os containers gerenciados pelo containerd.

```bash
sudo crictl images
```
Lista todas as imagens disponíveis.

```bash
sudo crictl inspect <container-id>
```
Inspeciona um container específico.

```bash
sudo journalctl -u containerd -f
```
Exibe logs em tempo real do containerd.

## 13. Verificar Configurações do Kubelet
```bash
ps aux | grep kubelet
```
Verifica os argumentos e flags usados pelo kubelet.

```bash
cat /var/lib/kubelet/config.yaml
```
Exibe a configuração do kubelet.

## 14. Verificar Certificados
```bash
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout
```
Inspeciona o certificado do API server.

```bash
kubeadm certs check-expiration
```
Verifica a expiração dos certificados do cluster.

Esses comandos são essenciais para diagnosticar problemas em um cluster Kubernetes. Use-os conforme necessário para identificar e resolver falhas nos componentes do cluster.

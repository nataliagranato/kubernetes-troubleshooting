# Relatório Post-Mortem: Resolução do Conflito entre kube-proxy e Cilium

## 1. Resumo do Incidente
Durante a instalação de um cluster Kubernetes utilizando o script fornecido, identificamos que o nó control plane estava em estado NotReady, com falhas na inicialização dos pods do CoreDNS e do kube-proxy. Após investigação detalhada, concluímos que o problema principal era um conflito entre o kube-proxy (instalado automaticamente pelo kubeadm) e o Cilium, que foi configurado como a solução de rede (CNI) para o cluster.

O Cilium é projetado para substituir o kube-proxy ao fornecer sua própria implementação de balanceamento de carga e gerenciamento de rede usando eBPF. A coexistência do kube-proxy com o Cilium causou inconsistências na configuração da rede do cluster, resultando em falhas no rollout dos componentes essenciais.

## 2. Análise Detalhada do Problema

### 2.1. Sintomas Observados
- O nó control plane permaneceu em estado NotReady.
- Os pods do CoreDNS ficaram no estado Pending.
- Os pods do kube-proxy entraram em estado CrashLoopBackOff.
- O status do Cilium indicava erros relacionados ao rollout dos componentes (cilium, cilium-envoy, e cilium-operator).
- O log do kubelet relatou problemas com o container runtime (container runtime network not ready).

### 2.2. Causa Raiz
A causa raiz do problema foi a instalação automática do kube-proxy pelo comando kubeadm init, que entrou em conflito com o Cilium. O Cilium assumiu a responsabilidade pelo gerenciamento da rede e do proxy, mas o kube-proxy continuou tentando executar suas funções, causando inconsistências.

## 3. Verificações Realizadas
Para diagnosticar o problema, realizamos as seguintes verificações:

### 3.1. Status do Cluster
Executamos os seguintes comandos para verificar o estado do cluster:
```bash
kubectl get nodes
kubectl get pods -A
```
Observamos que:
- O nó control plane estava em estado NotReady.
- Os pods do CoreDNS estavam pendentes.
- Os pods do kube-proxy estavam em CrashLoopBackOff.

### 3.2. Logs do Kubelet
Inspecionamos os logs do kubelet para identificar problemas de rede:
```bash
sudo journalctl -u kubelet -f
```
Os logs revelaram mensagens como:
- container runtime network not ready.
- Network plugin returns error: cni plugin not initialized.

### 3.3. Status do Cilium
Verificamos o status do Cilium após a instalação:
```bash
cilium status --wait
```
Os erros indicaram que os componentes do Cilium (cilium, cilium-envoy, e cilium-operator) não estavam sendo iniciados corretamente.

### 3.4. Configuração do kube-proxy
Confirmamos que o kube-proxy estava instalado e ativo:
```bash
kubectl get daemonset -n kube-system kube-proxy
```
Isso confirmou que o kube-proxy estava em execução, criando conflitos com o Cilium.

## 4. Soluções Implementadas
Com base nas verificações, implementamos as seguintes soluções:

### 4.1. Desativação do kube-proxy
Removemos o kube-proxy para permitir que o Cilium assumisse completamente o gerenciamento da rede:
```bash
kubectl delete daemonset kube-proxy -n kube-system
kubectl delete configmap kube-proxy -n kube-system
```

### 4.2. Reconfiguração do Bootstrap do Cluster
Atualizamos o script de instalação para desativar o kube-proxy durante o bootstrap do cluster:
```bash
sudo kubeadm init --kubernetes-version=1.30.1 --pod-network-cidr=192.168.0.0/16 --skip-phases=addon/kube-proxy
```

### 4.3. Reinstalação do Cilium
Reinstalamos o Cilium para garantir que ele fosse configurado corretamente:
```bash
cilium uninstall
cilium install
cilium status --wait
```

### 4.4. Verificação Final
Após as correções, verificamos novamente o estado do cluster:
```bash
kubectl get nodes
kubectl get pods -A
cilium status --wait
```
Todos os componentes estavam funcionando corretamente, e o nó control plane estava em estado Ready.

## 5. Lições Aprendidas

### 5.1. Evitar Conflitos Entre Componentes
É fundamental evitar a coexistência de múltiplas soluções que desempenham funções semelhantes (como kube-proxy e Cilium). Ao usar uma solução de rede avançada como o Cilium, devemos desativar explicitamente o kube-proxy durante o bootstrap do cluster.

### 5.2. Validar Scripts de Instalação
Scripts automatizados devem incluir verificações explícitas para garantir que todos os componentes estejam funcionando corretamente após cada etapa crítica. Isso inclui verificar o status do kubelet, do container runtime e da CNI.

### 5.3. Monitoramento Proativo
O monitoramento proativo dos logs do kubelet e dos eventos do cluster pode ajudar a identificar problemas antes que eles se tornem críticos.

## 6. Melhorias Futuras

### 6.1. Atualizar o Script de Instalação
Incorporar as seguintes melhorias ao script:
- Adicionar verificações automáticas após cada etapa crítica.
- Incluir opções para diferentes CNIs e ajustar o CIDR de rede conforme necessário.
- Documentar claramente as dependências e configurações específicas para cada CNI.

### 6.2. Treinamento e Documentação
Criar documentação detalhada sobre como configurar diferentes CNIs em clusters Kubernetes, destacando as interações entre os componentes e os potenciais pontos de conflito.

## 7. Conclusão
O incidente foi resolvido com sucesso após identificar e corrigir o conflito entre o kube-proxy e o Cilium. As lições aprendidas neste processo nos ajudarão a evitar problemas semelhantes no futuro e a melhorar nossos processos de implantação e manutenção de clusters Kubernetes.

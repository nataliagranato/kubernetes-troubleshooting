# Diagrama 1: Arquitetura do Kubernetes (Componentes Críticos)

```mermaid
graph TD
    A[Cluster Kubernetes] --> B[Control Plane]
    B --> C[API Server]
    B --> D[etcd]
    B --> E[Controller Manager]
    B --> F[Scheduler]
    A --> G[Worker Nodes]
    G --> H[Kubelet]
    G --> I[Container Runtime]
    G --> J[Kube-proxy]
    A --> K[Pods]
```

Este diagrama mostra a arquitetura básica do Kubernetes, destacando os componentes críticos:
- **Cluster Kubernetes**: O conjunto completo de nós que compõem o cluster.
- **Control Plane**: O plano de controle que gerencia o cluster.
  - **API Server**: O ponto de entrada para todas as operações administrativas no cluster.
  - **etcd**: O armazenamento de dados chave-valor distribuído usado para armazenar todos os dados de cluster.
  - **Controller Manager**: Gerencia os controladores que regulam o estado do cluster.
  - **Scheduler**: Responsável por atribuir pods aos nós de trabalho.
- **Worker Nodes**: Os nós que executam as aplicações.
  - **Kubelet**: O agente que roda em cada nó de trabalho e garante que os contêineres estejam rodando.
  - **Container Runtime**: O software que executa os contêineres.
  - **Kube-proxy**: Mantém as regras de rede no nó de trabalho.
- **Pods**: As menores unidades de implantação no Kubernetes.



# Diagrama 2: Fluxo de Comunicação entre Pods e Services

```mermaid
sequenceDiagram
    participant PodA
    participant Service
    participant PodB
    PodA->>Service: Requisição HTTP
    Service->>PodB: Encaminha requisição
    PodB-->>Service: Resposta
    Service-->>PodA: Resposta ao cliente
```

Este diagrama mostra como a comunicação ocorre entre pods e serviços:
- **PodA** envia uma requisição HTTP para o **Service**.
- O **Service** encaminha a requisição para **PodB**.
- **PodB** responde ao **Service**.
- O **Service** responde ao **PodA**.


# Diagrama 3: Ciclo de Vida de um Pod

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Running: Agendado pelo Scheduler
    Running --> Succeeded: Tarefa concluída
    Running --> Failed: Erro na execução
    Failed --> Terminated: Removido
    Succeeded --> Terminated: Removido
```

Este diagrama ilustra os diferentes estados pelos quais um pod pode passar:
- **Pending**: O pod foi aceito pelo sistema, mas ainda não foi agendado para um nó.
- **Running**: O pod foi agendado e está sendo executado.
- **Succeeded**: O pod completou sua tarefa com sucesso.
- **Failed**: O pod falhou na execução.
- **Terminated**: O pod foi removido.

# Diagrama 4: Troubleshooting de Falhas no Control Plane

```mermaid
flowchart TD
    A[Falha no Control Plane] --> B{Verificar API Server}
    B -->|OK| C{Verificar etcd}
    B -->|Erro| D[Reiniciar API Server]
    C -->|OK| E{Verificar Controller Manager}
    C -->|Erro| F[Restaurar etcd]
    E -->|OK| G{Verificar Scheduler}
    E -->|Erro| H[Reiniciar Controller Manager]
    G -->|OK| I[Sistema Operacional]
    G -->|Erro| J[Reiniciar Scheduler]
```

Este diagrama mostra um fluxo de trabalho para solucionar problemas no plano de controle:
- **Falha no Control Plane** leva à verificação do **API Server**.
- Se o **API Server** estiver OK, verifica-se o **etcd**.
- Se o **etcd** estiver OK, verifica-se o **Controller Manager**.
- Se o **Controller Manager** estiver OK, verifica-se o **Scheduler**.
- Se todos os componentes estiverem OK, verifica-se o **Sistema Operacional**.


# Diagrama 5: Persistent Volumes (PV) e Persistent Volume Claims (PVC)

```mermaid
flowchart LR
    PVC[[PVC]] -->|Vincula| PV[[PV]]
    PV -->|Provisionado por| StorageClass[[StorageClass]]
    StorageClass -->|Backend| Storage[(Storage\nAWS EBS/NFS)]
    classDef error fill:#ff9999;
    PVC -.->|Erro: StorageClass\n não existe| Error[(PVC Pendente)]:::error
```

Este diagrama mostra a relação entre PVs, PVCs e StorageClasses:
- **PVC** vincula-se a um **PV**.
- **PV** é provisionado por uma **StorageClass**.
- **StorageClass** define o backend de armazenamento (por exemplo, AWS EBS, NFS).
- Se a **StorageClass** não existir, o **PVC** fica pendente.

# Diagrama 6: Troubleshooting de Rede (Exemplo Prático)

```mermaid
flowchart TD
    A[Falha de Rede] --> B{Verificar kube-proxy}
    B -->|OK| C{Verificar DNS}
    B -->|Erro| D[Reiniciar kube-proxy]
    C -->|OK| E{Verificar ConfigMap}
    C -->|Erro| F[Corrigir DNS]
    E -->|OK| G[Verificar Regras de Firewall]
    E -->|Erro| H[Atualizar ConfigMap]
    G -->|OK| I[Rede Funcional]
    G -->|Erro| J[Ajustar Regras de Firewall]
```

Este diagrama mostra um fluxo de trabalho para solucionar problemas de rede:
- **Falha de Rede** leva à verificação do **kube-proxy**.
- Se o **kube-proxy** estiver OK, verifica-se o **DNS**.
- Se o **DNS** estiver OK, verifica-se o **ConfigMap**.
- Se o **ConfigMap** estiver OK, verifica-se as **Regras de Firewall**.

# Diagrama 7: Monitoramento com Prometheus + Grafana

```mermaid
graph TD
    A[Cluster Kubernetes] --> B[Exporters]
    B --> C[Node Exporter]
    B --> D[cAdvisor]
    C --> E[Prometheus]
    D --> E
    E --> F[Grafana]
    F --> G[Dashboards]
```

Este diagrama mostra a configuração de monitoramento com Prometheus e Grafana:
- **Cluster Kubernetes** envia dados para os **Exporters**.
- **Node Exporter** e **cAdvisor** coletam métricas.
- **Prometheus** coleta dados dos exporters.
- **Grafana** usa os dados do Prometheus para criar **Dashboards**.

# Diagrama Adicional: Troubleshooting de Pod (Exemplo)

```mermaid
flowchart TD
    A[Falha no Pod] --> B{Verificar Logs}
    B -->|OK| C{Verificar Recursos}
    B -->|Erro| D[Corrigir Erro no Código]
    C -->|OK| E{Verificar Health Checks}
    C -->|Erro| F[Aumentar Recursos]
    E -->|OK| G[Pod Funcional]
    E -->|Erro| H[Corrigir Health Checks]
```

Este diagrama mostra um fluxo de trabalho para solucionar problemas em um pod:
- **Falha no Pod** leva à verificação dos **Logs**.
- Se os **Logs** estiverem OK, verifica-se os **Recursos**.
- Se os **Recursos** estiverem OK, verifica-se os **Health Checks**.
- Se os **Health Checks** estiverem OK, o **Pod** está funcional.

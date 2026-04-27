# 01 - Nodes

## What is a Node?

A **Node** is a physical or virtual machine that is part of a Kubernetes cluster.
Every node is managed by the control plane and runs the necessary components to host Pods.

```
Kubernetes Cluster
├── Control Plane Node(s)   → manages the cluster
└── Worker Node(s)          → runs your applications (Pods)
```

---

## Types of Nodes

### 1. Control Plane Node
- Runs control plane components: API Server, etcd, Scheduler, Controller Manager
- **Tainted by default** — normal application Pods are not scheduled here
- In production: usually 3 control plane nodes for high availability
- Taint: `node-role.kubernetes.io/control-plane:NoSchedule`

### 2. Worker Node
- Runs application workloads (your Pods)
- Components: `kubelet`, `kube-proxy`, container runtime
- A cluster can have 1 to thousands of worker nodes

---

## Node Components (recap)

```
┌──────────────────────────────────┐
│           WORKER NODE            │
│                                  │
│  kubelet         → node agent    │
│  kube-proxy      → networking    │
│  container runtime → runs ctrs   │
│                                  │
│  ┌──────┐ ┌──────┐ ┌──────┐      │
│  │ Pod  │ │ Pod  │ │ Pod  │      │
│  └──────┘ └──────┘ └──────┘      │
└──────────────────────────────────┘
```

---

## Node Status & Conditions

K8s tracks the health of every node via **conditions**:

| Condition | Meaning |
|---|---|
| `Ready` | Node is healthy and ready to accept Pods |
| `MemoryPressure` | Node is running low on memory |
| `DiskPressure` | Node is running low on disk space |
| `PIDPressure` | Too many processes running on the node |
| `NetworkUnavailable` | Node network is not configured correctly |

> If `Ready = False` or `Ready = Unknown`, the node is considered unhealthy and pods may be rescheduled elsewhere.

---

## Node Info / Capacity

Each node exposes key metadata that the Scheduler uses to make decisions:

```yaml
# Visible via: kubectl describe node <node-name>
Capacity:
  cpu:                2
  memory:             4Gi
  pods:               110       # max pods this node can run

Allocatable:          # what's actually available after system reservations
  cpu:                1900m
  memory:             3.5Gi

System Info:
  OS:                 Linux
  Kernel Version:     5.15.0
  Container Runtime:  containerd://1.6.0
  Kubelet Version:    v1.28.0
  Kube-Proxy Version: v1.28.0
```

---

## How a Node Joins the Cluster

```
Node boots up
     │
     ▼
kubelet starts → registers itself with API Server
     │
     ▼
API Server adds Node object to etcd
     │
     ▼
Controller Manager watches Node health
     │
     ▼
Scheduler can now place Pods on this Node ✅
```

---

## Taints & Tolerations (intro)

- **Taint** → placed on a Node to **repel** pods
- **Toleration** → placed on a Pod to **allow** it on a tainted node

```
Control plane node has taint:
  node-role.kubernetes.io/control-plane:NoSchedule

→ Normal pods won't be scheduled there
→ Only system pods with a matching toleration can run there
```

> Deep dive on Taints & Tolerations comes with the Scheduling topic.

---

## Useful kubectl Commands

```bash
# List all nodes
kubectl get nodes

# List nodes with more info (IP, roles, version)
kubectl get nodes -o wide

# Detailed info about a specific node
kubectl describe node <node-name>

# Check node resource usage
kubectl top nodes

# Mark a node as unschedulable (no new pods)
kubectl cordon <node-name>

# Drain a node (evict all pods, for maintenance)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Bring node back online
kubectl uncordon <node-name>

# Add a label to a node
kubectl label node <node-name> env=production

# Add a taint to a node
kubectl taint nodes <node-name> key=value:NoSchedule
```

---

## Node Labels

Labels are key-value pairs on nodes used for:
- **Node selectors** — schedule pods on specific nodes
- **Affinity rules** — advanced scheduling preferences

```bash
# View node labels
kubectl get nodes --show-labels

# Common built-in labels
kubernetes.io/hostname=node1
kubernetes.io/os=linux
kubernetes.io/arch=amd64
node.kubernetes.io/instance-type=t3.medium   # cloud only
```

---

## 🧠 Revision Questions

1. What is the difference between `Capacity` and `Allocatable` on a node?
2. What happens to Pods on a node when it goes `NotReady`?
3. What is the purpose of `kubectl cordon` vs `kubectl drain`?
4. Why is the control plane node tainted by default?
5. Which component on the node is responsible for registering it with the cluster?

> Answers in `notes.md`
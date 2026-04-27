# 00 - Kubernetes Architecture

## Overview

Kubernetes (K8s) is a container orchestration platform. Every K8s cluster has two main parts:

| Part | Also Called | Role |
|---|---|---|
| Master Node | Control Plane | Brain — decides **what** to run, **where**, and monitors it |
| Worker Node | Data Plane | Muscle — where your actual applications (containers) run |

---

## Control Plane Components

```
┌─────────────────────────────────────────────────────┐
│                   CONTROL PLANE                     │
│                                                     │
│  ┌─────────────┐   ┌──────┐   ┌─────────────────┐  │
│  │  API Server │   │ etcd │   │   Scheduler     │  │
│  │ (entrypoint)│   │ (DB) │   │ (decides where) │  │
│  └─────────────┘   └──────┘   └─────────────────┘  │
│                                                     │
│  ┌──────────────────────┐  ┌──────────────────────┐ │
│  │  Controller Manager  │  │ Cloud Controller Mgr │ │
│  │  (maintains state)   │  │ (optional, for cloud)│ │
│  └──────────────────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### 1. API Server (`kube-apiserver`)
- **The single entrypoint** for all communication in the cluster
- Every `kubectl` command hits the API server first
- Validates and processes requests, then updates etcd
- Think of it as the **receptionist** of K8s

### 2. etcd
- **Distributed key-value store** — the cluster's database
- Stores ALL cluster state: nodes, pods, configs, secrets
- If etcd dies, the cluster loses its memory
- Think of it as the **brain's memory**

### 3. Scheduler (`kube-scheduler`)
- Watches for newly created Pods that have no Node assigned
- Decides **which Node** a Pod should run on
- Considers: resource availability, affinity rules, taints/tolerations
- Think of it as the **HR manager** assigning work

### 4. Controller Manager (`kube-controller-manager`)
- Runs multiple controllers in a single process
- Continuously watches cluster state and reconciles it to **desired state**
- Examples: Node Controller, ReplicaSet Controller, Deployment Controller
- Think of it as the **operations manager** keeping things running

### 5. Cloud Controller Manager (optional)
- Connects K8s to cloud provider APIs (AWS, GCP, Azure)
- Manages cloud-specific resources: load balancers, volumes, routes
- Only present in cloud-managed clusters (EKS, GKE, AKS)

---

## Worker Node Components

```
┌─────────────────────────────────┐
│           WORKER NODE           │
│                                 │
│  ┌─────────┐  ┌───────────────┐ │
│  │ kubelet │  │  kube-proxy   │ │
│  │ (agent) │  │  (networking) │ │
│  └─────────┘  └───────────────┘ │
│                                 │
│  ┌───────────────────────────┐  │
│  │    Container Runtime      │  │
│  │  (containerd / CRI-O)     │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌────┐ ┌────┐ ┌────┐           │
│  │Pod │ │Pod │ │Pod │  ...      │
│  └────┘ └────┘ └────┘           │
└─────────────────────────────────┘
```

### 1. kubelet
- An **agent** that runs on every worker node
- Receives Pod specs from the API server
- Ensures containers described in PodSpecs are running and healthy
- Reports node and pod status back to the control plane
- Think of it as the **node's local manager**

### 2. kube-proxy
- Runs on every node, maintains **network rules**
- Enables communication to Pods from inside or outside the cluster
- Handles Service networking (ClusterIP, NodePort etc.)
- Think of it as the **network traffic controller**

### 3. Container Runtime
- The software that actually **runs containers**
- K8s supports any CRI (Container Runtime Interface) compatible runtime
- Common options: `containerd`, `CRI-O`
- Docker used to be used but was deprecated in K8s 1.24+

---

## How They Work Together — Request Flow

```
Developer
   │
   │  kubectl apply -f pod.yaml
   ▼
API Server  ──────────────────────► etcd (stores desired state)
   │
   ▼
Scheduler ──► picks best Node
   │
   ▼
API Server ──► notifies kubelet on chosen Node
   │
   ▼
kubelet ──► tells Container Runtime to pull image & start container
   │
   ▼
Pod is Running ✅
```

---

## Key Concepts to Remember

| Concept | One-liner |
|---|---|
| Desired State | What you declare in YAML |
| Actual State | What's currently running |
| Reconciliation | Controller Manager constantly syncs actual → desired |
| API Server | Only component that talks to etcd directly |

---

## Common kubectl Commands

```bash
# View all nodes in the cluster
kubectl get nodes

# View detailed info about a node
kubectl describe node <node-name>

# View control plane component status
kubectl get componentstatuses

# View system pods (control plane runs as pods in kubeadm clusters)
kubectl get pods -n kube-system
```

---

## 🧠 Revision Questions

1. Which component is the **only one** that directly reads/writes to etcd?
2. A Pod is created but stays in `Pending` — which component is likely busy?
3. What is the difference between Controller Manager and Scheduler?
4. If `kubelet` crashes on a node, what happens to running pods on that node?

> Answers are in `notes.md`
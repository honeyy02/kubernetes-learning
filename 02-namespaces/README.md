# 02 - Namespaces

## What is a Namespace?

A **Namespace** is a logical boundary inside a Kubernetes cluster that lets you divide and organise resources. Think of it as a virtual cluster within a cluster.

```
Kubernetes Cluster
├── namespace: default       → where resources go if you don't specify
├── namespace: kube-system   → K8s internal components
├── namespace: dev           → dev team workloads
├── namespace: qa            → QA/testing workloads
└── namespace: prod          → production workloads
```

---

## Why Use Namespaces?

| Use Case | Example |
|---|---|
| Environment separation | `dev`, `qa`, `staging`, `prod` |
| Team separation | `team-frontend`, `team-backend` |
| Resource control | Give dev 2Gi RAM max, prod 16Gi |
| Access control | Dev team can only access `dev` namespace |
| Avoid name collisions | Two teams can both have an app called `backend` in different namespaces |

---

## 4 Default Namespaces

| Namespace | Purpose |
|---|---|
| `default` | Where your resources go if you don't specify a namespace |
| `kube-system` | K8s internal components (API server, scheduler, DNS etc.) |
| `kube-public` | Publicly readable, used for cluster info — rarely used manually |
| `kube-node-lease` | Stores node heartbeat objects — helps detect node failures faster |

```bash
# See all default namespaces
kubectl get namespaces
```

---

## Namespaced vs Cluster-Scoped Resources

Not everything lives inside a namespace:

| Namespaced (scoped) | Cluster-wide (not namespaced) |
|---|---|
| Pods | Nodes |
| Deployments | PersistentVolumes |
| Services | ClusterRoles |
| ConfigMaps | StorageClasses |
| Secrets | Namespaces themselves |

```bash
# Check if a resource type is namespaced
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=false
```

---

## Resource Quotas

You can limit how much CPU/memory/pods a namespace can use:

```
namespace: dev
  max CPU:    2 cores
  max memory: 4Gi
  max pods:   10
```

If a pod tries to exceed the quota → it gets **rejected**.

---

## Cross-Namespace Communication

By default, pods across namespaces **can** talk to each other using full DNS:

```
<service-name>.<namespace>.svc.cluster.local

# Example: frontend in dev talking to backend in prod
http://backend.prod.svc.cluster.local:8080
```

To **restrict** cross-namespace traffic → use **NetworkPolicy** (covered in CNI topic).

---

## kubectl Tips for Namespaces

```bash
# Always add -n <namespace> or --namespace <namespace>
kubectl get pods -n dev
kubectl get pods -n kube-system

# See resources across ALL namespaces
kubectl get pods --all-namespaces
kubectl get pods -A                     # shorthand

# Set a default namespace for your session (so you don't keep typing -n)
kubectl config set-context --current --namespace=dev

# Check which namespace you're currently in
kubectl config view --minify | grep namespace
```

---

## 🧠 Revision Questions

1. What namespace do pods go to if you don't specify one?
2. Are Nodes namespaced resources? Why or why not?
3. What happens if a pod tries to use more CPU than its namespace quota allows?
4. How would a pod in `dev` namespace reach a service called `backend` in `prod` namespace?
5. What is `kube-node-lease` used for?

> Answers in `notes.md`
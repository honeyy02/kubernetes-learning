# Architecture — Tips, Gotchas & Revision Answers

## Revision Answers

1. **Only the API Server** talks directly to etcd. All other components go through the API Server.
2. **The Scheduler** — it's responsible for assigning Pods to Nodes. Pending = not yet scheduled.
3. **Scheduler** decides *where* to place a Pod (one-time decision). **Controller Manager** continuously watches and maintains the *desired state* (ongoing).
4. Pods keep running (container runtime is independent), but the node becomes `NotReady` and the control plane can't get health updates. Eventually pods may be rescheduled elsewhere.

---

## Common Gotchas

- ❗ `etcd` ≠ `etc` — always spell it correctly, it's a proper name (from the Unix `/etc` directory + `d` for distributed)
- ❗ Docker is **not** the container runtime in modern K8s (deprecated since 1.24) — it's `containerd`
- ❗ The control plane itself runs as Pods inside `kube-system` namespace (in kubeadm clusters)
- ❗ `kube-proxy` ≠ a reverse proxy — it manages iptables/IPVS rules, not HTTP traffic
- ❗ Worker nodes don't need to know about each other — only the control plane has the full picture

---

## Interview Tips

- "What happens when you run `kubectl apply`?" → Walk through the full flow: kubectl → API Server → etcd → Scheduler → kubelet → container runtime
- etcd is the **source of truth** — back it up in production!
- The control plane is **stateless** (except etcd) — API server, scheduler, controller manager can be restarted safely

---

## Quick Reference

```
Control Plane:
  kube-apiserver        → entrypoint, validates all requests
  etcd                  → key-value store, cluster database  
  kube-scheduler        → assigns pods to nodes
  kube-controller-manager → reconciles desired vs actual state
  cloud-controller-manager → (optional) cloud provider integration

Worker Node:
  kubelet               → node agent, manages pod lifecycle
  kube-proxy            → networking rules for Services
  container runtime     → runs containers (containerd, CRI-O)
```
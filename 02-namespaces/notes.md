# Namespaces — Tips, Gotchas & Revision Answers

## Revision Answers

1. **`default` namespace** — all resources go here if no namespace is specified in the manifest or CLI.
2. **No** — Nodes are cluster-scoped resources. They represent physical/virtual machines that belong to the whole cluster, not any single namespace.
3. The pod creation is **rejected** immediately by the API Server with a quota exceeded error. The pod never gets created.
4. Using the full DNS: `http://backend.prod.svc.cluster.local` — format is `<service>.<namespace>.svc.cluster.local`
5. `kube-node-lease` stores **Lease objects** for each node. kubelet updates its Lease every few seconds as a heartbeat. This lets the control plane detect node failures faster without overloading the API server.

---

## Common Gotchas

- ❗ Deleting a namespace **deletes everything inside it** — pods, services, configmaps, secrets. Be careful!
- ❗ Namespaces do NOT provide network isolation by default — pods can still talk across namespaces
- ❗ `kubectl get pods` only shows `default` namespace — always use `-A` or `-n <ns>` to see everything
- ❗ Some resources like Nodes, PVs, ClusterRoles are **not** in any namespace — `-n` flag has no effect on them
- ❗ `kube-system` namespace — never delete or modify things here unless you know what you're doing

---

## Namespace vs Network Isolation

Common misconception: namespaces ≠ network isolation

```
Namespace separation:  ✅ organises resources, access control, quotas
Network isolation:     ❌ NOT automatic — need NetworkPolicy for this
```

---

## Interview Tips

- "How do you isolate teams in K8s?" → Namespaces + RBAC (roles) + ResourceQuotas + NetworkPolicies
- "Can two pods in different namespaces have the same name?" → Yes! Names only need to be unique *within* a namespace
- "What's the difference between namespace-scoped and cluster-scoped resources?" → Use `kubectl api-resources` to check

---

## Quick Reference

```bash
kubectl get namespaces                              # list all namespaces
kubectl create namespace dev                        # create namespace (imperative)
kubectl apply -f namespace.yaml                     # create namespace (declarative)
kubectl get pods -n dev                             # pods in specific namespace
kubectl get pods -A                                 # pods in ALL namespaces
kubectl describe resourcequota dev-quota -n dev     # check quota usage
kubectl config set-context --current --namespace=dev  # set default namespace
kubectl delete namespace dev                        # delete namespace + everything in it!
```
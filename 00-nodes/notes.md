# Nodes — Tips, Gotchas & Revision Answers

## Revision Answers

1. **Capacity** = total resources the node has (e.g. 4Gi RAM). **Allocatable** = what's left after reserving resources for system processes (kubelet, OS). Scheduler uses *Allocatable*, not Capacity.

2. Pods are not immediately killed. After a timeout (~5 min by default), the Controller Manager marks them for rescheduling and new Pods are created on healthy nodes. Old pods get `Terminating` status.

3. **`cordon`** = marks node as unschedulable (no new pods land here, existing pods keep running). **`drain`** = cordons the node AND evicts all running pods (used before maintenance/shutdown).

4. To prevent user application pods from accidentally running on the control plane and consuming resources needed by cluster management components.

5. **kubelet** — it starts up, reads the node's info, and registers it with the API Server automatically.

---

## Common Gotchas

- ❗ `kubectl top nodes` requires **Metrics Server** to be installed — not available by default
- ❗ `kubectl drain` will **fail** if pods are not managed by a controller (standalone pods) — use `--force` carefully
- ❗ DaemonSet pods are NOT evicted by drain by default — use `--ignore-daemonsets`
- ❗ A node in `NotReady` does NOT immediately kill its pods — there's a grace period (tolerationSeconds)
- ❗ Node labels with prefix `kubernetes.io/` are auto-added by K8s — don't manually modify them

---

## cordon vs drain vs delete — When to use what?

| Command | Use case | Pods affected? |
|---|---|---|
| `cordon` | Temporarily stop new pods landing | No — existing pods stay |
| `drain` | Node maintenance / shutdown | Yes — all pods evicted |
| `delete node` | Remove node from cluster permanently | Node object deleted, pods rescheduled |

---

## Interview Tips

- "How does K8s know a node is unhealthy?" → kubelet stops sending heartbeats to API server → node condition becomes `Unknown` → Controller Manager starts rescheduling pods
- Nodes are just API objects — you can `kubectl get node`, `kubectl describe node`, `kubectl delete node`
- In managed clouds (EKS/GKE), nodes are just EC2/VMs — the cloud auto-replaces failed ones

---

## Quick Reference

```bash
kubectl get nodes                          # list nodes
kubectl get nodes -o wide                  # with IPs and runtime
kubectl describe node <name>               # full details
kubectl top nodes                          # CPU/memory usage
kubectl cordon <name>                      # stop scheduling
kubectl drain <name> --ignore-daemonsets   # evict pods
kubectl uncordon <name>                    # re-enable scheduling
kubectl label node <name> key=value        # add label
kubectl taint nodes <name> key=val:Effect  # add taint
```
# Node Inspection — Practice Commands
# Run these on Killer Koda to explore nodes

# ── 1. List all nodes ─────────────────────────────────────
kubectl get nodes

# Expected output:
# NAME           STATUS   ROLES           AGE   VERSION
# controlplane   Ready    control-plane   10d   v1.28.0
# node01         Ready    <none>          10d   v1.28.0


# ── 2. Wide output (IPs, container runtime) ───────────────
kubectl get nodes -o wide


# ── 3. Describe a node (capacity, conditions, pods) ───────
kubectl describe node node01


# ── 4. Check node labels ──────────────────────────────────
kubectl get nodes --show-labels


# ── 5. Add a custom label to a node ──────────────────────
kubectl label node node01 env=production

# Verify
kubectl get nodes --show-labels | grep env


# ── 6. Cordon a node (stop new pods scheduling) ───────────
kubectl cordon node01

# Check — node should show SchedulingDisabled
kubectl get nodes


# ── 7. Uncordon (re-enable scheduling) ────────────────────
kubectl uncordon node01


# ── 8. Drain a node (evict all pods) ──────────────────────
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data

# Note: This will evict all pods — don't run on a live prod node!


# ── 9. Add a taint to a node ──────────────────────────────
kubectl taint nodes node01 env=production:NoSchedule

# This means: no pod can be scheduled on node01
# unless the pod has a matching toleration

# Remove the taint
kubectl taint nodes node01 env=production:NoSchedule-


# ── 10. View node resource usage (needs metrics-server) ───
kubectl top nodes
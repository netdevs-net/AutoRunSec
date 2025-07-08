#!/bin/bash
set -e

NAMESPACE=monitoring

# 1. Stop monitoring workloads
kubectl delete deployment grafana prometheus -n $NAMESPACE --ignore-not-found=true
kubectl delete daemonset node-exporter -n $NAMESPACE --ignore-not-found=true
kubectl delete deployment kube-state-metrics -n $NAMESPACE --ignore-not-found=true

# 2. Delete PVCs and PVs (old and new names)
kubectl delete pvc grafana-data grafana-data-new prometheus-storage -n $NAMESPACE --ignore-not-found=true
kubectl delete pv grafana-pv grafana-pv-new prometheus-pv prometheus-pv-new --ignore-not-found=true

# 3. Wait for PVs to terminate
while kubectl get pv | grep -q Terminating; do
  echo "Waiting for PVs to terminate..."
  sleep 2
done

# 4. Re-apply manifests
kubectl apply -k infrastructure/monitoring

# 5. Show status
kubectl get pods -n $NAMESPACE
kubectl get pvc -n $NAMESPACE
kubectl get pv

echo "\n✅ Monitoring storage reset complete!" 
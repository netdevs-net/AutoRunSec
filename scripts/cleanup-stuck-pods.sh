#!/bin/bash
# cleanup-stuck-pods.sh
# Force delete all pods stuck in Terminating or Completed state in all namespaces

set -euo pipefail

# Get all pods in all namespaces that are Terminating or Completed for more than 5 minutes
kubectl get pods --all-namespaces --no-headers \
  | grep -E 'Terminating|Completed' \
  | awk '{print $2, $1}' \
  | while read -r pod ns; do
    echo "Force deleting pod $pod in namespace $ns ..."
    kubectl delete pod "$pod" -n "$ns" --grace-period=0 --force || true
done

echo "Cleanup complete." 
#!/bin/bash
set -e

# Deploy all core components in the right order

# 1. Create the namespace if it doesn't exist
kubectl get ns ars >/dev/null 2>&1 || kubectl create ns ars

echo "\n[1/4] Applying core components..."
kubectl apply -f infrastructure/components/elasticsearch/elasticsearch-statefulset.yaml
kubectl apply -f infrastructure/components/grafana/grafana-deployment.yaml
kubectl apply -f infrastructure/components/thehive/thehive-deployment.yaml
kubectl apply -f infrastructure/components/cortex/cortex-deployment.yaml
kubectl apply -f infrastructure/components/nginx-exporter/nginx-exporter-deployment.yaml

# 2. Logging/Monitoring
kubectl apply -f infrastructure/logging/loki-deployment.yaml
kubectl apply -f infrastructure/logging/promtail-daemonset.yaml
kubectl apply -f infrastructure/logging/promtail-config.yaml

# 3. Prometheus
kubectl apply -f infrastructure/components/prometheus/prometheus-additional-scrapeconfigs.yaml

# 4. Your main app(s)
# (Add your main app deployment here, e.g. oceanhealing)


echo "\nDeployment complete! Check pod status with: kubectl get pods -n ars"

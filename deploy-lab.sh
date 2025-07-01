#!/bin/bash
set -e

# Build and load frontend image for Minikube
# (Required so the frontend pod can pull the latest image)
echo "[0/4] Building and loading frontend Docker image..."
docker build -t ars-frontend:latest -f docker/frontend.Dockerfile .
minikube image load ars-frontend:latest

# Deploy all core components in the right order

# 1. Create the namespace if it doesn't exist
kubectl get ns ars >/dev/null 2>&1 || kubectl create ns ars

echo "\n[1/4] Applying all manifests via Kustomize..."
kubectl apply -k infrastructure/overlays/dev

echo "\nDeployment complete! Check pod status with: kubectl get pods -n ars"

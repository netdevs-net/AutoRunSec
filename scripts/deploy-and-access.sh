#!/bin/bash

# Deploy and Access Script for ARS Infrastructure
# This script deploys the infrastructure and automatically sets up access

set -e

echo "🚀 ARS Infrastructure Deployment & Access"
echo "========================================"

# Step 1: Build and deploy
echo "\n[1/3] Building and deploying infrastructure..."
./deploy-lab.sh

# Step 2: Start port-forwarding for all services
echo "\n[2/3] Setting up access to all services..."
./scripts/port-forward-all.sh

echo "\n🎉 Everything is ready!"
echo "✅ Infrastructure deployed"
echo "✅ Port-forwarding active"
echo "🌐 Access your frontend: http://localhost:8081"
echo ""
echo "💡 To stop everything:"
echo "   pkill -f 'kubectl port-forward.*8081'"
echo "   kubectl delete -k infrastructure/overlays/dev" 
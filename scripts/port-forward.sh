#!/bin/bash

# Port forwarding script for ARS frontend
# This script automatically sets up port-forwarding for the frontend service

NAMESPACE="ars"
SERVICE="frontend-dev"
LOCAL_PORT="8081"
REMOTE_PORT="80"

echo "🚀 Setting up port-forwarding for ARS frontend..."
echo "📡 Service: $SERVICE"
echo "🌐 Local port: $LOCAL_PORT"
echo "🔗 Remote port: $REMOTE_PORT"
echo ""

# Check if the service exists
if ! kubectl get service $SERVICE -n $NAMESPACE >/dev/null 2>&1; then
    echo "❌ Error: Service $SERVICE not found in namespace $NAMESPACE"
    echo "💡 Make sure you've deployed the infrastructure with: kubectl apply -k infrastructure/overlays/dev"
    exit 1
fi

# Check if port is already in use
if lsof -Pi :$LOCAL_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Port $LOCAL_PORT is already in use. Stopping existing port-forward..."
    pkill -f "kubectl port-forward.*$LOCAL_PORT" || true
    sleep 2
fi

echo "✅ Starting port-forward..."
echo "🌍 Access your frontend at: http://localhost:$LOCAL_PORT"
echo "🛑 Press Ctrl+C to stop"
echo ""

# Start port-forwarding
kubectl port-forward service/$SERVICE $LOCAL_PORT:$REMOTE_PORT -n $NAMESPACE 
#!/bin/bash

# Port forwarding script for all ARS services
# This script sets up port-forwarding for all services mentioned in the frontend

NAMESPACE="ars"

echo "🚀 Setting up port-forwarding for all ARS services..."
echo "=================================================="

# Function to start port-forwarding for a service
start_port_forward() {
    local service_name=$1
    local local_port=$2
    local remote_port=$3
    local description=$4
    
    echo "📡 Setting up $description..."
    
    # Check if port is already in use
    if lsof -Pi :$local_port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "⚠️  Port $local_port is already in use. Stopping existing port-forward..."
        pkill -f "kubectl port-forward.*$local_port" || true
        sleep 1
    fi
    
    # Check if service exists (try ars namespace first, then monitoring)
    if kubectl get service $service_name -n $NAMESPACE >/dev/null 2>&1; then
        # Start port-forwarding in background
        kubectl port-forward service/$service_name $local_port:$remote_port -n $NAMESPACE >/dev/null 2>&1 &
        echo "✅ $description: http://localhost:$local_port"
    elif kubectl get service $service_name -n monitoring >/dev/null 2>&1; then
        # Start port-forwarding in background (monitoring namespace)
        kubectl port-forward service/$service_name $local_port:$remote_port -n monitoring >/dev/null 2>&1 &
        echo "✅ $description: http://localhost:$local_port (monitoring namespace)"
    else
        echo "❌ Service $service_name not found in ars or monitoring namespace"
    fi
}

# Start all services
start_port_forward "prometheus" "9090" "9090" "Prometheus"
start_port_forward "grafana" "3000" "3000" "Grafana"
start_port_forward "loki" "3100" "3100" "Loki API"
start_port_forward "tempo" "3200" "3200" "Tempo"
start_port_forward "oceanhealing-dev" "5543" "5543" "Ocean Healing"

echo ""
echo "🎉 All services are now accessible!"
echo ""
echo "📊 Observability:"
echo "   Prometheus: http://localhost:9090"
echo "   Grafana: http://localhost:3000"
echo "   Loki API: http://localhost:3100"
echo "   Tempo: http://localhost:3200"
echo ""
echo "🌊 Applications:"
echo "   Ocean Healing: http://localhost:5543"
echo ""
echo "🛑 To stop all port-forwarding:"
echo "   pkill -f 'kubectl port-forward'"
echo ""
echo "💡 The frontend links should now work!" 
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
    
    # Check if service exists
    if kubectl get service $service_name -n $NAMESPACE >/dev/null 2>&1; then
        # Start port-forwarding in background
        kubectl port-forward service/$service_name $local_port:$remote_port -n $NAMESPACE >/dev/null 2>&1 &
        echo "✅ $description: http://localhost:$local_port"
    else
        echo "❌ Service $service_name not found"
    fi
}

# Start all services
start_port_forward "ars-prometheus-dev" "9090" "9090" "Prometheus"
start_port_forward "grafana" "3000" "3000" "Grafana"
start_port_forward "ars-minio-dev" "9001" "9001" "MinIO Console"
start_port_forward "elasticsearch" "9200" "9200" "Elasticsearch"
start_port_forward "thehive" "9005" "9000" "TheHive"
start_port_forward "cortex" "9006" "9001" "Cortex"
start_port_forward "ars-falco-dev" "2801" "8765" "Falco"
start_port_forward "ars-redis-dev" "6379" "6379" "Redis"
start_port_forward "loki" "3100" "3100" "Loki API"
start_port_forward "oceanhealing-dev" "5543" "5543" "Ocean Healing"
start_port_forward "ars-nginx-exporter-dev" "9113" "9113" "Nginx Exporter"
start_port_forward "ars-promtail-dev" "9080" "9080" "Promtail"

echo ""
echo "🎉 All services are now accessible!"
echo ""
echo "📊 Observability:"
echo "   Prometheus: http://localhost:9090"
echo "   Grafana: http://localhost:3000"
echo "   MinIO Console: http://localhost:9001"
echo "   Elasticsearch: http://localhost:9200"
echo ""
echo "🔒 Security:"
echo "   TheHive: http://localhost:9005"
echo "   Cortex: http://localhost:9006"
echo "   Falco: http://localhost:2801"
echo ""
echo "🗄️ Data Sources:"
echo "   Redis: http://localhost:6379"
echo "   Loki API: http://localhost:3100"
echo "   Ocean Healing: http://localhost:5543"
echo "   Nginx Exporter: http://localhost:9113"
echo "   Promtail: http://localhost:9080"
echo ""
echo "🛑 To stop all port-forwarding:"
echo "   pkill -f 'kubectl port-forward'"
echo ""
echo "💡 The frontend links should now work!" 
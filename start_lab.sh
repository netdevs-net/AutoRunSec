#!/bin/bash

show_help() {
    echo "Usage: $0 [--compose] [--k8s] [--help]"
    echo "  lab using Docker(default)"
    echo "  --k8s      lab using MicroK8s-in-Docker (advanced)"
    echo "  --help      Show this help message"
}

MODE="compose"

for arg in "$@"; do
  case "$arg" in
    --compose)
      MODE="compose";;
    --k8s)
      MODE="k8s";;
    -h|--help)
      show_help; exit 0;;
    *)
      echo "Unknown argument: $arg"; show_help; exit 1;;
  esac
done

if [[ "$MODE" == "compose" ]]; then
  echo "🛠️  Bootstrapping lab environment with Docker Compose..."
  if ! command -v docker-compose &> /dev/null; then
      echo "❌ docker-compose not found. Please install Docker Compose."
      exit 1
  fi
  docker-compose pull
  docker compose -f frontend.yml up -d
  sleep 5
  echo "✅ LAB BOOTSTRAP COMPLETE"
  echo ""
  echo "Observability:"
  echo "- 📊 Prometheus:           http://localhost:9090"
  echo "- 📈 Grafana:              http://localhost:3000 (admin / admin123)"
  echo "- 🛢️  MinIO Console:        http://localhost:9001   (admin / admin123)"
  echo "- 🗄️  Elasticsearch:        http://localhost:9200"

  echo ""
  echo "Automated Response Security:"
  echo "- 🐝 TheHive:              http://localhost:9005"
  echo "- 🧠 Cortex:               http://localhost:9006"

  echo ""
  echo "Data Sources"
  echo "- 🦅 Falco:                http://localhost:2801"
  echo "- 🟥 Redis:                http://localhost:6379"
  echo "- 🚦 Nginx Exporter:       http://localhost:9113/metrics"
  echo "- 🔎 Nginx status:         http://localhost:5543/stub_status"
  echo "- 📜 Loki API:             http://localhost:3100"
  echo ""
  echo "- 🚪 ARS Entry Page:       http://localhost:8080/"
  echo ""
  echo "Tip: Copy/paste these URLs into your browser."
  
fi

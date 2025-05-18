#!/bin/bash

show_help() {
    echo "Usage: $0 [--compose] [--k8s] [--help]"
    echo "  --compose   Start lab using Docker Compose (default)"
    echo "  --k8s       Start lab using MicroK8s-in-Docker (advanced)"
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
  docker-compose up -d
  sleep 5
  echo "✅ LAB BOOTSTRAP COMPLETE"
  echo ""
  echo "Access your lab services at these URLs:"
  echo "- 🏥 OceanHealing App:      http://localhost:5543"
  echo "- 📊 Prometheus:           http://localhost:9090"
  echo "- 📈 Grafana:              http://localhost:3000 (admin / admin123)"
  echo "- 🚦 Nginx Exporter:        http://localhost:9113/metrics"
  echo "- 🛢️  MinIO Console:        http://localhost:9001   (admin / admin123)"
  echo "- 📜 Loki API:              http://localhost:3100"
  echo "- 🐝 TheHive:               http://localhost:9005"
  echo "- 🧠 Cortex:                http://localhost:9006"
  echo "- 🛠️  AWX:                   http://localhost:8043 (admin / password)"
  echo ""
  echo "🔎 Nginx status:           http://localhost:5543/stub_status"
  echo ""
  echo "Tip: Copy/paste these URLs into your browser."

  # Check AWX container status
  AWX_STATUS=$(docker ps --filter 'name=awx' --format '{{.Status}}')
  if [[ -z "$AWX_STATUS" ]]; then
    echo "⚠️  AWX container is not running. Showing last 20 lines of logs for troubleshooting:"
    docker logs --tail 20 awx || echo "No logs found for AWX."
  else
    echo "✅ AWX container status: $AWX_STATUS"
  fi
}]}},{

elif [[ "$MODE" == "k8s" ]]; then
  echo "🛠️  Bootstrapping advanced lab with MicroK8s-in-Docker..."
  echo "This will launch a privileged Ubuntu 22.04 container, install MicroK8s, and prepare for K8s workloads."
  echo "NOTE: This is experimental and requires a host with virtualization support and at least 16GB RAM."
  echo ""
  docker run -it --privileged --network=host --hostname=lab-k8s \
    -v /var/lib/microk8s:/var/lib/microk8s \
    -v /var/lib/containerd:/var/lib/containerd \
    -v /opt/lab-data:/opt/lab-data \
    ubuntu:22.04 /bin/bash -c '
      set -e;
      export DEBIAN_FRONTEND=noninteractive;
      apt-get update && apt-get install -y sudo curl snapd lsb-release;
      snap install microk8s --classic --channel=1.28/stable;
      usermod -a -G microk8s root;
      export PATH=$PATH:/snap/bin;
      microk8s status --wait-ready;
      microk8s enable dns storage ingress prometheus;
      echo "MicroK8s is ready. You can now deploy workloads using microk8s kubectl.";
      bash'
  echo "✅ MicroK8s-in-Docker environment started. Attach to the container to deploy workloads."
else
  show_help; exit 1
fi

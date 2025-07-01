#!/bin/bash
# start_lab_k8s.sh
# Deploys each service from docker-compose.yml as a Kubernetes Deployment and Service in Minikube

set -e

NAMESPACE="ars-lab"

# Create namespace if not exists
echo "[INFO] Creating namespace $NAMESPACE (if not exists)"
kubectl get namespace $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

# Function to deploy a service as a Deployment and Service
deploy_service() {
  local name="$1"
  local image="$2"
  local port="$3"
  local container_port="$4"
  local extra_args="$5"

  echo "[INFO] Deploying $name..."

  # Create Deployment YAML
  cat <<EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $name
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $name
  template:
    metadata:
      labels:
        app: $name
    spec:
      containers:
      - name: $name
        image: $image
        ports:
        - containerPort: $container_port
$extra_args
EOF

  # Create Service YAML
  cat <<EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: v1
kind: Service
metadata:
  name: $name
spec:
  selector:
    app: $name
  ports:
  - protocol: TCP
    port: $port
    targetPort: $container_port
  type: NodePort
EOF
}

# Deploy Redis
deploy_service "redis" "redis:alpine" 6379 6379 ""

# Deploy Falco (with privileged and volume mounts)
deploy_service "falco" "falcosecurity/falco:latest" 8765 8765 "        securityContext:\n          privileged: true\n        volumeMounts:\n        - name: dev\n          mountPath: /host/dev\n        - name: proc\n          mountPath: /host/proc:ro\n        - name: modules\n          mountPath: /host/lib/modules:ro\n        - name: usr\n          mountPath: /host/usr:ro\n        - name: docker-sock\n          mountPath: /host/var/run/docker.sock\n      volumes:\n      - name: dev\n        hostPath:\n          path: /dev\n      - name: proc\n        hostPath:\n          path: /proc\n      - name: modules\n        hostPath:\n          path: /lib/modules\n      - name: usr\n        hostPath:\n          path: /usr\n      - name: docker-sock\n        hostPath:\n          path: /var/run/docker.sock\n"

# Deploy MinIO
deploy_service "minio" "minio/minio" 9001 9001 "        env:\n        - name: MINIO_ROOT_USER\n          value: \"admin\"\n        - name: MINIO_ROOT_PASSWORD\n          value: \"admin123\"\n        args: [\"server\", \"/data\", \"--console-address\", \":9001\"]\n        volumeMounts:\n        - name: minio-data\n          mountPath: /data\n      volumes:\n      - name: minio-data\n        emptyDir: {}\n"

# Add more deploy_service calls below for other services from docker-compose.yml as needed
# Example: deploy_service "service-name" "image:tag" <service-port> <container-port> "<extra-yaml>"

# Print status
echo "[INFO] All deployments submitted. Run 'kubectl get all -n $NAMESPACE' to check status."

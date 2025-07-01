# ARS Kubernetes Cluster Infrastructure

This repository defines the full infrastructure for the ARS (Automated Response Security) platform, focusing on a robust, observable, and secure microservices stack running on Kubernetes. All manifests, overlays, and scripts are located in the `infrastructure/` directory.

---

## Architecture Overview

- **Kubernetes**: The core orchestration platform, supporting scalable, resilient deployments.
- **Observability Stack**: Includes Prometheus (metrics), Loki (logs), and Grafana (dashboards).
- **Supporting Services**: MinIO (object storage), Redis (cache/message broker), Falco (security monitoring), and more.
- **App Pod**: The main application, `oceanhealing-dev`, is instrumented for observability and security.

---

## Historical Note: Docker Compose Lab

This system was originally built and tested using Docker Compose, running 10+ containers for all services. The `start_lab.sh` script can still be used to spin up the entire stack locally with Docker Compose, making development and rapid iteration easy before Kubernetes adoption.

- **Legacy Docker Compose**: Useful for local dev, CI, and quick prototyping.
- **Transition to Kubernetes**: All services were ported to Kubernetes using Kustomize, with overlays for dev/prod and a focus on infrastructure-as-code best practices.

---

## Services and Their Roles

### 1. **oceanhealing-dev (App Pod)**
- The main application container (React/Node.js).
- Exposes health endpoints and metrics for scraping.
- All observability and security tools are designed to monitor this pod.

### 2. **Prometheus**
- Collects and stores time-series metrics from the app pod and cluster components.
- Scrapes `/metrics` endpoints, tracks CPU, memory, HTTP requests, etc.
- Essential for alerting, SLOs, and performance analysis.

### 3. **Loki**
- Aggregates logs from all pods (including oceanhealing-dev) via Promtail or other log shippers.
- Enables fast, label-based log queries and correlation with metrics in Grafana.
- Critical for debugging and root-cause analysis.

### 4. **Grafana**
- Visualization layer for both metrics (Prometheus) and logs (Loki).
- Provides dashboards, alerts, and a unified observability experience.

### 5. **MinIO**
- S3-compatible object storage, used for:
  - Storing app uploads, backups, and artifacts.
  - (Optionally) long-term metrics/logs storage with Thanos, Velero, or other tools.
- Highly available and cloud-native.

### 6. **Redis**
- In-memory cache and message broker.
- Used for session storage, queueing, and accelerating app performance.

### 7. **Falco**
- Real-time runtime security monitoring.
- Detects suspicious behavior, file access, and container anomalies.
- Sends alerts to the security stack or external SIEMs.

### 8. **Other Infrastructure**
- **Network Policies**: Secure pod-to-pod communication.
- **RBAC**: Fine-grained access control for all services.
- **Secrets Management**: Secure storage of sensitive data (see `infrastructure/overlays/dev/kustomization.yaml` for secret generators).

---

## Directory Structure

- `infrastructure/base/` — Core manifests for all services.
- `infrastructure/monitoring/` — Canonical source for observability stack manifests.
- `infrastructure/overlays/dev/` — Development-specific overlays and patches.
- `infrastructure/components/` — Modular service definitions.
- `start_lab.sh` — Legacy Docker Compose bootstrap script.
- `start_lab_k8s.sh` — Script for deploying the stack to Minikube or other local clusters.

---

## How to Use

### **Local Dev (Docker Compose)**
```sh
./start_lab.sh
```
- Brings up all services in Docker Compose for rapid iteration.

### **Kubernetes (Minikube or Cloud)**
```sh
kubectl apply -k infrastructure/overlays/dev/
```
- Deploys the full stack to your Kubernetes cluster using Kustomize overlays.

---

## Observability Flow

- **Metrics**: App pod exposes metrics → Prometheus scrapes and stores → Grafana visualizes.
- **Logs**: App pod logs collected by Promtail → Loki stores and indexes → Grafana queries logs.
- **Security**: Falco monitors all pods and nodes for threats.
- **Storage**: MinIO provides persistent object storage for app and infra needs.

---

## Contributing & Extending
- Add new services as components or overlays.
- Use Kustomize patches for environment-specific config.
- All manifests are designed for clarity, security, and extensibility.

---

## Questions?
If you have questions about the stack, observability, or how to extend the cluster, open an issue or contact the maintainers.

deny[msg] {
  input.kind == "Deployment"
  not input.spec.selector.matchLabels.app

  msg := "Containers must provide app label for pod selectors"
}
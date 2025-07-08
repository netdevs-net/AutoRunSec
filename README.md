# ARS Kubernetes Cluster Infrastructure

This repository defines the full infrastructure for the ARS (Automated Response Security) platform, focusing on a robust, observable, and secure microservices stack running on Kubernetes. All manifests, overlays, and scripts are located in the `infrastructure/` directory.

---

## Architecture Overview

- **Kubernetes**: The core orchestration platform, supporting scalable, resilient deployments.
- **Observability Stack**: Includes Prometheus (metrics), Loki (logs), and Grafana (dashboards).
- **Security Monitoring**: Falco for real-time security monitoring and threat detection.
- **Supporting Services**: MinIO (object storage), Redis (cache/message broker), and more.
- **App Pod**: The main application, `oceanhealing-dev`, is instrumented for observability and security.

---

## Infrastructure Structure

### **Kustomize-Based Deployment**
The infrastructure uses Kustomize for declarative, environment-specific deployments:

```
infrastructure/
├── base/                    # Base manifests and common configurations
├── components/              # Modular service definitions
│   ├── nginx-exporter/     # Web server metrics collection
│   ├── promtail/          # Log aggregation and forwarding
│   └── ...                # Other components
├── security/               # Security monitoring stack
│   ├── falco-daemonset.yaml
│   ├── falco-config.yaml
│   └── falco_rules.yaml
├── overlays/               # Environment-specific configurations
│   ├── dev/               # Development environment
│   └── prod/              # Production environment
└── monitoring/             # Observability stack
```

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
- Aggregates logs from all pods (including oceanhealing-dev) via Promtail.
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
- **Note**: Requires kernel module access for full functionality (see deployment notes).

### 8. **Other Infrastructure**
- **Network Policies:** Secure pod-to-pod communication and restrict traffic based on namespace, label, or port.
- **RBAC:** Fine-grained access control for all services and users.
- **Secrets Management:** Secure storage and automated generation of sensitive data.
- **Ingress:** Configurable ingress controller for secure, external access to services.
- **Autoscaling:** Horizontal Pod Autoscalers (HPA) for dynamic scaling based on resource usage.
- **Backup & Restore:** PersistentVolumeClaims (PVC) for data, with documented backup/restore procedures.
- **Resource Validation:** Admission controllers and resource validators to enforce resource limits and best practices.
- **Security Scanning:** Automated secret scanning with gitleaks and `.gitignore` rules to prevent secret leakage.
- **Disaster Recovery:** Step-by-step cluster restore checklist and best practices for rapid recovery.

### 9. **Cortex**
- Automated analysis and response engine for security incidents.
- Integrates with TheHive to process observables and run analyzers.
- Scalable and API-driven, enabling automated enrichment and response workflows.

### 10. **TheHive**
- Open-source Security Incident Response Platform (SIRP).
- Manages cases, alerts, and investigations.
- Integrates with Cortex for automated analysis and with Elasticsearch for fast search.

### 11. **Elasticsearch**
- Distributed search and analytics engine.
- Stores and indexes security events, observables, and case data for TheHive.
- Enables fast, full-text search and analytics across security data.

---

## Deployment

### **Quick Start**
```bash
# Deploy base infrastructure
kubectl apply -k infrastructure/

# Deploy development environment
kubectl apply -k infrastructure/overlays/dev/

# Deploy production environment
kubectl apply -k infrastructure/overlays/prod/
```

### **Using Scripts**
```bash
# Deploy and access services
./scripts/deploy-and-access.sh

# Port forwarding utilities
./scripts/port-forward.sh
./scripts/port-forward-all.sh
```

### **Environment-Specific Deployment**
- **Development**: Uses overlays for local development with relaxed security policies
- **Production**: Enforces strict security policies and resource limits
- **Custom**: Create new overlays for specific environments

---

## Security Monitoring with Falco

### **Current Status**
- ✅ **Configuration**: Properly configured with container plugin and security rules
- ✅ **Deployment**: Kustomize-based deployment with proper resource management
- ❌ **Kernel Module**: Limited by containerized environment (Docker Desktop)

### **Environment Requirements**
- **Full Functionality**: Requires VM environment (Multipass, Vagrant) or bare metal
- **Containerized**: Limited to container metadata monitoring only
- **Production**: Consider host-level Falco installation for complete security monitoring

### **Alternative Approaches**
- Use VM-based Kubernetes cluster for full Falco functionality
- Consider alternative security monitoring tools for containerized environments
- Implement host-level security monitoring for production deployments

---

## Observability Flow

- **Metrics**: App pod exposes metrics → Prometheus scrapes and stores → Grafana visualizes.
- **Logs**: App pod logs collected by Promtail → Loki stores and indexes → Grafana queries logs.
- **Security**: Falco monitors all pods and nodes for threats (when kernel access available).
- **Storage**: MinIO provides persistent object storage for app and infra needs.

---

## Contributing & Extending

### **Adding New Services**
1. Create component directory in `infrastructure/components/`
2. Add kustomization.yaml for the component
3. Include in base kustomization or create environment-specific overlays

### **Environment-Specific Configurations**
- Use Kustomize patches for environment-specific settings
- Create new overlays for custom environments
- Maintain consistent labeling and resource management

### **Best Practices**
- All manifests are designed for clarity, security, and extensibility
- Use Kustomize for declarative, environment-specific deployments
- Maintain proper resource limits and security policies
- Document environment requirements and limitations

---

## Questions?
If you have questions about the stack, observability, or how to extend the cluster, open an issue or contact the maintainers.

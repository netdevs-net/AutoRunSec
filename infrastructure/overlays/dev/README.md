# Development Overlay

This overlay provides development-specific configurations for the ARS infrastructure.

## Quick Start

1. **Deploy the infrastructure:**
   ```bash
   kubectl apply -k infrastructure/overlays/dev
   ```

2. **Access all services:**
   ```bash
   # Option 1: Use the automated script (recommended)
   ./scripts/port-forward-all.sh
   
   # Option 2: Just the frontend
   ./scripts/port-forward.sh
   
   # Option 3: Manual port-forwarding
   kubectl port-forward service/frontend-dev 8081:80 -n ars
   ```

3. **Open your browser:**
   - Frontend: http://localhost:8081
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3000
   - MinIO Console: http://localhost:9001
   - Elasticsearch: http://localhost:9200
   - TheHive: http://localhost:9005
   - Cortex: http://localhost:9006
   - Falco: http://localhost:2801
   - Redis: http://localhost:6379
   - Loki API: http://localhost:3100
   - Ocean Healing: http://localhost:5543

## Services

- **Frontend**: Available on port 8081 via port-forwarding
- **MinIO**: Available on port 9001 via port-forwarding
- **Redis**: Available on port 6379 via port-forwarding
- **Prometheus**: Available on port 9090 via port-forwarding

## Development Features

- Single replica deployments for resource efficiency
- Debug logging enabled
- Development-specific environment variables
- Lower resource limits for local development 
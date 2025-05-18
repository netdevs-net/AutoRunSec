# Construction InfraSec Homelab Environment

This repository contains a secure, production-grade homelab environment managed with Docker Compose. It includes runtime security hardening using Falco for container behavior monitoring, and is ready for playbook integration with TheHive for automated incident response.

---

## 🚀 Services Overview

| Service           | URL                                 | Default Credentials     | Description |
|-------------------|-------------------------------------|------------------------|-------------|
| OceanHealing App  | http://localhost:5543               | N/A                    | Main application |
| Prometheus        | http://localhost:9090               | N/A                    | Metrics & monitoring |
| Grafana           | http://localhost:3000               | admin / admin123       | Dashboards & visualization |
| Nginx Exporter    | http://localhost:9113/metrics       | N/A                    | Nginx metrics exporter |
| MinIO Console     | http://localhost:9001               | admin / admin123       | S3-compatible storage |
| Loki API          | http://localhost:3100               | N/A                    | Log aggregation |
| TheHive           | http://localhost:9005               | N/A                    | Incident response platform |
| Cortex            | http://localhost:9006               | N/A                    | Automated analysis |
| AWX               | http://localhost:8043               | admin / password       | Ansible automation & orchestration |
| Falco             | N/A (logs to stdout/file)           | N/A                    | Container runtime security |

---

## 🔒 Security Hardening

### OceanHealing App (and recommended for all services)
- **No new privileges:** Prevents privilege escalation.
- **Seccomp profile:** Uses Docker's default syscall filter.
- **Capabilities dropped:** Drops all Linux capabilities.
- **Read-only filesystem:** Prevents writes except for explicitly mounted volumes.
- **Non-root user:** Runs as UID 1000 (ensure this user exists in your image).

### Falco: Runtime Behavior Analysis
- Monitors syscalls and container activity for suspicious behavior.
- Ships with a comprehensive default rule set.
- Can be extended with custom rules.

---

## 🛡️ Falco Quickstart & Tuning

1. **View Falco alerts:**
   ```bash
   docker logs falco
   ```
2. **Tune rules:**
   - Copy `/etc/falco/falco_rules.yaml` from the Falco container.
   - Edit/add rules as needed (see [Falco rule docs](https://falco.org/docs/rules/)).
   - Mount your custom rules file into the container:
     ```yaml
     volumes:
       - ./falco_rules.yaml:/etc/falco/falco_rules.local.yaml:ro
     ```

### Example: Allow benign DNS lookups
```yaml
- rule: Allow benign DNS
  desc: Allow DNS lookups by containers
  condition: evt.type in ("sendto") and fd.sip.name = "8.8.8.8"
  output: "Allowed DNS lookup (container=%container.name user=%user.name)"
  priority: INFO
  enabled: true
```

---

## 🔗 Integrating Falco with TheHive (Incident Response)

1. **Configure Falco Webhook Output:**
   - Add to `command:` in `docker-compose.yml` (or use env var):
     ```yaml
     command: >
       falco --cri /host/var/run/docker.sock --webhook-url http://thehive:9005/api/alert
     ```
   - Or use [Falcosidekick](https://github.com/falcosecurity/falcosidekick) for advanced integrations.

2. **Configure TheHive to receive alerts:**
   - See [TheHive API docs](https://docs.thehive-project.org/).
   - You may need to configure an API key and adjust the webhook payload.

---

## 📝 Operational Tips

- **Start the lab:**
  ```bash
  docker compose up -d
  ```
- **Stop the lab:**
  ```bash
  docker compose down
  ```
- **View Falco logs:**
  ```bash
  docker logs -f falco
  ```
- **Update Falco rules:**
  - Edit your custom rules file and restart the Falco container.

---

## 📂 Project Structure

- `docker-compose.yml` — Main Compose file, includes all services and security configuration.
- `README.md` — This documentation.
- `falco_rules.yaml` — (Optional) Custom Falco rules.

---

## 🛠️ Extending Security
- Apply similar security options to all containers.
- Use AppArmor/SELinux profiles for even finer control.
- Regularly review Falco and Docker logs for anomalies.
- Integrate with SIEM or alerting systems for production use.

---

## 📚 References
- [Falco Documentation](https://falco.org/docs/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [TheHive Project](https://thehive-project.org/)
- [Falcosidekick](https://github.com/falcosecurity/falcosidekick)

---

For questions or contributions, open an issue or PR.

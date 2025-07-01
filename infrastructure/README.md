# Build and Deploy Instructions

This guide explains how to build all container images, apply all Kubernetes manifests, and configure required environment variables and secrets to rapidly set up or restore this cluster. The namespace is `ars`.  

---

## 1. Build All Docker Images

All Dockerfiles are located in the `docker/` directory at the project root.

### Example: Build the Frontend Image
```sh
cd /Users/s3/Sites/ARS
# Build frontend image
docker build -t ars-frontend:latest -f docker/frontend.Dockerfile .
```

Repeat this process for any other images (replace Dockerfile and image name as needed):
```sh
docker build -t <image-name>:<tag> -f docker/<Dockerfile> .
```

If you use a remote registry (optional):
```sh
docker tag ars-frontend:latest <your-registry>/ars-frontend:latest
docker push <your-registry>/ars-frontend:latest
```

---

## 2. Apply All Kubernetes Manifests

All manifests are organized under `infrastructure/components/` and managed with Kustomize overlays.

### Example: Apply all frontend manifests
```sh
kubectl apply -k infrastructure/components/frontend/
```

Repeat for other components as needed:
```sh
kubectl apply -k infrastructure/components/<component-name>/
```

If you use overlays (e.g., for dev or prod):
```sh
kubectl apply -k infrastructure/overlays/dev/
```

---

## 3. Environment Variables and Secrets

Some deployments may require environment variables or secrets. These are typically managed via Kubernetes `Secret` or `ConfigMap` resources.

- Check each deployment manifest for `env:` sections or references to `secretKeyRef` or `configMapKeyRef`.
- Create required secrets before applying manifests, for example:

```sh
kubectl create secret generic my-secret \
  --from-literal=MY_KEY=supersecretvalue \
  -n ars
```

- Create configmaps as needed:
```sh
kubectl create configmap my-config \
  --from-file=path/to/config/file \
  -n ars
```

- If using ingress with custom domains, add entries to your `/etc/hosts` file as needed (e.g. `frontend.local`).

### Additional Important Details

1. **Namespace Scoping**
   - Always specify the correct namespace (`-n ars`) when creating secrets or configmaps, and ensure your manifests reference the intended namespace. Secrets/configmaps are namespace-scoped and will not be visible to pods in other namespaces.

2. **Base64 Encoding for Secret Data in YAML**
   - If you define secrets directly in YAML manifests, the values must be base64-encoded. For example:
     ```yaml
     apiVersion: v1
     kind: Secret
     metadata:
       name: my-secret
       namespace: ars
     type: Opaque
     data:
       MY_KEY: BASE64_ENCODED_EXAMPLE_VALUE  # example only, do not use real secrets in git
     ```
     Use `echo -n 'supersecretvalue' | base64` to generate these values.

3. **Referencing Secrets/ConfigMaps in Deployments**
   - Ensure your deployments reference secrets and configmaps using `envFrom`, `env`, `secretKeyRef`, or `configMapKeyRef`. Example:
     ```yaml
     env:
       - name: MY_KEY
         valueFrom:
           secretKeyRef:
             name: my-secret
             key: MY_KEY
     ```

4. **Updating Secrets and Rolling Deployments**
   - If you update a secret or configmap, your pods will not automatically reload the new values unless you trigger a rollout. Use:
     ```sh
     kubectl rollout restart deployment <deployment-name> -n ars
     ```
     to force pods to restart and pick up new secret/configmap values.

5. **Storing and Managing Secrets Securely**
   - Avoid hardcoding secrets in git or plaintext YAML files.
   - Use tools like [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets), [HashiCorp Vault](https://www.vaultproject.io/), or your cloud provider’s secret manager for production.
   - For local/dev, ensure `.gitignore` includes any files with sensitive data.

---

## 4. Persistent Data (Stateful Services)

If you use persistent services (e.g., MinIO, databases), make sure to:
- Backup and restore data using the service's backup tools (e.g., MinIO `mc` client).
- PersistentVolumeClaims are defined in manifests, but actual data must be backed up separately.

---

## 5. Cluster Restore Checklist

1. Build and push all required images.
2. Create all required secrets and configmaps.
3. Apply all manifests with `kubectl apply -k ...` for each component or overlay.
4. Restore persistent data if needed.
5. Verify all pods and services are running:
   ```sh
   kubectl get pods -A
   kubectl get svc -A
   kubectl get ingress -A
   ```
6. Access services via ingress or port-forward as documented.

---

**For more details, see individual component READMEs or deployment manifests.**

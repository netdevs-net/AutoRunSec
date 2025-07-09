#!/bin/bash

# Script to create GHCR secret for Kubernetes
# Usage: ./scripts/create-ghcr-secret.sh

set -e

echo "🔐 Creating GHCR Secret for Kubernetes"
echo "======================================"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Prompt for GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ GitHub username cannot be empty"
    exit 1
fi

# Prompt for Personal Access Token
echo ""
echo "📝 You need a GitHub Personal Access Token with 'read:packages' permission"
echo "   Create one at: https://github.com/settings/tokens"
echo ""
read -s -p "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Personal Access Token cannot be empty"
    exit 1
fi

# Create the Docker config JSON
DOCKER_CONFIG_JSON=$(echo -n "{\"auths\":{\"ghcr.io\":{\"auth\":\"$(echo -n "${GITHUB_USERNAME}:${GITHUB_TOKEN}" | base64)\"}}}")

# Base64 encode the entire config
BASE64_CONFIG=$(echo -n "$DOCKER_CONFIG_JSON" | base64)

echo ""
echo "✅ Generated base64 encoded Docker config"
echo ""

# Create the secret YAML
cat > infrastructure/overlays/dev/ghcr-creds-dev.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: ghcr-creds-dev
  namespace: ars
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ${BASE64_CONFIG}
EOF

echo "📄 Created secret file: infrastructure/overlays/dev/ghcr-creds-dev.yaml"
echo ""

# Apply the secret
echo "🚀 Applying secret to Kubernetes..."
kubectl apply -f infrastructure/overlays/dev/ghcr-creds-dev.yaml

echo ""
echo "✅ Secret 'ghcr-creds-dev' created in namespace 'ars'"
echo ""
echo "🔍 Verifying secret..."
kubectl get secret ghcr-creds-dev -n ars

echo ""
echo "🎉 Done! The secret is now available for your OceanHealing pods." 
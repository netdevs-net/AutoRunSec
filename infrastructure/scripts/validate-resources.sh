#!/bin/bash

# Validate resource requirements
validate_resources() {
  local resources="$1"
  
  # Check CPU requests don't exceed limits
  echo "$resources" | jq -r 'select(.kind == "Deployment") | .spec.template.spec.containers[] | select(.resources.requests.cpu > .resources.limits.cpu) | .name' | while read -r container; do
    echo "ERROR: Container $container has CPU request > limit"
    exit 1
  done
  
  # Check memory requests don't exceed limits
  echo "$resources" | jq -r 'select(.kind == "Deployment") | .spec.template.spec.containers[] | select(.resources.requests.memory > .resources.limits.memory) | .name' | while read -r container; do
    echo "ERROR: Container $container has memory request > limit"
    exit 1
  done
}

# Check rollout status
check_rollout() {
  local resources="$1"
  
  echo "$resources" | kubectl apply -f - --dry-run=server
  
  # Get deployments
  local deployments=$(echo "$resources" | jq -r 'select(.kind == "Deployment") | .metadata.name')
  
  for deploy in $deployments; do
    echo "Verifying rollout status for $deploy"
    kubectl rollout status deployment/$deploy --timeout=60s || exit 1
  done
}

# Main execution
resources=$(kustomize build "$1" | kubectl apply -f - --dry-run=client -o json)

validate_resources "$resources"
check_rollout "$resources"

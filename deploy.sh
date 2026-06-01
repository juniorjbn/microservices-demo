#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="onlineboutique"
CHART="oci://registry-1.docker.io/juniorjbn/onlineboutique"
REGISTRY="juniorjbn"
TAG="v1.0.0"

echo "══════════════════════════════════════════════════"
echo "  Online Boutique — Deploy via Helm"
echo "  Chart:   ${CHART}"
echo "  Images:  ${REGISTRY}/*:${TAG}"
echo "  Cluster: $(kubectl config current-context 2>/dev/null || echo '?')"
echo "══════════════════════════════════════════════════"
echo ""

# Create namespace if it doesn't exist
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install onlineboutique "${CHART}" \
  --namespace "${NAMESPACE}" \
  --set images.repository="${REGISTRY}" \
  --set images.tag="${TAG}" \
  --set cartDatabase.inClusterRedis.create=true \
  --set cartDatabase.inClusterRedis.publicRepository=true \
  --set frontend.externalService=false

echo ""
echo "══════════════════════════════════════════════════"
echo "  Deploy complete!"
echo ""
echo "  Watch pods:"
echo "    kubectl get pods -n ${NAMESPACE} -w"
echo ""
echo "  Port-forward (Kind não tem LoadBalancer):"
echo "    kubectl port-forward -n ${NAMESPACE} svc/frontend 8080:80"
echo "    → http://localhost:8080"
echo "══════════════════════════════════════════════════"

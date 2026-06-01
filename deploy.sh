#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="onlineboutique"
CHART="./helm-chart"
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
  --wait \
  --timeout 15m

echo ""
echo "══════════════════════════════════════════════════"
echo "  Deploy complete!"
echo ""
echo "  Watch pods:"
echo "    kubectl get pods -n ${NAMESPACE} -w"
echo ""
echo "  Get frontend address:"
echo "    kubectl get svc -n ${NAMESPACE} frontend-external"
echo ""
echo "  Port-forward (if no LB):"
echo "    kubectl port-forward -n ${NAMESPACE} svc/frontend-external 8080:80"
echo "    → http://localhost:8080"
echo "══════════════════════════════════════════════════"

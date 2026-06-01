#!/usr/bin/env bash
set -euo pipefail

REGISTRY="juniorjbn"
CHART="helm-chart/"

echo "══════════════════════════════════════════════════"
echo "  Publish Helm Chart → Docker Hub (OCI)"
echo "  Registry: oci://registry-1.docker.io/${REGISTRY}"
echo "══════════════════════════════════════════════════"
echo ""

# Ensure logged in — try Docker Desktop creds first, fall back to interactive
if docker-credential-desktop get <<< "https://index.docker.io/v1/" &>/dev/null; then
  DOCKER_PASSWORD=$(docker-credential-desktop get <<< "https://index.docker.io/v1/" | python3 -c "import sys,json; print(json.load(sys.stdin)['Secret'])")
  echo "$DOCKER_PASSWORD" | helm registry login registry-1.docker.io --username "${REGISTRY}" --password-stdin &>/dev/null && echo "Logged in via Docker Desktop credentials."
elif ! helm registry login registry-1.docker.io --username "${REGISTRY}" 2>/dev/null; then
  echo "Please login to Docker Hub interactively:"
  helm registry login registry-1.docker.io --username "${REGISTRY}"
fi

echo ""
echo "Packaging chart..."
PACKAGE="$(helm package "${CHART}" 2>&1 | tail -1)"
echo "${PACKAGE}"

CHART_TGZ="$(ls -t onlineboutique-*.tgz | head -1)"
echo ""
echo "Pushing ${CHART_TGZ} to Docker Hub..."
helm push "${CHART_TGZ}" "oci://registry-1.docker.io/${REGISTRY}"

echo ""
echo "Cleaning up..."
rm "${CHART_TGZ}"

echo ""
echo "══════════════════════════════════════════════════"
echo "  Published:"
echo "    oci://registry-1.docker.io/${REGISTRY}/onlineboutique"
echo "══════════════════════════════════════════════════"

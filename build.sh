#!/usr/bin/env bash
set -euo pipefail

REGISTRY="juniorjbn"
TAG="v1.0.0"
PLATFORM="linux/amd64"

build_and_push() {
  local name="$1"
  local context="$2"
  local img="${REGISTRY}/${name}:${TAG}"

  echo ""
  echo "══════════════════════════════════════════════════"
  echo "  Building: ${name}"
  echo "  Context:  ${context}"
  echo "  Image:    ${img}"
  echo "══════════════════════════════════════════════════"

  docker buildx build \
    --platform="${PLATFORM}" \
    --load \
    -t "${img}" \
    "${context}"

  echo "  ✓ Built:  ${img}"

  docker push "${img}"
  echo "  ✓ Pushed: ${img}"
  echo ""
}

echo "============================================"
echo "  Online Boutique — Build + Push"
echo "  Registry: ${REGISTRY}"
echo "  Tag:      ${TAG}"
echo "  Platform: ${PLATFORM}"
echo "============================================"
echo ""

# --- Wave 1: Go services (4) ---
echo "◆ Wave 1: Go services"
for svc in frontend:src/frontend checkoutservice:src/checkoutservice productcatalogservice:src/productcatalogservice shippingservice:src/shippingservice; do
  name="${svc%%:*}"
  ctx="${svc#*:}"
  build_and_push "${name}" "${ctx}" &
done
wait
echo "✓ Wave 1 complete"
echo ""

# --- Wave 2: Node + Python services (5) ---
echo "◆ Wave 2: Node + Python services"
for svc in currencyservice:src/currencyservice paymentservice:src/paymentservice emailservice:src/emailservice recommendationservice:src/recommendationservice loadgenerator:src/loadgenerator; do
  name="${svc%%:*}"
  ctx="${svc#*:}"
  build_and_push "${name}" "${ctx}" &
done
wait
echo "✓ Wave 2 complete"
echo ""

# --- Wave 3: Heavy services (C#, Java) ---
echo "◆ Wave 3: Heavy services (C#, Java)"
for svc in cartservice:src/cartservice/src adservice:src/adservice; do
  name="${svc%%:*}"
  ctx="${svc#*:}"
  build_and_push "${name}" "${ctx}" &
done
wait
echo "✓ Wave 3 complete"
echo ""

echo ""
echo "══════════════════════════════════════════════════"
echo "  All images built and pushed!"
echo ""
echo "  Registry: ${REGISTRY}"
echo "  Tag:      ${TAG}"
echo ""
echo "    ${REGISTRY}/frontend:${TAG}"
echo "    ${REGISTRY}/checkoutservice:${TAG}"
echo "    ${REGISTRY}/productcatalogservice:${TAG}"
echo "    ${REGISTRY}/shippingservice:${TAG}"
echo "    ${REGISTRY}/currencyservice:${TAG}"
echo "    ${REGISTRY}/paymentservice:${TAG}"
echo "    ${REGISTRY}/emailservice:${TAG}"
echo "    ${REGISTRY}/recommendationservice:${TAG}"
echo "    ${REGISTRY}/loadgenerator:${TAG}"
echo "    ${REGISTRY}/cartservice:${TAG}"
echo "    ${REGISTRY}/adservice:${TAG}"
echo ""
echo "  Also uses: redis:alpine (official image)"
echo "══════════════════════════════════════════════════"

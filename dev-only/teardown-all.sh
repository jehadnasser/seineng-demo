#!/bin/sh
#
# !!! For development only!!
#
# this script tears down the kind cluster and the local registry
#

set -eo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT/.."
REPO_ROOT="$(pwd)"
echo "Repo root: $REPO_ROOT"

source scripts/configs.sh

echo "!!!! WARNING: This will delete your cluster '${KIND_CLUSTER_NAME}' and the local registry '${REG_NAME}'."
read -p "Are you sure? (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "Aborting."
  exit 0
fi
docker rm -f "${REG_NAME}" 2>/dev/null || true
kind delete cluster --name "${KIND_CLUSTER_NAME}" 2>/dev/null || true

backend_image_id=$(docker images -q --filter=reference="localhost:5001/backend-app:*")
if [[ ! -z "$backend_image_id" ]]; then
  docker rmi -f $(docker images -q --filter=reference="localhost:5001/backend-app:*") || true
fi

frontend_image_id=$(docker images -q --filter=reference="localhost:5001/frontend-app:*")
if [[ ! -z "$frontend_image_id" ]]; then
  docker rmi -f $(docker images -q --filter=reference="localhost:5001/frontend-app:*") || true
fi

echo "Teardown complete!"
#
# This script builds Docker images for the backend and frontend, and pushes them to a local registry.
# It assumes that a local Docker registry is already running and accessible at localhost:<REG_PORT>
#

# for testing this script only, uncomment the following lines:
# #!/bin/sh
# set -eo pipefail
# reg_port=5001
# REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# REPO_ROOT="${REPO_ROOT}/.."
# cd "$REPO_ROOT"

echo "\n\nBuilding and publishing images to the local registry..."

local_reg="localhost:${reg_port}"
# backend app
backend_manifest_path="${ENV_PATH}/applications/guestbook-backend/src/backend/kubernetes-manifests"
backend_full_image_name="${local_reg}/${backend_img_name}:${backend_img_tag}"
backend_dockerfile_path="${ENV_PATH}/applications/guestbook-backend/src/backend/Dockerfile"
backend_context_path="${ENV_PATH}/applications/guestbook-backend/src/backend/"
# Frontend app
frontend_full_image_name="${local_reg}/${frontend_img_name}:${frontend_img_tag}"
frontend_dockerfile_path="${ENV_PATH}/applications/guestbook-frontend/src/frontend/Dockerfile"
frontend_context_path="${ENV_PATH}/applications/guestbook-frontend/src/frontend/"

# Backend app -----------------------------
##
# fail fast by checking if the local registry is reachable
if ! timeout 10s bash -c "until curl -fsS \"http://localhost:${reg_port}/v2/\" >/dev/null; do sleep 0.5; done"; then
  echo "Local registry is not reachable!" >&2
  exit 1
fi

# build the docker image
echo "Build docker image..."
DOCKER_BUILDKIT=1 docker build \
  -t "${backend_img_name}:${backend_img_tag}" \
  -f "$backend_dockerfile_path" \
  "$backend_context_path"

# check if the build was successful
if [ $? -ne 0 ]; then
    echo "Docker build failed!" >&2
    exit 1
fi

# scan the image for vulnerabilities
echo "Scanning image for vulnerabilities..."
trivy image \
  --quiet \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  "${backend_img_name}:${backend_img_tag}"  || true # do not fail, just log the vulns

# tagging the image
docker tag "${backend_img_name}:${backend_img_tag}" "${backend_full_image_name}"

# push the image to the registry
echo "Pushing image to the local registry..."
if ! timeout 30s docker push "${backend_full_image_name}"; then
  echo "!!Pushing to local registry failed!!" >&2
  exit 1
fi

# check if the image is pushed to the registry
response=$(curl -s "http://${local_reg}/v2/${backend_img_name}/tags/list")
if [ -n "$response" ]; then
  echo "$response"
  echo "Successfully built and pushed \"${backend_full_image_name}\""
else
  echo "Failed to build and push the image!!" >&2
  exit 1
fi


# Frontend app -----------------------------
##
# build the docker image
echo "Build docker image..."
DOCKER_BUILDKIT=1 docker build \
  -t "${frontend_img_name}:${frontend_img_tag}" \
  -f "$frontend_dockerfile_path" \
  "$frontend_context_path"

# scan the image for vulnerabilities
echo "Scanning image for vulnerabilities..."
trivy image \
  --quiet \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  "${frontend_img_name}:${frontend_img_tag}" || true

# tagging the image
docker tag "${frontend_img_name}:${frontend_img_tag}" "${frontend_full_image_name}"

# push the image to the registry
echo "Pushing image to the local registry..."
if ! timeout 30s docker push "${frontend_full_image_name}"; then
  echo "!!Pushing to local registry failed!!" >&2
  exit 1
fi

# check if the image is pushed to the registry
response=$(curl -s "http://${local_reg}/v2/${frontend_img_name}/tags/list")
if [ -n "$response" ]; then
  echo "$response"
  echo "Successfully built and pushed \"${frontend_full_image_name}\""
else
  echo "Failed to build and push the image!!" >&2
  exit 1
fi

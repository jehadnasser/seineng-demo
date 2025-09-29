#
# Deploy the workloads to the cluster
#
echo "\n\nDeploying workloads to the cluster..."
# for testing this script only, uncomment the following lines:
#!/bin/sh
# set -eo pipefail
# reg_port=5001
# REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# REPO_ROOT="${REPO_ROOT}/.."
# cd "$REPO_ROOT"
# reg_port=5001
# local_reg="localhost:${reg_port}"
# backend_img_name="backend-app"
# backend_img_tag="v0.0.2"
# frontend_img_name="frontend-app"
# frontend_img_tag="v0.0.3"

# manifest paths
backend_manifest_path="${ENV_PATH}/applications/guestbook-backend/src/backend/kubernetes-manifests"
backend_kustomization_path="${backend_manifest_path}/kustomization.yaml.tmpl"
frontend_manifest_path="${ENV_PATH}/applications/guestbook-frontend/src/frontend/kubernetes-manifests"
frontend_kustomization_path="${frontend_manifest_path}/kustomization.yaml.tmpl"

# apply the applications kustomization
kubectl apply -k "${ENV_PATH}"

# define images metadata for envsubst
export BACKEND_IMAGE_NAME="${local_reg}/${backend_img_name}"
export BACKEND_IMAGE_TAG="${backend_img_tag}"
export FRONTEND_IMAGE_NAME="${local_reg}/${frontend_img_name}"
export FRONTEND_IMAGE_TAG="${frontend_img_tag}"

# apply backend manifests
# Generate a temporary kustomization.yaml file with new image names and tags
cat "${backend_manifest_path}/kustomization.yaml.tmpl" | \
envsubst > "${backend_manifest_path}/kustomization.yaml"

echo "applying backend kustomization..."
# apply the kustomization
kubectl apply -k "${backend_manifest_path}"
# clean up the temporary kustomization.yaml file
rm "${backend_manifest_path}/kustomization.yaml"

# apply frontend manifests
# Generate a temporary kustomization.yaml file with new image names and tags
cat "${frontend_manifest_path}/kustomization.yaml.tmpl" | \
envsubst > "${frontend_manifest_path}/kustomization.yaml"

echo "applying frontend kustomization..."
# apply the kustomization
kubectl apply -k "${frontend_manifest_path}"
# clean up the temporary kustomization.yaml file
rm "${frontend_manifest_path}/kustomization.yaml"
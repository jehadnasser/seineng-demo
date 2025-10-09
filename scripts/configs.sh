#
# These are the configuration variables used by all scripts
#
# get the absolute path of the directory of this script

# set the environment (dev, staging, prod,...)
ENV="dev"
ENV_PATH="${REPO_ROOT}/clusters/${ENV}"

# load and export all env vars
set -a
source "${ENV_PATH}/secret.env" # re-source to export the variables
set +a

# local registry
REG_NAME='kind-registry'
REG_START_PORT_RANGE='5000'

# kind cluster
KIND_CLUSTER_NAME="cluster-infra-eng-task"
HELM_TIMEOUT="5m"
K8S_WAITING_TIMEOUT=600s

backend_img_name="backend-app"
backend_img_tag="v0.0.1"

frontend_img_name="frontend-app"
frontend_img_tag="v0.0.1"
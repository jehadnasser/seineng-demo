# # for testing this script only, uncomment the following lines:
# #!/bin/sh
# set -eo pipefail
# reg_port=5001
# REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# REPO_ROOT="${REPO_ROOT}/.."
# cd "$REPO_ROOT"
O11Y_PATH="${REPO_ROOT}/clusters/${ENV}/shared-k8s-services/observability"
MONITORING_PATH="${REPO_ROOT}/clusters/${ENV}/shared-k8s-services/observability/monitoring"
LOGGING_PATH="${REPO_ROOT}/clusters/${ENV}/shared-k8s-services/observability/logging"

# add helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

############################################
########### Monitoring stack  ##############
############################################
# Deploy the Monitoring stack to the cluster
echo "\n\nInstalling the Monitoring stack..."
# install prometheus and grafana helm charts

# create the namespaces
kubectl apply -f "${MONITORING_PATH}/namespaces.yaml"

# install kube-prometheus-stack
envsubst < "${MONITORING_PATH}/prometheus-stack/values.yaml" | \
helm upgrade --install kps prometheus-community/kube-prometheus-stack \
  --namespace "monitoring" \
  --values - \
  --wait --atomic --timeout ${HELM_TIMEOUT} >/dev/null 2>&1 || true

# helm upgrade --install kps prometheus-community/kube-prometheus-stack \
#   --namespace "monitoring" \
#   --values "${MONITORING_PATH}/prometheus-stack/values.yaml" \
#   --wait --atomic --timeout ${HELM_TIMEOUT} >/dev/null 2>&1 || true
echo "Prometheus, Grafana, and Alertmanager are installed!"


############################################
########### Logging stack  #################
############################################
echo "\n\nInstalling the logging stack..."

# Deploy the Logging stack to the cluster
# create the namespaces
kubectl apply -f "${LOGGING_PATH}/namespaces.yaml"

# install grafana-agent-operator
helm upgrade --install grafana-agent-operator grafana/grafana-agent-operator \
  --namespace "logging" \
  --wait --atomic --timeout ${HELM_TIMEOUT} >/dev/null 2>&1 || true
echo "Grafana Agent Operator is installed!"

# install Loki
helm upgrade --install loki grafana/loki \
  --namespace "logging" \
  --values "${LOGGING_PATH}/loki/values.yaml" \
  --wait --atomic --timeout ${HELM_TIMEOUT} >/dev/null 2>&1 || true
echo "Loki is installed!"

# install promtail
helm upgrade --install promtail grafana/promtail \
  --namespace logging \
  --values "${LOGGING_PATH}/promtail/values.yaml" \
  --wait --atomic --timeout ${HELM_TIMEOUT} >/dev/null 2>&1 || true
echo "Promtail is installed!"
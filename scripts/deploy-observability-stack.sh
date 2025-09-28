HELM_TIMEOUT="5m"

# # for testing this script only, uncomment the following lines:
# #!/bin/sh
# set -eo pipefail
# reg_port=5001
# REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# REPO_ROOT="${REPO_ROOT}/.."
# cd "$REPO_ROOT"

# create the namespaces
kubectl apply -f "${REPO_ROOT}/clusters/shared-k8s-services/observability/namespaces.yaml"

echo "\nDeploying the observability stack (Prometheus, Grafana, Loki, Promtail, Grafana OnCall)..."
# install prometheus and grafana helm charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

# install kube-prometheus-stack
helm upgrade --install kps prometheus-community/kube-prometheus-stack \
  --namespace "monitoring" \
  --values "${REPO_ROOT}/clusters/shared-k8s-services/observability/prometheus-stack/values.yaml" \
  --wait --atomic --timeout ${HELM_TIMEOUT} >/dev/null 2>&1 || true
echo "Prometheus, Grafana, and Alertmanager are installed!"

# install grafana-agent-operator
helm upgrade --install grafana-agent-operator grafana/grafana-agent-operator \
  --namespace "logging" \
  --wait --atomic --timeout ${HELM_TIMEOUT} >/dev/null 2>&1 || true
echo "Grafana Agent Operator is installed!"

# install Loki
helm upgrade --install loki grafana/loki \
  --namespace "logging" \
  --values "${REPO_ROOT}/clusters/shared-k8s-services/observability/loki/values.yaml" \
  --wait --atomic --timeout ${HELM_TIMEOUT} >/dev/null 2>&1 || true
echo "Loki is installed!"

# install promtail
helm upgrade --install promtail grafana/promtail \
  --namespace logging \
  --values "${REPO_ROOT}/clusters/shared-k8s-services/observability/promtail/values.yaml" \
  --wait --atomic --timeout ${HELM_TIMEOUT} >/dev/null 2>&1 || true
echo "Promtail is installed!"

# wait for grafana to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=600s
# forward the grafana port to localhost
kubectl port-forward --namespace monitoring svc/kps-grafana 3000:80 &
echo "Grafana: http://localhost:3000"

# apply custom prometheus rules
kubectl apply -f "${REPO_ROOT}/clusters/shared-k8s-services/observability/prometheus-stack/promrule-app-svc-uptime-critical-alerts.yaml"

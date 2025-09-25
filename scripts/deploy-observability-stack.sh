timeout="5m"

# create the namespaces
kubectl apply -f "${REPO_ROOT}/clusters/shared-k8s-services/observability/namespaces.yaml"

# install prometheus and grafana helm charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

# install kube-prometheus-stack
helm upgrade --install kps prometheus-community/kube-prometheus-stack \
  --namespace "monitoring" \
  --values "${REPO_ROOT}/clusters/shared-k8s-services/observability/prometheus-stack/values.yaml" \
  --wait --atomic --timeout "${timeout}" >/dev/null 2>&1 || true
echo "Prometheus and Grafana are installed!"

# install grafana-agent-operator
helm upgrade --install grafana-agent-operator grafana/grafana-agent-operator \
  --namespace "logging" \
  --wait --atomic --timeout "${timeout}" >/dev/null 2>&1 || true
echo "Grafana Agent Operator is installed!"

# install Loki
helm upgrade --install loki grafana/loki \
  --namespace "logging" \
  --values "${REPO_ROOT}/clusters/shared-k8s-services/observability/loki/values.yaml" \
  --wait --atomic --timeout "${timeout}" >/dev/null 2>&1 || true
echo "Loki is installed!"

# install promtail
helm upgrade --install promtail grafana/promtail \
  --namespace logging \
  --values "${REPO_ROOT}/clusters/shared-k8s-services/observability/promtail/values.yaml" \
  --wait --atomic --timeout "${timeout}" >/dev/null 2>&1 || true
echo "Promtail is installed!"

# forward the grafana port to localhost
grafana_pod_name=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=kps" -oname)
kubectl --namespace monitoring port-forward $grafana_pod_name 3000 &

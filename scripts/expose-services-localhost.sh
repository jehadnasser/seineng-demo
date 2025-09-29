# Dev Only: Expose services to localhost for easy access
# This script is intended for development environment only.
# It forwards the ports of services running in the cluster to localhost.

# wait for grafana to be ready
echo "\n\nExposing services to localhost..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout="${K8S_WAITING_TIMEOUT}"
grafana_port="$(get_free_port "3000")" || {
  echo "No free port found!" >&2
  exit 1
}
# forward the grafana port to localhost
kubectl port-forward --namespace monitoring svc/kps-grafana "${grafana_port}":80 &
echo "Grafana URL: http://localhost:${grafana_port}"

# wait for alertmanager to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=alertmanager -n monitoring --timeout="${K8S_WAITING_TIMEOUT}"
alertmanager_port="$(get_free_port "9093")" || {
  echo "No free port found!" >&2
  exit 1
}
# forward the alertmanager port to localhost
kubectl port-forward --namespace monitoring svc/alertmanager-operated "${alertmanager_port}":9093 &
echo "Alertmanager URL: http://localhost:${alertmanager_port}"

# wait for frontend to be ready
kubectl wait --for=condition=ready pod -l app=python-guestbook,tier=frontend -n default --timeout="${K8S_WAITING_TIMEOUT}"
# wait backend to be ready
kubectl wait --for=condition=ready pod -l app=python-guestbook,tier=backend -n default --timeout="${K8S_WAITING_TIMEOUT}"
# wait mongodb to be ready
kubectl wait --for=condition=ready pod -l app=python-guestbook,tier=db -n default --timeout="${K8S_WAITING_TIMEOUT}"

frontend_port="$(get_free_port "8080")" || {
  echo "No free port found!" >&2
  exit 1
}
# forward the frontend port to localhost
kubectl port-forward --namespace default svc/python-guestbook-frontend "${frontend_port}":80 &
echo "Frontend URL: http://localhost:${frontend_port}"

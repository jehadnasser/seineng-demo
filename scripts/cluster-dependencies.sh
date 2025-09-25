#
# This script sets up the dependencies for the cluster
#

### Setup Ingress
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/heads/main/deploy/static/provider/kind/deploy.yaml"

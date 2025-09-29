#
# This script sets up the dependencies for the cluster
#

echo "\n\nSetting up cluster dependencies..."

### Setup Ingress
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/heads/main/deploy/static/provider/kind/deploy.yaml"

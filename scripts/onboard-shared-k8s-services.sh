# Here we can onboard shared k8s services that are used across multiple environments
# e.g., observability stack, ingress controllers, cert managers, etc.

echo "\n\nOnboarding shared k8s services..."

source "$REPO_ROOT/scripts/install-observability-stack.sh"
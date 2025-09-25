#!/bin/sh
#
# https://kind.sigs.k8s.io/docs/user/local-registry/
set -eo pipefail

# get the absolute path of the directory of this script
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

# source "$REPO_ROOT/clusters/dev/.env"

# source the scripts
source "$REPO_ROOT/scripts/configs.sh"
source "$REPO_ROOT/scripts/functions.sh"

source "$REPO_ROOT/scripts/bootstrap-local-registry.sh"
source "$REPO_ROOT/scripts/bootstrap-kind-cluster.sh" # needs a running registry
source "$REPO_ROOT/scripts/cluster-dependencies.sh" # needs a running cluster

source "$REPO_ROOT/scripts/deploy-observability-stack.sh" # needs a running cluster
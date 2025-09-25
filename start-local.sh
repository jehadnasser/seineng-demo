#!/bin/sh
#
# https://kind.sigs.k8s.io/docs/user/local-registry/
set -eo pipefail

# get the absolute path of the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# source the scripts
source "$SCRIPT_DIR/scripts/configs.sh"
source "$SCRIPT_DIR/scripts/functions.sh"

source "$SCRIPT_DIR/scripts/bootstrap-local-registry.sh"
source "$SCRIPT_DIR/scripts/bootstrap-kind-cluster.sh" # needs a running registry
source "$SCRIPT_DIR/scripts/cluster-dependencies.sh" # needs a running cluster

#!/bin/sh
#
# this script tears down the kind cluster and the local registry
# for local development only!!
#
set -eo pipefail

# get REG_PORT as argument, otherwise ask for it
if [ -z "${1:-}" ]; then
  read -p "Enter registry port: " REG_PORT
else
  REG_PORT="$1"
fi

# test the local registry by pulling, tagging and pushing any random image, 
# then curl the registry for the image
docker pull busybox:latest >/dev/null 2>&1
docker tag busybox:latest localhost:${REG_PORT}/mybusybox:demo
if ! timeout 10s docker push localhost:${REG_PORT}/mybusybox:demo; then
  echo "!!Pushing to local registry failed!!" >&2
  exit 1
fi

# Check registry API
response=$(curl -s "http://localhost:${REG_PORT}/v2/mybusybox/tags/list")
if [ -n "$response" ]; then
  echo ":) Test passed:"
  echo "$response"
else
  echo "!!Local registry test failed!!" >&2
  exit 1
fi
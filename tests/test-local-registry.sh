#!/bin/sh
#
# this script tears down the kind cluster and the local registry
# for local development only!!
#
set -eo pipefail

# get IO_REG_PORT as argument, otherwise ask for it
if [ -z "${1:-}" ]; then
  read -p "Enter registry port: " IO_REG_PORT
else
  IO_REG_PORT="$1"
fi

if ! timeout 10s bash -c "until curl -fsS \"http://localhost:${IO_REG_PORT}/v2/\" >/dev/null; do sleep 0.5; done"; then
  echo "Local registry is not reachable!" >&2
  exit 1
fi

# test the local registry by pulling, tagging and pushing any random image, 
# then curl the registry for the image
docker pull busybox:latest >/dev/null 2>&1
docker tag busybox:latest localhost:${IO_REG_PORT}/mybusybox:demo

if ! timeout 10s docker push localhost:${IO_REG_PORT}/mybusybox:demo; then
  echo "!!Pushing to local registry failed!!" >&2
  exit 1
fi

# Check registry API
response=$(curl -s "http://localhost:${IO_REG_PORT}/v2/mybusybox/tags/list")
if [ -n "$response" ]; then
  echo ":) Test passed:"
  echo "$response"
  # Cleanup
  docker rmi busybox:latest >/dev/null 2>&1
  docker rmi localhost:${IO_REG_PORT}/mybusybox:demo >/dev/null 2>&1
else
  echo "!!Local registry test failed!!" >&2
  docker rmi busybox:latest >/dev/null 2>&1
  exit 1
fi
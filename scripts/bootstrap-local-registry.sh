#
# Bootstrap a local docker registry to be used with kind
#

# find a free port (default: $DEFAULT_REG_PORT)
reg_port="$(get_free_port "$REG_START_PORT_RANGE")" || {
  echo "No free port found!" >&2
  exit 1
}

# create registry container unless it already exists
if [ "$(docker inspect -f '{{.State.Running}}' "${REG_NAME}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${REG_NAME}" \
    registry:2
fi

echo "*** Local registry: http://localhost:${reg_port}"
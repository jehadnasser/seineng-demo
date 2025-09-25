#!/bin/sh


# Get a free port in the range START_PORT(arg)..end_port
# echo the first free port from START_PORT to stdout and returns 0
# returns 1 if no free port is found
# usage: get_free_port [START_PORT]
get_free_port() {
  local port="$1"
  local end_port=65535
  while [ "$port" -le "$end_port" ]; do
    # if nothing is using the $port echo it and exit
    if ! lsof -i :"$port" >/dev/null 2>&1; then
      echo "$port"
      return 0
    fi
    port=$((port+1))
  done
  return 1
}
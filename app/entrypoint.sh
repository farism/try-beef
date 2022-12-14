#!/bin/bash

set -e

/bin/run-parts docker-entrypoint.d

echo "Running $@"

exec $(node server/index.mjs & (sleep 10 && docker pull fae0/beef) & "$@")

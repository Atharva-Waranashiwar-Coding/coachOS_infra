#!/bin/sh
set -eu
docker image prune -f --filter 'until=168h'

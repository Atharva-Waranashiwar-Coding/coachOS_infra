#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
COMPOSE_FILE_PATH=${COMPOSE_FILE_PATH:-compose/docker-compose.prod.yml}
ENV_FILE_PATH=${ENV_FILE_PATH:-env/production.env}
IMAGE_ENV_FILE_PATH=${IMAGE_ENV_FILE_PATH:-env/image-versions.env}

exec docker compose \
  --project-directory "$ROOT_DIR" \
  --env-file "$ROOT_DIR/$ENV_FILE_PATH" \
  --env-file "$ROOT_DIR/$IMAGE_ENV_FILE_PATH" \
  -f "$ROOT_DIR/$COMPOSE_FILE_PATH" \
  "$@"

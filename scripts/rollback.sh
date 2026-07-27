#!/bin/sh
set -eu
root_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
test -n "${ROLLBACK_IMAGE_FILE:-}" || { echo 'Set ROLLBACK_IMAGE_FILE to a pinned image env file.' >&2; exit 2; }
cp "$ROLLBACK_IMAGE_FILE" "$root_dir/env/image-versions.env"
exec "$root_dir/scripts/deploy.sh"

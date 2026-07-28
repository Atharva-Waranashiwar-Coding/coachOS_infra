#!/bin/sh
set -eu
root_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
compose="$root_dir/scripts/compose.sh"

"$compose" up -d auth-db athlete-db media-db ai-review-db assistant-db redis minio
"$compose" run --rm auth-migrate
"$compose" run --rm athlete-migrate
"$compose" run --rm media-migrate
"$compose" run --rm ai-review-migrate
"$compose" run --rm assistant-migrate

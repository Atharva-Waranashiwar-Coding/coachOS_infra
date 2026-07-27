#!/bin/sh
set -eu
root_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
"$root_dir/scripts/compose.sh" up -d auth-service athlete-service media-service ai-review-service assistant-service

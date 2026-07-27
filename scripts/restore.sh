#!/bin/sh
set -eu
root_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
exec "$root_dir/scripts/restore-database.sh" "$@"

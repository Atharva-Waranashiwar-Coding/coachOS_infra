#!/bin/sh
set -eu
root_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
"$root_dir/scripts/wait-for-health.sh"

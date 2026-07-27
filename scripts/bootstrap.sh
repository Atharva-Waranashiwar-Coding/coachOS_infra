#!/bin/sh
set -eu
root_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
install -d -m 0750 "$root_dir/env"
test -f "$root_dir/env/production.env" || cp "$root_dir/env/production.env.example" "$root_dir/env/production.env"
test -f "$root_dir/env/image-versions.env" || cp "$root_dir/env/image-versions.env.example" "$root_dir/env/image-versions.env"
printf '%s\n' 'Fill env/production.env and env/image-versions.env before deploying.'

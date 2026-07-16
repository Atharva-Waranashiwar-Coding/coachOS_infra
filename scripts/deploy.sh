#!/bin/sh
set -eu

root_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
test -f "$root_dir/.env"
test -f "$root_dir/nginx/tls/fullchain.pem"
test -f "$root_dir/nginx/tls/privkey.pem"

"$root_dir/scripts/compose.sh" config --quiet
if "$root_dir/scripts/compose.sh" ps --status running --quiet | grep -q .; then
  "$root_dir/scripts/backup-all.sh"
fi
"$root_dir/scripts/compose.sh" pull
"$root_dir/scripts/compose.sh" up -d --remove-orphans
"$root_dir/scripts/wait-for-health.sh"

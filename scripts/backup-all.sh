#!/bin/sh
set -eu

root_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
backup_dir=${1:-"$root_dir/backups"}
retention_days=${BACKUP_RETENTION_DAYS:-14}

for database in auth athlete media ai-review; do
  "$root_dir/scripts/backup-database.sh" "$database" "$backup_dir"
done

find "$backup_dir" -type f \( -name '*.dump' -o -name '*.dump.sha256' \) -mtime "+$retention_days" -delete

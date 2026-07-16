#!/bin/sh
set -eu

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <auth|athlete|media|ai-review> [backup-directory]" >&2
  exit 2
fi

database=$1
backup_dir=${2:-"$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)/backups"}
timestamp=$(date -u +%Y%m%dT%H%M%SZ)

case "$database" in
  auth) service=auth-db; user=coachos_auth; db=coachos_auth ;;
  athlete) service=athlete-db; user=coachos_athlete; db=coachos_athlete ;;
  media) service=media-db; user=coachos_media; db=coachos_media ;;
  ai-review) service=ai-review-db; user=coachos_ai_review; db=coachos_ai_review ;;
  *) echo "Unknown database: $database" >&2; exit 2 ;;
esac

mkdir -p "$backup_dir"
output="$backup_dir/${database}-${timestamp}.dump"
"$(dirname "$0")/compose.sh" exec -T "$service" \
  pg_dump --username "$user" --dbname "$db" --format custom --no-owner --no-acl > "$output"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$output" > "$output.sha256"
else
  shasum -a 256 "$output" > "$output.sha256"
fi
echo "$output"

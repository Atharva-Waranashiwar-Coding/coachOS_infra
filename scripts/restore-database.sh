#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <auth|athlete|media|ai-review> <backup.dump>" >&2
  exit 2
fi
if [ "${ALLOW_DESTRUCTIVE_RESTORE:-false}" != "true" ]; then
  echo "Set ALLOW_DESTRUCTIVE_RESTORE=true to acknowledge destructive restore." >&2
  exit 1
fi

database=$1
backup_file=$2
test -f "$backup_file"
if [ -f "$backup_file.sha256" ]; then
  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$(dirname "$backup_file")" && sha256sum -c "$(basename "$backup_file").sha256")
  else
    (cd "$(dirname "$backup_file")" && shasum -a 256 -c "$(basename "$backup_file").sha256")
  fi
fi

case "$database" in
  auth)
    service=auth-db; user=coachos_auth; db=coachos_auth
    dependents="auth-service athlete-service media-service ai-review-service media-outbox-worker ai-review-worker ai-review-outbox-worker"
    ;;
  athlete)
    service=athlete-db; user=coachos_athlete; db=coachos_athlete
    dependents="athlete-service media-service ai-review-service media-outbox-worker ai-review-worker ai-review-outbox-worker"
    ;;
  media)
    service=media-db; user=coachos_media; db=coachos_media
    dependents="media-service ai-review-service media-outbox-worker ai-review-worker ai-review-outbox-worker"
    ;;
  ai-review)
    service=ai-review-db; user=coachos_ai_review; db=coachos_ai_review
    dependents="ai-review-service ai-review-worker ai-review-outbox-worker"
    ;;
  *) echo "Unknown database: $database" >&2; exit 2 ;;
esac

compose="$(dirname "$0")/compose.sh"
"$compose" stop $dependents
"$compose" exec -T "$service" \
  pg_restore --username "$user" --dbname "$db" --clean --if-exists --no-owner --no-acl < "$backup_file"
"$compose" up -d $dependents

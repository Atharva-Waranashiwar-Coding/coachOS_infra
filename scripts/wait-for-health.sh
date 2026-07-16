#!/bin/sh
set -eu

timeout=${DEPLOY_HEALTH_TIMEOUT_SECONDS:-180}
elapsed=0
healthchecked_services="auth-service athlete-service media-service ai-review-service frontend"
running_services="nginx"

while [ "$elapsed" -lt "$timeout" ]; do
  unhealthy=0
  for service in $healthchecked_services; do
    state=$("$(dirname "$0")/compose.sh" ps --format json "$service" 2>/dev/null || true)
    echo "$state" | grep -q '"Health":"healthy"' || unhealthy=1
  done
  for service in $running_services; do
    state=$("$(dirname "$0")/compose.sh" ps --format json "$service" 2>/dev/null || true)
    echo "$state" | grep -q '"State":"running"' || unhealthy=1
  done
  if [ "$unhealthy" -eq 0 ]; then
    echo "CoachOS services are running."
    exit 0
  fi
  sleep 5
  elapsed=$((elapsed + 5))
done

"$(dirname "$0")/compose.sh" ps
echo "Timed out waiting for CoachOS health." >&2
exit 1

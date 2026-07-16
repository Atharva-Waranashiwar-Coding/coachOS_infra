# GitHub Actions

The active infrastructure workflows live in `.github/workflows`.

- `ci.yml` validates shell scripts, both Compose configurations, Prometheus rules, and Grafana JSON.
- `deploy.yml` performs a manually approved, environment-scoped deployment over SSH to a generic Docker host.

Service repositories independently lint, test, build, and publish their own GHCR images.

The protected deployment environment requires `DEPLOY_SSH_KEY`, `DEPLOY_KNOWN_HOSTS`, `DEPLOY_HOST`, `DEPLOY_USER`, and `DEPLOY_PATH`. Generate the known-hosts value through a trusted administrative channel; the workflow does not accept an unverified runtime key scan.

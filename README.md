# CoachOS Infrastructure

Infrastructure configuration and operational tooling for CoachOS.

## Responsibilities

- Docker Compose setup
- Kubernetes manifests later
- Terraform infrastructure later
- GitHub Actions workflows
- Nginx configuration
- Local scripts
- Monitoring configuration
- Environment and deployment documentation

## Project Structure

- `docker`: shared Docker assets and local compose support
- `kubernetes`: Kubernetes manifests
- `terraform`: infrastructure as code
- `github-actions`: reusable workflow references
- `nginx`: reverse proxy and frontend serving configuration
- `scripts`: local and deployment helper scripts
- `monitoring`: metrics, logs, and observability setup

## Environment

Do not commit real `.env` files. Infrastructure secrets should be managed through environment-specific secret stores or CI/CD secret settings.

Ignored local files include:

- `.env`
- `terraform.tfstate`
- `.terraform/`
- `*.log`

## Local Development Strategy

The initial local stack should run each service independently during development and add a shared Docker Compose stack once service APIs and database dependencies are ready.

## Deployment Plan

MVP deployment should use containerized services, managed PostgreSQL, cloud object storage for videos, and a hosted frontend or Nginx-served static build.

## CI/CD Plan

GitHub Actions should eventually run:

- Backend tests
- Frontend build
- Docker image builds
- Migration checks
- Deployment workflows

## Monitoring Plan

Start with health checks and structured logs. Add centralized logs, metrics, tracing, dashboards, and alerts as the system matures.

## Status

Stage 0: infrastructure folder skeleton created. Local compose, CI workflows, and deployment configuration are next.

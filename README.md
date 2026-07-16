# CoachOS Infrastructure

Production-oriented, cloud-neutral Docker Compose deployment for CoachOS. This repository owns edge routing, service orchestration, PostgreSQL, object storage, monitoring, log aggregation, backups, and deployment automation. Kubernetes, Docker Swarm, Redis, Kafka, and RabbitMQ are intentionally not used.

## Architecture

```text
Browser
  |
  v
Nginx edge proxy :80/:443
  |-- /                 -> React frontend
  |-- /auth-api/        -> Auth Service
  |-- /athlete-api/     -> Athlete Service
  |-- /media-api/       -> Media Service
  `-- /ai-review-api/   -> AI Review Service

Each API -> its own PostgreSQL database
Media Service -> private MinIO/S3-compatible storage
AI Review workers -> configured AI provider

Prometheus <- APIs, Nginx exporters, PostgreSQL exporters
Grafana    <- Prometheus and Loki
Promtail   -> Docker JSON logs -> Loki
```

The four backend databases are separate containers, credentials, volumes, and migration histories. Services communicate through authenticated HTTP APIs and never query another service's database.

## Repository Layout

- `docker-compose.dev.yml`: source-build integration environment with published developer ports
- `docker-compose.prod.yml`: image-based hardened production environment
- `nginx`: development and HTTPS-ready production edge configuration
- `monitoring`: Prometheus rules, Grafana provisioning, Loki, and Promtail
- `scripts`: deployment, health, TLS, backup, and restore operations
- `.github/workflows`: infrastructure validation and manual deployment
- `github-actions`: CI/CD notes

## Compose Topology

| Component | Development | Production |
| --- | --- | --- |
| Edge Nginx | `localhost:8080` | ports `80` and `443` |
| Frontend | internal, edge-routed | internal, edge-routed |
| Backend APIs | `8000`, `8001`, `8003`, `8004` plus edge paths | internal only |
| PostgreSQL | `5540`-`5543` | internal only |
| MinIO | `9000`, console `9001` | internal only |
| Prometheus | `9090` | `127.0.0.1:9090` |
| Grafana | `3000` | `127.0.0.1:3000` |
| Loki | `3100` | internal only |

Networks are split into public edge traffic, internal service traffic, data traffic, and monitoring traffic. Production databases and storage are not published to the host.

## Environment

Create the untracked deployment environment:

```bash
cp .env.example .env
```

Replace every placeholder. Required groups are:

- `COACHOS_DOMAIN`, `COACHOS_SCHEME`, and `COMPOSE_PROJECT_NAME`
- one strong password per PostgreSQL database
- `JWT_SECRET_KEY` shared by services validating access tokens
- unique directional service-to-service tokens
- MinIO credentials and `OPENAI_API_KEY`
- Grafana administrator credentials
- immutable or controlled image references for every application
- backup retention and deployment health timeout

Do not put secrets in Compose files, Docker images, frontend `VITE_*` values, Git, or command history. Protect `.env` with host filesystem permissions and inject its values from the deployment environment.

## Development

All sibling repositories must share the same parent directory.

```bash
cp .env.example .env
docker compose --env-file .env -f docker-compose.dev.yml up -d --build
docker compose --env-file .env -f docker-compose.dev.yml ps
```

Open `http://localhost:8080`. The development Compose file builds every repository, starts all four databases, runs Alembic automatically in each API container, starts workers, and provisions MinIO.

Stop the stack:

```bash
docker compose --env-file .env -f docker-compose.dev.yml down
```

## Production Deployment

1. Install Docker Engine, the Docker Compose plugin, Git, OpenSSL, and enough persistent disk space.
2. Clone the infra repository and create `.env`.
3. Set image variables to images published by the service CI workflows.
4. Install valid TLS files at `nginx/tls/fullchain.pem` and `nginx/tls/privkey.pem`.
5. Log in to the image registry when images are private.
6. Run the deployment script.

```bash
./scripts/deploy.sh
```

The script validates Compose, backs up running databases, pulls images, performs a rolling Compose reconciliation, waits for application health, and leaves migrations to the API entrypoints. `alembic upgrade head` is idempotent; workers set `RUN_MIGRATIONS=false` to prevent migration races.

For a local TLS smoke test only:

```bash
./scripts/generate-self-signed-cert.sh localhost
./scripts/deploy.sh
```

## CI/CD

Each application repository runs its own quality checks and Docker build:

- Python: Ruff, Black, mypy, pytest, Docker Buildx
- Frontend: ESLint, TypeScript, Vitest, Vite build, Docker Buildx
- Successful `main` pushes publish SHA and `latest` tags to GHCR

Infrastructure CI validates shell syntax, both Compose models, Prometheus configuration and alerts, and Grafana JSON. The manual deployment workflow uses a protected GitHub environment and SSH to run `scripts/deploy.sh` on a generic Docker host. It requires a pinned `DEPLOY_KNOWN_HOSTS` value in addition to the SSH key, host, user, and deployment path.

## Monitoring

Every FastAPI service exposes:

- `GET /health/live`: process liveness
- `GET /health/ready`: PostgreSQL dependency readiness
- `GET /metrics`: Prometheus metrics

Prometheus scrapes API request metrics, Nginx exporters, and four PostgreSQL exporters. Alerts cover unavailable services, elevated 5xx rates, high p95 latency, and unavailable databases. Grafana is provisioned with Prometheus and Loki data sources plus the CoachOS operations dashboard.

Promtail discovers Docker containers through the local Docker socket, parses JSON application logs, and sends them to Loki. Socket access is read-only but remains privileged operational access; keep the monitoring stack restricted to trusted hosts.

## Logging

Backend logs are JSON written to stdout. Each record includes timestamp, level, service, logger, message, and request-scoped fields. Nginx accepts or generates `X-Request-ID`, forwards it to APIs, and APIs return it to clients and include it in logs. Container logs remain the source of truth; Promtail and Loki provide centralized search.

## Backup Strategy

Backups use PostgreSQL custom-format logical dumps, one database at a time, with SHA-256 sidecars.

```bash
./scripts/backup-all.sh
./scripts/backup-database.sh auth
./scripts/backup-database.sh athlete /secure/backup/path
```

Default backups are written under ignored `backups/` and pruned using `BACKUP_RETENTION_DAYS`. Copy completed dumps and checksum files to separate encrypted storage. Database backups do not include MinIO objects; object storage requires a separate bucket replication or filesystem backup policy.

## Recovery Procedure

1. Stop user traffic or place the edge behind maintenance handling.
2. Verify the selected dump and its `.sha256` sidecar.
3. Confirm the target database and acceptable data-loss window.
4. Run the guarded restore.
5. Wait for services to restart and pass readiness checks.
6. Verify login, athlete reads, media metadata, review queues, and Grafana alerts.

```bash
ALLOW_DESTRUCTIVE_RESTORE=true ./scripts/restore-database.sh auth backups/auth-YYYYMMDDTHHMMSSZ.dump
./scripts/wait-for-health.sh
```

Restore stops dependent application containers, runs `pg_restore --clean --if-exists`, and restarts dependencies. Restore each database from a coordinated backup set when recovering the full platform.

## Security Checklist

- [ ] Replace all example credentials and use at least 32 random bytes for secrets.
- [ ] Install trusted TLS certificates and restrict private key permissions.
- [ ] Keep PostgreSQL, MinIO, Loki, and service ports off the public network.
- [ ] Pin production images to immutable digests or release tags.
- [ ] Restrict CORS to the deployed CoachOS origin.
- [ ] Keep Nginx rate limits enabled and tune them from observed traffic.
- [ ] Run application containers as non-root with read-only filesystems, dropped capabilities, and `no-new-privileges`.
- [ ] Restrict Docker socket and host SSH access to operators.
- [ ] Rotate JWT, internal service, database, object-storage, AI, and Grafana credentials.
- [ ] Export encrypted backups off-host and test restores regularly.
- [ ] Review dependency and image scan results before promotion.

## Assumptions And Tradeoffs

- A single Docker host is the production failure domain. Compose does not provide multi-host failover.
- PostgreSQL and MinIO are self-hosted for portability; operators own patching, replication, capacity, and disaster recovery.
- Automatic migrations favor deployment simplicity. Backward-compatible migrations are required because Compose may briefly run mixed application versions.
- Promtail uses the Docker socket for container discovery. This is operationally simple but increases host trust requirements.
- Rate limiting is per Nginx instance and client IP. Distributed limiting is intentionally absent because there is one edge instance and no Redis.
- Logs and metrics are retained locally unless the operator adds external storage or backup.

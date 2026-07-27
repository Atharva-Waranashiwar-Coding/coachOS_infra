ENV_FILE ?= env/production.env
IMAGE_FILE ?= env/image-versions.env
COMPOSE = docker compose --env-file $(ENV_FILE) --env-file $(IMAGE_FILE) -f compose/docker-compose.prod.yml

.PHONY: bootstrap plan apply deploy rollback migrate health backup restore validate
bootstrap:
	./scripts/bootstrap.sh
plan:
	terraform -chdir=terraform/environments/production init
	terraform -chdir=terraform/environments/production plan
apply:
	terraform -chdir=terraform/environments/production apply
deploy:
	./scripts/deploy.sh
rollback:
	./scripts/rollback.sh
migrate:
	./scripts/migrate.sh
health:
	./scripts/health-check.sh
backup:
	./scripts/backup.sh
restore:
	./scripts/restore.sh
validate:
	$(COMPOSE) config --quiet

ifneq (,$(wildcard .env))
include .env
export
endif

PROXY_COMPOSE = docker compose -f infrastructure/compose/docker-compose.proxy.yml
DATABASE_COMPOSE = docker compose -f infrastructure/compose/docker-compose.database.yml
KEYCLOAK_COMPOSE = docker compose -f infrastructure/compose/docker-compose.keycloak.yml
LEGISLAGD_COMPONENTS_DIR ?= modules
LEGISLAGD_GIT_STATUS_TIMEOUT ?= 60
COMPOSE_HTTP_TIMEOUT ?= 300
DOCKER_CLIENT_TIMEOUT ?= 300
export LEGISLAGD_GIT_STATUS_TIMEOUT COMPOSE_HTTP_TIMEOUT DOCKER_CLIENT_TIMEOUT
PORTAL_COMPOSE = docker compose -p portalmodelo -f $(LEGISLAGD_COMPONENTS_DIR)/PortalModelo-SD/docker-compose.portal.yml -f infrastructure/compose/overrides/portal.legislagd.yml
SAPL_COMPOSE = docker compose -p sapl -f $(LEGISLAGD_COMPONENTS_DIR)/SAPL-SD/docker/docker-compose-dev-db.yml -f infrastructure/compose/overrides/sapl.legislagd.yml
SIGI_COMPOSE = docker compose -p sigi -f $(LEGISLAGD_COMPONENTS_DIR)/SIGI-SD/docker-compose.yml -f infrastructure/compose/overrides/sigi.legislagd.yml
ECIDADE_COMPOSE = docker compose -p ecidade -f $(LEGISLAGD_COMPONENTS_DIR)/e-Cidade-SD/docker-compose.yml -f infrastructure/compose/overrides/ecidade.legislagd.yml
SIGI_SERVICES = redis symfony-admin sigi-worker chatwoot chatwoot-worker botpress ollama qdrant portainer pgadmin
ECIDADE_SERVICES = ecidade_php56

LEGISLAGD_ENABLE_PORTAL ?= 1
LEGISLAGD_ENABLE_SAPL ?= 1
LEGISLAGD_ENABLE_SIGI ?= 1
LEGISLAGD_ENABLE_KEYCLOAK ?= 1
LEGISLAGD_ENABLE_ECIDADE ?= 1

MODULES = all completo dev sapl portal sigi ecidade proxy database keycloak
PLATFORM_MODULES =
ifneq (,$(filter 1 true yes on,$(LEGISLAGD_ENABLE_KEYCLOAK)))
PLATFORM_MODULES += keycloak
endif
ifneq (,$(filter 1 true yes on,$(LEGISLAGD_ENABLE_PORTAL)))
PLATFORM_MODULES += portal
endif
ifneq (,$(filter 1 true yes on,$(LEGISLAGD_ENABLE_SAPL)))
PLATFORM_MODULES += sapl
endif
ifneq (,$(filter 1 true yes on,$(LEGISLAGD_ENABLE_SIGI)))
PLATFORM_MODULES += sigi
endif
ifneq (,$(filter 1 true yes on,$(LEGISLAGD_ENABLE_ECIDADE)))
PLATFORM_MODULES += ecidade
endif
SELECTED_MODULES = $(or $(filter $(MODULES),$(MAKECMDGOALS)),all)

.PHONY: help check clone bootstrap-repos validate prepare-dev-env dev-install initial-load initial-load-sapl initial-load-sigi initial-load-keycloak initial-load-portal initial-load-ecidade provision-keycloak-db provision-keycloak-dev-users provision-ecidade-db up down stop restart ps logs config pull build migrate urls \
	up-all up-completo up-dev up-platform up-sapl up-portal up-sigi up-ecidade up-proxy up-keycloak \
	up-database down-database stop-database restart-database ps-database logs-database config-database pull-database \
	migrate-all migrate-completo migrate-dev migrate-sapl migrate-sigi \
	down-all down-completo down-dev down-platform down-sapl down-portal down-sigi down-ecidade down-proxy down-keycloak \
	stop-all stop-completo stop-dev stop-platform stop-sapl stop-portal stop-sigi stop-ecidade stop-proxy stop-keycloak \
	restart-all restart-completo restart-dev restart-sapl restart-portal restart-sigi restart-ecidade restart-proxy restart-keycloak \
	ps-all ps-completo ps-dev ps-sapl ps-portal ps-sigi ps-ecidade ps-proxy ps-keycloak \
	logs-all logs-completo logs-dev logs-sapl logs-portal logs-sigi logs-ecidade logs-proxy logs-keycloak \
	config-all config-completo config-dev config-sapl config-portal config-sigi config-ecidade config-proxy config-keycloak \
	pull-all pull-completo pull-dev pull-sapl pull-portal pull-sigi pull-ecidade pull-proxy pull-keycloak \
	build-all build-completo build-dev build-sapl build-portal build-sigi build-ecidade build-proxy build-keycloak \
	$(MODULES)

help:
	@echo "LegislaGD - plataforma central legislativa aberta"
	@echo ""
	@echo "Uso principal:"
	@echo "  make up              Sobe PortalModelo-SD, SAPL-SD, SIGI-SD e Traefik central"
	@echo "  make down            Derruba toda a plataforma central"
	@echo "  make restart         Reinicia toda a plataforma central"
	@echo "  make ps              Lista os containers da plataforma"
	@echo "  make migrate         Aplica migracoes/esquemas dos modulos integrados"
	@echo "  make dev-install     Prepara .env, sobe a stack e aplica cargas iniciais locais"
	@echo "  make initial-load    Aplica cargas iniciais locais nos modulos integrados"
	@echo "  make urls            Mostra os enderecos locais"
	@echo "  make ps database     Lista o Postgres central"
	@echo "  make ps keycloak     Lista o Keycloak"
	@echo "  make provision-keycloak-db  Cria/atualiza banco e usuario do Keycloak no Postgres central"
	@echo "  make provision-keycloak-dev-users  Cria/atualiza usuarios SSO locais de teste"
	@echo ""
	@echo "Padrao local:"
	@echo "  ambiente: $${LEGISLAGD_ENV:-development}"
	@echo "  branch dos modulos: $${LEGISLAGD_COMPONENT_BRANCH:-dev}"
	@echo ""
	@echo "Modulos individuais:"
	@echo "  make up portal       Sobe somente PortalModelo-SD com Traefik central"
	@echo "  make up sapl         Sobe somente SAPL-SD com Traefik central"
	@echo "  make up sigi         Sobe somente SIGI-SD com Traefik central"
	@echo "  make up ecidade      Sobe somente e-Cidade-SD com Traefik central"
	@echo "  make up keycloak     Sobe somente Keycloak usando o Postgres central"
	@echo "  make down portal     Derruba somente PortalModelo-SD"
	@echo "  make down sapl       Derruba somente SAPL-SD"
	@echo "  make down sigi       Derruba somente SIGI-SD"
	@echo "  make down ecidade    Derruba somente e-Cidade-SD"
	@echo ""
	@echo "Modulos habilitados no make up padrao: database $(or $(PLATFORM_MODULES),nenhum)"
	@echo ""
	@echo "Observacao: e-Cidade-SD usa o Postgres central do LegislaGD nesta etapa."

check:
	./scripts/check-repositories.sh

clone: bootstrap-repos

bootstrap-repos:
	./scripts/clone-components.sh

validate:
	./scripts/validate-environment.sh

prepare-dev-env:
	sh ./scripts/ensure-dev-env.sh

dev-install: prepare-dev-env
	@$(MAKE) up
	@$(MAKE) initial-load
	@$(MAKE) urls

initial-load: prepare-dev-env
	@$(MAKE) initial-load-sapl
	@$(MAKE) initial-load-sigi
	@$(MAKE) initial-load-keycloak
	@$(MAKE) initial-load-portal
	@$(MAKE) initial-load-ecidade

initial-load-sapl: up-sapl
	sh ./scripts/reset-sapl-admin.sh

initial-load-sigi: prepare-dev-env up-sigi
	$(SIGI_COMPOSE) exec -T symfony-admin php bin/console doctrine:fixtures:load --no-interaction
	sh ./scripts/provision-chatwoot-dev-sso.sh

initial-load-keycloak: prepare-dev-env up-keycloak
	set -a; . ./.env; set +a; sh ./scripts/provision-keycloak-dev-users.sh

initial-load-portal: up-portal
	$(PORTAL_COMPOSE) stop portalmodelo
	$(PORTAL_COMPOSE) run --rm portalmodelo make buildout
	$(PORTAL_COMPOSE) up -d --build

initial-load-ecidade: up-ecidade
	$(ECIDADE_COMPOSE) exec -T ecidade_php56 sh -lc "chmod -R 775 /var/www/html && if [ -f docker/database/ecidade_base.sql.gz ]; then gunzip -kf docker/database/ecidade_base.sql.gz; fi && bash docker/install.sh"

provision-keycloak-db: up-database
	docker exec -i legislagd-postgres sh -s < infrastructure/database/provision-keycloak-database.sh

provision-ecidade-db: up-database
	docker exec -i \
		-e LEGISLAGD_POSTGRES_USER="$${LEGISLAGD_POSTGRES_USER:-legislagd}" \
		-e LEGISLAGD_POSTGRES_DB="$${LEGISLAGD_POSTGRES_DB:-legislagd}" \
		-e ECIDADE_DB_NAME="$${ECIDADE_DB_NAME:-ecidade}" \
		-e ECIDADE_DB_USER="$${ECIDADE_DB_USER:-dbseller}" \
		-e ECIDADE_DB_PASSWORD="$${ECIDADE_DB_PASSWORD:-dbseller}" \
		-e ECIDADE_PLUGIN_DB_USER="$${ECIDADE_PLUGIN_DB_USER:-plugin}" \
		-e ECIDADE_PLUGIN_DB_PASSWORD="$${ECIDADE_PLUGIN_DB_PASSWORD:-plugin}" \
		-e ECIDADE_LEGACY_DB_USER="$${ECIDADE_LEGACY_DB_USER:-dbseller}" \
		-e ECIDADE_LEGACY_DB_PASSWORD="$${ECIDADE_LEGACY_DB_PASSWORD:-dbseller}" \
		legislagd-postgres sh -s < infrastructure/database/provision-ecidade-database.sh

provision-keycloak-dev-users: prepare-dev-env up-keycloak
	set -a; . ./.env; set +a; sh ./scripts/provision-keycloak-dev-users.sh

up: $(addprefix up-,$(SELECTED_MODULES))

up-all: up-platform
up-completo: up-platform
up-dev: up-platform

up-platform: bootstrap-repos up-database up-proxy $(addprefix up-,$(PLATFORM_MODULES))
	@$(MAKE) urls

up-database:
	$(DATABASE_COMPOSE) up -d

up-proxy:
	$(PROXY_COMPOSE) up -d

up-keycloak: up-database up-proxy provision-keycloak-db
	$(KEYCLOAK_COMPOSE) up -d

up-portal build-portal: export LEGISLAGD_ENABLE_PORTAL=1
up-portal: bootstrap-repos up-proxy
	$(PORTAL_COMPOSE) up -d --build

up-sapl build-sapl: export LEGISLAGD_ENABLE_SAPL=1
up-sapl: bootstrap-repos up-database up-proxy
	$(SAPL_COMPOSE) up -d --build
	@$(MAKE) migrate-sapl

up-sigi build-sigi: export LEGISLAGD_ENABLE_SIGI=1
up-sigi: bootstrap-repos up-database up-proxy
	$(SIGI_COMPOSE) up -d --build --no-deps $(SIGI_SERVICES)
	@$(MAKE) migrate-sigi

up-ecidade build-ecidade: export LEGISLAGD_ENABLE_ECIDADE=1
up-ecidade: bootstrap-repos provision-ecidade-db up-proxy
	$(ECIDADE_COMPOSE) up -d --build --no-deps $(ECIDADE_SERVICES)

migrate: $(addprefix migrate-,$(SELECTED_MODULES))

migrate-all: migrate-sapl migrate-sigi
migrate-completo: migrate-all
migrate-dev: migrate-all

migrate-sapl:
	$(SAPL_COMPOSE) exec -T sapl-dev python3 manage.py migrate --noinput

migrate-sigi:
	$(SIGI_COMPOSE) exec -T symfony-admin php bin/console doctrine:schema:update --force --no-interaction

down: $(addprefix down-,$(SELECTED_MODULES))

down-all: down-platform
down-completo: down-platform
down-dev: down-platform

down-platform: down-ecidade down-sigi down-sapl down-portal down-keycloak down-database down-proxy

down-portal:
	$(PORTAL_COMPOSE) down

down-sapl:
	$(SAPL_COMPOSE) down

down-sigi:
	$(SIGI_COMPOSE) down

down-ecidade:
	$(ECIDADE_COMPOSE) down

down-database:
	$(DATABASE_COMPOSE) down

down-proxy:
	$(PROXY_COMPOSE) down

down-keycloak:
	$(KEYCLOAK_COMPOSE) down

stop: $(addprefix stop-,$(SELECTED_MODULES))

stop-all: stop-platform
stop-completo: stop-platform
stop-dev: stop-platform

stop-platform: stop-ecidade stop-sigi stop-sapl stop-portal stop-keycloak stop-database stop-proxy

stop-portal:
	$(PORTAL_COMPOSE) stop

stop-sapl:
	$(SAPL_COMPOSE) stop

stop-sigi:
	$(SIGI_COMPOSE) stop

stop-ecidade:
	$(ECIDADE_COMPOSE) stop

stop-database:
	$(DATABASE_COMPOSE) stop

stop-proxy:
	$(PROXY_COMPOSE) stop

stop-keycloak:
	$(KEYCLOAK_COMPOSE) stop

restart: $(addprefix restart-,$(SELECTED_MODULES))

restart-all: down-all up-all
restart-completo: restart-all
restart-dev: restart-all
restart-portal: down-portal up-portal
restart-sapl: down-sapl up-sapl
restart-sigi: down-sigi up-sigi
restart-ecidade: down-ecidade up-ecidade
restart-proxy: down-proxy up-proxy
restart-database: down-database up-database
restart-keycloak: down-keycloak up-keycloak

ps: $(addprefix ps-,$(SELECTED_MODULES))

ps-all: ps-database ps-proxy ps-keycloak ps-portal ps-sapl ps-sigi ps-ecidade
ps-completo: ps-all
ps-dev: ps-all

ps-proxy:
	$(PROXY_COMPOSE) ps

ps-database:
	$(DATABASE_COMPOSE) ps

ps-keycloak:
	$(KEYCLOAK_COMPOSE) ps

ps-portal:
	$(PORTAL_COMPOSE) ps

ps-sapl:
	$(SAPL_COMPOSE) ps

ps-sigi:
	$(SIGI_COMPOSE) ps

ps-ecidade:
	$(ECIDADE_COMPOSE) ps

logs: $(addprefix logs-,$(SELECTED_MODULES))

logs-all:
	@echo "Use um modulo para logs em modo continuo:"
	@echo "  make logs portal"
	@echo "  make logs sapl"
	@echo "  make logs sigi"
	@echo "  make logs ecidade"
	@echo "  make logs proxy"
	@echo "  make logs database"
	@echo "  make logs keycloak"

logs-completo: logs-all
logs-dev: logs-all

logs-portal:
	$(PORTAL_COMPOSE) logs -f portalmodelo

logs-sapl:
	$(SAPL_COMPOSE) logs -f sapl-dev

logs-sigi:
	$(SIGI_COMPOSE) logs -f

logs-ecidade:
	$(ECIDADE_COMPOSE) logs -f

logs-proxy:
	$(PROXY_COMPOSE) logs -f proxy

logs-database:
	$(DATABASE_COMPOSE) logs -f database

logs-keycloak:
	$(KEYCLOAK_COMPOSE) logs -f

config: $(addprefix config-,$(SELECTED_MODULES))

config-all: config-database config-proxy config-keycloak config-portal config-sapl config-sigi config-ecidade
config-completo: config-all
config-dev: config-all

config-proxy:
	$(PROXY_COMPOSE) config

config-database:
	$(DATABASE_COMPOSE) config

config-keycloak:
	$(KEYCLOAK_COMPOSE) config

config-portal:
	$(PORTAL_COMPOSE) config

config-sapl:
	$(SAPL_COMPOSE) config

config-sigi:
	$(SIGI_COMPOSE) config

config-ecidade:
	$(ECIDADE_COMPOSE) config

pull: $(addprefix pull-,$(SELECTED_MODULES))

pull-all: pull-database pull-proxy pull-keycloak pull-portal pull-sapl pull-sigi pull-ecidade
pull-completo: pull-all
pull-dev: pull-all

pull-proxy:
	$(PROXY_COMPOSE) pull

pull-database:
	$(DATABASE_COMPOSE) pull

pull-keycloak:
	$(KEYCLOAK_COMPOSE) pull

pull-portal:
	$(PORTAL_COMPOSE) pull

pull-sapl:
	$(SAPL_COMPOSE) pull

pull-sigi:
	$(SIGI_COMPOSE) pull

pull-ecidade:
	$(ECIDADE_COMPOSE) pull

build: $(addprefix build-,$(SELECTED_MODULES))

build-all: build-portal build-sapl build-sigi build-ecidade
build-completo: build-all
build-dev: build-all

build-proxy:
	@echo "Proxy usa imagem publica do Traefik; nao ha build local."

build-keycloak:
	@echo "Keycloak usa imagem publica; nao ha build local."

build-portal: bootstrap-repos
	$(PORTAL_COMPOSE) build

build-sapl: bootstrap-repos
	$(SAPL_COMPOSE) build

build-sigi: bootstrap-repos
	$(SIGI_COMPOSE) build

build-ecidade: bootstrap-repos
	$(ECIDADE_COMPOSE) build

urls:
	@echo "LegislaGD central:"
	@echo "  http://legislagd.localhost"
	@echo "  http://proxy.legislagd.localhost"
	@echo "  http://id.legislagd.localhost"
	@echo "  Postgres central: localhost:$${LEGISLAGD_POSTGRES_PORT:-5432}"
	@echo ""
	@echo "Modulos integrados:"
	@echo "  PortalModelo-SD: http://portal.legislagd.localhost"
	@echo "  SAPL-SD:         http://sapl.legislagd.localhost"
	@echo "  SIGI-SD admin:   http://sigi.legislagd.localhost"
	@echo "  SIGI Chatwoot:   http://chat.sigi.legislagd.localhost"
	@echo "  SIGI Botpress:   http://bot.sigi.legislagd.localhost"
	@echo "  SIGI IA:         http://ia.sigi.legislagd.localhost"
	@echo "  SIGI Qdrant:     http://qdrant.sigi.legislagd.localhost"
	@echo "  SIGI pgAdmin:    http://pgadmin.sigi.legislagd.localhost"
	@echo "  SIGI Portainer:  http://portainer.sigi.legislagd.localhost"
	@echo "  e-Cidade-SD:     http://ecidade.legislagd.localhost"
	@echo ""
	@echo "e-Cidade-SD usa o Postgres central do LegislaGD nesta etapa."

$(MODULES):
	@:

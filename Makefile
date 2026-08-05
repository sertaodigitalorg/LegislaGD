ifneq (,$(wildcard .env))
include .env
export
endif

PROXY_COMPOSE = docker compose -f infrastructure/compose/docker-compose.proxy.yml
PORTAL_COMPOSE = docker compose -p portalmodelo -f ../PortalModelo-SD/docker-compose.portal.yml -f infrastructure/compose/overrides/portal.legislagd.yml
SAPL_COMPOSE = docker compose -p sapl -f ../SAPL-SD/docker/docker-compose-dev-db.yml -f infrastructure/compose/overrides/sapl.legislagd.yml
SIGI_COMPOSE = docker compose -p sigi -f ../SIGI-SD/docker-compose.yml -f infrastructure/compose/overrides/sigi.legislagd.yml

LEGISLAGD_ENABLE_PORTAL ?= 1
LEGISLAGD_ENABLE_SAPL ?= 1
LEGISLAGD_ENABLE_SIGI ?= 1

MODULES = all completo dev sapl portal sigi proxy
PLATFORM_MODULES =
ifneq (,$(filter 1 true yes on,$(LEGISLAGD_ENABLE_PORTAL)))
PLATFORM_MODULES += portal
endif
ifneq (,$(filter 1 true yes on,$(LEGISLAGD_ENABLE_SAPL)))
PLATFORM_MODULES += sapl
endif
ifneq (,$(filter 1 true yes on,$(LEGISLAGD_ENABLE_SIGI)))
PLATFORM_MODULES += sigi
endif
SELECTED_MODULES = $(or $(filter $(MODULES),$(MAKECMDGOALS)),all)

.PHONY: help check clone bootstrap-repos validate up down stop restart ps logs config pull build urls \
	up-all up-completo up-dev up-platform up-sapl up-portal up-sigi up-proxy \
	down-all down-completo down-dev down-platform down-sapl down-portal down-sigi down-proxy \
	stop-all stop-completo stop-dev stop-platform stop-sapl stop-portal stop-sigi stop-proxy \
	restart-all restart-completo restart-dev restart-sapl restart-portal restart-sigi restart-proxy \
	ps-all ps-completo ps-dev ps-sapl ps-portal ps-sigi ps-proxy \
	logs-all logs-completo logs-dev logs-sapl logs-portal logs-sigi logs-proxy \
	config-all config-completo config-dev config-sapl config-portal config-sigi config-proxy \
	pull-all pull-completo pull-dev pull-sapl pull-portal pull-sigi pull-proxy \
	build-all build-completo build-dev build-sapl build-portal build-sigi build-proxy \
	$(MODULES)

help:
	@echo "LegislaGD - plataforma central legislativa aberta"
	@echo ""
	@echo "Uso principal:"
	@echo "  make up              Sobe PortalModelo-SD, SAPL-SD, SIGI-SD e Traefik central"
	@echo "  make down            Derruba toda a plataforma central"
	@echo "  make restart         Reinicia toda a plataforma central"
	@echo "  make ps              Lista os containers da plataforma"
	@echo "  make urls            Mostra os enderecos locais"
	@echo ""
	@echo "Padrao local:"
	@echo "  ambiente: $${LEGISLAGD_ENV:-development}"
	@echo "  branch dos modulos: $${LEGISLAGD_COMPONENT_BRANCH:-dev}"
	@echo ""
	@echo "Modulos individuais:"
	@echo "  make up portal       Sobe somente PortalModelo-SD com Traefik central"
	@echo "  make up sapl         Sobe somente SAPL-SD com Traefik central"
	@echo "  make up sigi         Sobe somente SIGI-SD com Traefik central"
	@echo "  make down portal     Derruba somente PortalModelo-SD"
	@echo "  make down sapl       Derruba somente SAPL-SD"
	@echo "  make down sigi       Derruba somente SIGI-SD"
	@echo ""
	@echo "Modulos habilitados no make up padrao: $(or $(PLATFORM_MODULES),nenhum)"
	@echo ""
	@echo "Observacao: e-Cidade-SD nao sobe nesta etapa."

check:
	./scripts/check-repositories.sh

clone: bootstrap-repos

bootstrap-repos:
	./scripts/clone-components.sh

validate:
	./scripts/validate-environment.sh

up: $(addprefix up-,$(SELECTED_MODULES))

up-all: up-platform
up-completo: up-platform
up-dev: up-platform

up-platform: bootstrap-repos up-proxy $(addprefix up-,$(PLATFORM_MODULES))
	@$(MAKE) urls

up-proxy:
	$(PROXY_COMPOSE) up -d

up-portal build-portal: export LEGISLAGD_ENABLE_PORTAL=1
up-portal: bootstrap-repos up-proxy
	$(PORTAL_COMPOSE) up -d --build

up-sapl build-sapl: export LEGISLAGD_ENABLE_SAPL=1
up-sapl: bootstrap-repos up-proxy
	$(SAPL_COMPOSE) up -d --build

up-sigi build-sigi: export LEGISLAGD_ENABLE_SIGI=1
up-sigi: bootstrap-repos up-proxy
	$(SIGI_COMPOSE) up -d

down: $(addprefix down-,$(SELECTED_MODULES))

down-all: down-platform
down-completo: down-platform
down-dev: down-platform

down-platform: down-sigi down-sapl down-portal down-proxy

down-portal:
	$(PORTAL_COMPOSE) down

down-sapl:
	$(SAPL_COMPOSE) down

down-sigi:
	$(SIGI_COMPOSE) down

down-proxy:
	$(PROXY_COMPOSE) down

stop: $(addprefix stop-,$(SELECTED_MODULES))

stop-all: stop-platform
stop-completo: stop-platform
stop-dev: stop-platform

stop-platform: stop-sigi stop-sapl stop-portal stop-proxy

stop-portal:
	$(PORTAL_COMPOSE) stop

stop-sapl:
	$(SAPL_COMPOSE) stop

stop-sigi:
	$(SIGI_COMPOSE) stop

stop-proxy:
	$(PROXY_COMPOSE) stop

restart: $(addprefix restart-,$(SELECTED_MODULES))

restart-all: down-all up-all
restart-completo: restart-all
restart-dev: restart-all
restart-portal: down-portal up-portal
restart-sapl: down-sapl up-sapl
restart-sigi: down-sigi up-sigi
restart-proxy: down-proxy up-proxy

ps: $(addprefix ps-,$(SELECTED_MODULES))

ps-all: ps-proxy ps-portal ps-sapl ps-sigi
ps-completo: ps-all
ps-dev: ps-all

ps-proxy:
	$(PROXY_COMPOSE) ps

ps-portal:
	$(PORTAL_COMPOSE) ps

ps-sapl:
	$(SAPL_COMPOSE) ps

ps-sigi:
	$(SIGI_COMPOSE) ps

logs: $(addprefix logs-,$(SELECTED_MODULES))

logs-all:
	@echo "Use um modulo para logs em modo continuo:"
	@echo "  make logs portal"
	@echo "  make logs sapl"
	@echo "  make logs sigi"
	@echo "  make logs proxy"

logs-completo: logs-all
logs-dev: logs-all

logs-portal:
	$(PORTAL_COMPOSE) logs -f portalmodelo

logs-sapl:
	$(SAPL_COMPOSE) logs -f sapl-dev

logs-sigi:
	$(SIGI_COMPOSE) logs -f

logs-proxy:
	$(PROXY_COMPOSE) logs -f proxy

config: $(addprefix config-,$(SELECTED_MODULES))

config-all: config-proxy config-portal config-sapl config-sigi
config-completo: config-all
config-dev: config-all

config-proxy:
	$(PROXY_COMPOSE) config

config-portal:
	$(PORTAL_COMPOSE) config

config-sapl:
	$(SAPL_COMPOSE) config

config-sigi:
	$(SIGI_COMPOSE) config

pull: $(addprefix pull-,$(SELECTED_MODULES))

pull-all: pull-proxy pull-portal pull-sapl pull-sigi
pull-completo: pull-all
pull-dev: pull-all

pull-proxy:
	$(PROXY_COMPOSE) pull

pull-portal:
	$(PORTAL_COMPOSE) pull

pull-sapl:
	$(SAPL_COMPOSE) pull

pull-sigi:
	$(SIGI_COMPOSE) pull

build: $(addprefix build-,$(SELECTED_MODULES))

build-all: build-portal build-sapl build-sigi
build-completo: build-all
build-dev: build-all

build-proxy:
	@echo "Proxy usa imagem publica do Traefik; nao ha build local."

build-portal: bootstrap-repos
	$(PORTAL_COMPOSE) build

build-sapl: bootstrap-repos
	$(SAPL_COMPOSE) build

build-sigi: bootstrap-repos
	$(SIGI_COMPOSE) build

urls:
	@echo "LegislaGD central:"
	@echo "  http://legislagd.localhost"
	@echo "  http://proxy.legislagd.localhost"
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
	@echo ""
	@echo "e-Cidade-SD: fora da subida principal nesta etapa."

$(MODULES):
	@:

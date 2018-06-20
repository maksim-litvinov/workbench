.PHONY: build prepare run test seed down setup-apps just_start restart peatio_rebuild update

COMPOSE = docker-compose -f compose/app.yaml -f compose/backend.yaml  -f compose/proxy.yaml

default: run

build:
	$(COMPOSE) build peatio barong

prepare:
	$(COMPOSE) up -d vault db redis rabbitmq rabbitmq_management smtp_relay coinhub peatio_daemons $(COMPOSE) run --rm vault secrets enable totp || true

setup-apps: build
	$(COMPOSE) run --rm peatio "./bin/setup"
	$(COMPOSE) run --rm barong "./bin/setup"

run: prepare setup-apps
	$(COMPOSE) up peatio barong proxy

test: prepare
	@$(COMPOSE) run --rm peatio_specs

start: prepare setup-apps
	$(COMPOSE) up -d peatio barong

just_start:
	$(COMPOSE) up -d peatio barong

restart:
	$(COMPOSE) restart

peatio_rebuild:
	$(COMPOSE) build peatio
	$(COMPOSE) restart

update:
	git submodule update --init --remote

down:
	@$(COMPOSE) down

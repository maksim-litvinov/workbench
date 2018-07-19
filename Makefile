.PHONY: build prepare run test seed down setup-apps just_start restart peatio_rebuild update

COMPOSE = docker-compose

default: run

build:
	$(COMPOSE) build peatio barong toolbox frontend

daemons:
	$(COMPOSE) up -d deposit_coin deposit_coin_address slave_book market_ticker matching \
		order_processor pusher_market pusher_member trade_executor withdraw_coin

dependencies:
	$(COMPOSE) up -d vault db redis rabbitmq smtp_relay coinhub slanger rippled
	$(COMPOSE) run --rm vault secrets enable totp || true

prepare: dependencies daemons

setup-apps: build
	$(COMPOSE) run --rm barong bash -c "./bin/link_config && ./bin/setup"

run: prepare setup-apps
	$(COMPOSE) up barong peatio proxy frontend rippled

run_frontend:
	$(COMPOSE) up proxy frontend barong

test: prepare
	@$(COMPOSE) run --rm peatio_specs

start: prepare setup-apps
	$(COMPOSE) up -d peatio barong trading_ui proxy

just_start:
	$(COMPOSE) up peatio barong proxy

restart:
	$(COMPOSE) restart

peatio_rebuild:
	$(COMPOSE) build peatio
	$(COMPOSE) restart

update:
	git submodule update --init --remote

down:
	@$(COMPOSE) down

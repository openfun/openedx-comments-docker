# Docker
COMPOSE          = docker-compose
COMPOSE_RUN      = $(COMPOSE) run --rm
COMPOSE_EXEC     = $(COMPOSE) exec

# Django
MANAGE           = $(COMPOSE_EXEC) lms dockerize -wait tcp://mysql:3306 -timeout 60s python manage.py

default: help

bootstrap: build dev migrate index superuser demo ## bootstrap the project
.PHONY: bootstrap

build:  ## build the forum image
	$(COMPOSE) build forum lms
.PHONY: build

demo:  ## import demo course
	$(MANAGE) cms import /edx/app/edxapp/data /edx/demo/course
.PHONY: demo

dev:  ## start the forum service (and its dependencies)
	$(COMPOSE) up -d forum
.PHONY: dev

down:  ## stop & remove all services
	$(COMPOSE) down
.PHONY: stop

index:  ## initialize elasticsearch index
	$(COMPOSE_EXEC) forum bin/rake search:initialize
.PHONY: index

migrate:  ## perform database migrations
	$(MANAGE) lms migrate
	$(MANAGE) cms migrate
.PHONY: migrate

status:  ## an alias for docker-compose ps
	$(COMPOSE) ps
.PHONY: status

stop:  ## stop running services
	$(COMPOSE) stop
.PHONY: stop

superuser:  ## create superuser (Open edX LMS)
	$(MANAGE) lms shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@foex.edu', 'openedx-rox')";
.PHONY: superuse

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

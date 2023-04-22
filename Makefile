OWNER := fabianlee
PROJECT := gcp-cloudrun-python3-gunicorn
VERSION := 1.0.0
OPV := $(OWNER)/$(PROJECT):$(VERSION)

SHELL := /bin/bash

EXPOSED_PORT := 8080
CONTAINER_PORT := 8080
WEBPORT := $(EXPOSED_PORT):$(CONTAINER_PORT)

# you may need to change to "sudo docker" if not a member of 'docker' group
DOCKERCMD := "docker"

BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
# unique id from last git commit
MY_GITREF := $(shell git rev-parse --short HEAD)

## tests locally using Flask
test-local-flask:
	./run_flask_localdev.sh

## tests locally using Gunicorn
test-local-gunicorn:
	./run_gunicorn_localdev.sh

## builds docker image
docker-build:
	@echo MY_GITREF is $(MY_GITREF)
	$(DOCKERCMD) build -f Dockerfile -t $(OPV) .

## cleans docker image
clean:
	$(DOCKERCMD) image rm $(OPV) | true

## runs container in foreground, testing a couple of override values
docker-test-fg:
	# Other env vars that can be overridden
	# -e APP_CONTEXT=/gunicorn
	# -e GUNICORN_WORKERS=3
	# -e GUNICORN_BIND=0.0.0.0:8080
	$(DOCKERCMD) run -it -p $(WEBPORT) -e GUNICORN_WORKERS=3 --rm $(OPV)

## runs container in foreground, override entrypoint to use use shell
docker-test-cli:
	$(DOCKERCMD) run -it --rm --entrypoint "/bin/sh" $(OPV)

## run container in background
docker-run-bg:
	$(DOCKERCMD) run -d -p $(WEBPORT) -e GUNICORN_WORKERS=3 --rm --name $(PROJECT) $(OPV)

## get into console of container running in background
docker-cli-bg:
	$(DOCKERCMD) exec -it $(PROJECT) /bin/sh

## tails $(DOCKERCMD)logs
docker-logs:
	$(DOCKERCMD) logs -f $(PROJECT)

## stops container running in background
docker-stop:
	$(DOCKERCMD) ps -q --filter ancestor="$(OPV)" | xargs -r $(DOCKERCMD) stop

## pushes to $(DOCKERCMD)hub
docker-push:
	$(DOCKERCMD) push $(OPV)


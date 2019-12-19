# Change shell in linux
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Linux)
    SHELL:=bash
endif
# Get user ID
UID := $(shell id -u)
WORKDIR := /application
DEV_DIR := .
ifndef TARGET_ENVIRONMENT
    TARGET_ENVIRONMENT := dev
endif

# Get docker path or an empty string
DOCKER := $(shell command -v docker)
SERVICE_NAME := php-fpm



# Test if the dependencies we need to run this Makefile are installed and creates the common docker network if missing
depend-on-docker:
ifndef DOCKER
	@echo "Docker is not available. Please install docker"
	@exit 1
endif

uid:
	export UID

docker-build: depend-on-docker
	docker-compose \
		-f docker-compose.yml \
		build

run: uid docker-build
	docker-compose -f docker-compose.yml up; exit 0


# Run a shell into the development docker image
shell: docker-build
	docker run -ti --rm -v $(PWD):$(WORKDIR) -u $(UID):$(UID) --name $(SERVICE_NAME) -p $(PORT):$(PORT) $(REPOSITORY)-dev /bin/bash; exit 0;




test: depend-on-docker
	docker-compose -f docker-compose.yml exec $(SERVICE_NAME) /application/vendor/bin/phpunit

start-php-unit-coverage: depend-on-docker
	docker-compose -f docker-compose.yml exec $(SERVICE_NAME) /application/vendor/bin/phpunit --coverage

dockers-down: depend-on-docker
	docker-compose -f docker-compose.yml down
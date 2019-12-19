# Change shell in linux
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Linux)
    SHELL:=bash
endif
# Get user ID
UID := $(shell id -u)
WORKDIR := /var/www/html
DEV_DIR := .
ifndef TARGET_ENVIRONMENT
    TARGET_ENVIRONMENT := dev
endif

# Get docker path or an empty string
DOCKER := $(shell command -v docker)
SERVICE_NAME := php-fpm




# CMDs
MKDIR_P = mkdir -p
COMPOSER_PHAR_UPDATE_CMD := curl -o ./bin/composer.phar https://getcomposer.org/composer.phar
COMPOSER_INSTALL_CMD := php ./bin/composer.phar install -o --ignore-platform-reqs
COMPOSER_FIXLOCK_CMD := php ./bin/composer.phar update --lock -o --ignore-platform-reqs
COMPOSER_UPDATE_CMD := php ./bin/composer.phar update -o --ignore-platform-reqs

PORT := 9710


.EXPORT_ALL_VARIABLES:

default: setup-blackbox docker-build

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
	docker-compose -f docker-compose.yml exec $(SERVICE_NAME) /var/www/html/vendor/bin/phpunit

start-php-unit-coverage: depend-on-docker
	docker-compose -f docker-compose.yml exec $(SERVICE_NAME) /var/www/html/vendor/bin/phpunit --coverage

dockers-down: depend-on-docker
	docker-compose -f docker-compose.yml down
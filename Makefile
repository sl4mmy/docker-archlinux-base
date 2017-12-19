NAME = archlinux-base
VERSION = 2017.12

DATE = `/bin/date +%Y-%m-%d`

DOCKER_FLAGS ?= --memory=4GB --rm=true
DOCKER_REPOSITORY ?= sl4mmy

all: Dockerfile
	docker build --rm=true --tag="$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)" $(DOCKER_FLAGS) .

Dockerfile: Dockerfile.in
	sed "s/\$${VERSION}/$(VERSION)/;s/\$${DATE}/$(DATE)/" $(<) >$(@)

attach:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-attach" --entrypoint=/bin/bash "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

run:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-run" "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

clean:
	-rm Dockerfile

.PHONY: all attach clean run

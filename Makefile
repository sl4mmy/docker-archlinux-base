NAME = archlinux-base
VERSION = `/bin/date +%Y.%m`

DATE = `/bin/date +%Y-%m-%d`

COUNTRY ?= United States

DOCKER_FLAGS ?= --memory=4GB --rm=true
DOCKER_REPOSITORY ?= sl4mmy

all: Dockerfile Dockerfile.multilib
	docker build --rm=true --tag="$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)" $(DOCKER_FLAGS) .
	docker build --rm=true --tag="$(DOCKER_REPOSITORY)/$(NAME)-multilib:$(VERSION)" $(DOCKER_FLAGS) -f Dockerfile.multilib .

Dockerfile: Dockerfile.in
	sed "s/\$${VERSION}/$(VERSION)/; s/\$${DATE}/$(DATE)/; s/\$${COUNTRY}/$(COUNTRY)/" $(<) >$(@)

Dockerfile.multilib: Dockerfile.in
	sed "s/^FROM archlinux\\/base/FROM $(DOCKER_REPOSITORY)\\/$(NAME):$(VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${DATE}/$(DATE)/; s/\$${COUNTRY}/$(COUNTRY)/; /^# Enable multilib repository/,/^# RUN / s/^# RUN/RUN/" $(<) >$(@)

attach:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-attach" --entrypoint=/bin/bash "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

refresh: Dockerfile.in
	sed "s/\$${VERSION}/$(VERSION)/; s/\$${DATE}/$(DATE)/; s/\$${COUNTRY}/$(COUNTRY)/" $(<) >Dockerfile
	sed "s/^FROM archlinux\\/base/FROM $(DOCKER_REPOSITORY)\\/$(NAME):$(VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${DATE}/$(DATE)/; s/\$${COUNTRY}/$(COUNTRY)/; /^# Enable multilib repository/,/^# RUN / s/^# RUN/RUN/" $(<) >Dockerfile.multilib
	$(MAKE)

run:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-run" "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

clean:
	-rm Dockerfile Dockerfile.multilib

.PHONY: all attach clean refresh run

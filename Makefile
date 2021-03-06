# Copyright (c) 2017-2018 Kent R. Spillner <kspillner@acm.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

NAME = archlinux-base
VERSION = `/bin/date +%Y.%m`

DATE = `/bin/date +%Y-%m-%d`

COUNTRY ?= United States

DOCKER_FLAGS ?= --memory=4GB --rm=true
DOCKER_REPOSITORY ?= sl4mmy

all: Dockerfile Dockerfile.multilib
	docker build --rm=true --tag="$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)" $(DOCKER_FLAGS) .
	docker build --rm=true --tag="$(DOCKER_REPOSITORY)/$(NAME)-multilib:$(VERSION)" $(DOCKER_FLAGS) -f Dockerfile.multilib .

Dockerfile: Dockerfile.in Makefile
	sed "s/\$${VERSION}/$(VERSION)/; s/\$${DATE}/$(DATE)/; s/\$${COUNTRY}/$(COUNTRY)/" $(<) >$(@)

Dockerfile.multilib: Dockerfile.in Makefile
	sed "s/^FROM archlinux\\/base$$/FROM $(DOCKER_REPOSITORY)\\/$(NAME):$(VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${DATE}/$(DATE)/; s/\$${COUNTRY}/$(COUNTRY)/; /^# Enable multilib repository$$/,/^# RUN / s/^# RUN/RUN/" $(<) >$(@)

attach:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-attach" --entrypoint=/bin/bash "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

refresh: Dockerfile.in
	sed "s/\$${VERSION}/$(VERSION)/; s/\$${DATE}/$(DATE)/; s/\$${COUNTRY}/$(COUNTRY)/" $(<) >Dockerfile
	sed "s/^FROM archlinux\\/base$$/FROM $(DOCKER_REPOSITORY)\\/$(NAME):$(VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${DATE}/$(DATE)/; s/\$${COUNTRY}/$(COUNTRY)/; /^# Enable multilib repository/,/^# RUN / s/^# RUN/RUN/" $(<) >Dockerfile.multilib
	$(MAKE)

run:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-run" "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

clean:
	-rm -f Dockerfile Dockerfile.multilib

.PHONY: all attach clean refresh run

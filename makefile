#!/usr/bin/make -f

include makefile.config

.PHONY: build debug default logs remove run shell start status stop

default: build

build:
	docker build --force-rm=true --tag=$(registry)/$(image):$(tag) $(ARGS) .

debug:
	docker run \
		--name=$(name) \
		--tty=true \
		$(runargs) \
		$(registry)/$(image):$(tag) \
		$(ARGS)

logs:
	docker logs --follow=true $(ARGS) $(name)

remove:
	docker rm --volumes=true $(ARGS) $(name)

run:
	docker run \
		--detach=true \
		--name=$(name) \
		--tty=true \
		$(runargs) \
		$(registry)/$(image):$(tag) \
		$(ARGS)

shell:
	docker exec --interactive=true --tty=true $(name) /bin/login -f root -p $(ARGS)

start:
	docker start $(ARGS) $(name)

status:
	docker ps $(ARGS) --all=true --filter=name=$(name)

stop:
	docker stop $(ARGS) $(name)


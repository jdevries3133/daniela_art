# Copyright (C) 2021 John DeVries

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


# --- Shortcuts for building and shipping the docker container. ---
#
# `push` is the only rule with dependencies (clean -> build -> test).
# Building the container takes a long time, so we don't necessarily want
# other rules to be dependent on the build rule. Just keep in mind that if you
# *never* have run `make build`, then the other rules won't work!


DOCKER_ACCOUNT=jdevries3133
CONTAINER_NAME=danart

TAG?=$(shell git describe --tags)

# assuming the use of Docker hub, these constants need not be changed
CONTAINER=$(DOCKER_ACCOUNT)/$(CONTAINER_NAME):$(TAG)


.PHONY: run
run: build
	docker run -d -p 8000:80 -v $(PWD)/public:/usr/share/nginx/html $(CONTAINER)


.PHONY: build
build:
	docker build -t $(CONTAINER) .


.PHONY: push
push:
	docker buildx build --platform linux/amd64 --push -t $(CONTAINER) .


.PHONY: deploy
deploy: push
ifdef CI
	terraform init -input=false
endif
	terraform apply -auto-approve

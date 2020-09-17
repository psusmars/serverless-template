## FILL IN THESE VARIABLES
SERVERLESS_TEMPLATE=//TEMPLATE#ex: aws-python3
SERVERLESS_NAME=//NAME#ex: happy-go-fun-time note: you can only use alphanumerical characters and hyphens
##

DOCKER_TAG=<FILLMEIN>/lambda-$(SERVERLESS_NAME)
AWS_ENVS=--env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) --env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
DIR_MAPPING=-v `pwd`:/src
DOCKER_USER="$(shell id -u):$(shell id -g)"

.PHONY: build run setup install_plugins local_deploy serverless_create serverless_remove serverless_plugin_management docker_image_name echo_remote_invoke echo_local correct_permissions

build:
	docker build -t $(DOCKER_TAG) \
		.
run:
	docker run -it --rm $(DIR_MAPPING) \
		--entrypoint="/bin/bash" \
		$(AWS_ENVS) \
		$(DOCKER_TAG)

setup: build serverless_create correct_permissions
	@echo "Finished with setup"

install_plugins: build
	docker run --rm -it $(DIR_MAPPING) $(DOCKER_TAG) serverless plugin install --name serverless-python-requirements

local_deploy: build
	docker run --rm -it $(AWS_ENVS) $(DOCKER_TAG) serverless deploy

serverless_create: build
	docker run --rm -it $(DIR_MAPPING) $(DOCKER_TAG) serverless create --template $(SERVERLESS_TEMPLATE) --name $(SERVERLESS_NAME)
	@echo "BE SURE TO CHECK YOUR serverless.yml"

serverless_invoke: build
	docker run --rm -it $(AWS_ENVS) $(DOCKER_TAG) serverless invoke --log

serverless_remove: build
	docker run --rm -it $(DOCKER_TAG) serverless remove

serverless_plugin_management: build
	docker run -it --rm $(DIR_MAPPING) \
		--entrypoint="/bin/bash" \
		$(AWS_ENVS) \
		$(DOCKER_TAG)

correct_permissions:
	sudo chown -R $(DOCKER_USER) * .gitignore

echo_local:
	@echo "The line that follows will be how to invoke your local code"
	@echo "docker run --rm -it $(DOCKER_TAG) serverless invoke local --function YOURFUNCTIONNAME"

echo_remote_invoke:
	@echo "The line that follows will be how to invoke your remote code"
	@echo "docker run --rm -it $(AWS_ENVS) $(DOCKER_TAG) serverless invoke --function YOURFUNCTIONNAME"

docker_image_name:
	@echo $(DOCKER_TAG)
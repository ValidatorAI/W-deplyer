ANSIBLE_CONFIG ?= ./W.cfg
ANSIBLE_ARGS ?=
EXTRA_VARS ?=
PLAYBOOK_CMD = ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook $(ANSIBLE_ARGS) $(EXTRA_VARS)

.PHONY: deps docker traefik openviking hermes registry-login pull-w-bridge run-w-bridge run-campfire deploy-campfire deploy-all

deps:
	ansible-galaxy collection install -r requirements.yml

docker:
	$(PLAYBOOK_CMD) playbooks/install_docker.yml

traefik:
	$(PLAYBOOK_CMD) playbooks/install_traefik.yml

openviking:
	$(PLAYBOOK_CMD) playbooks/install_openviking.yml

hermes:
	$(PLAYBOOK_CMD) playbooks/install_hermes.yml

registry-login:
	$(PLAYBOOK_CMD) playbooks/docker_registry_login.yml

pull-w-bridge:
	$(PLAYBOOK_CMD) playbooks/pull_w_bridge_image.yml

run-w-bridge:
	$(PLAYBOOK_CMD) playbooks/run_w_bridge_container.yml

run-campfire:
	$(PLAYBOOK_CMD) playbooks/run_campfire_container.yml

deploy-campfire:
	$(PLAYBOOK_CMD) playbooks/deploy_campfire.yml

deploy-all:
	$(PLAYBOOK_CMD) playbooks/site.yml

run-base-image:
	docker run -d --name my-ubuntu --privileged --cgroupns=host dokken/ubuntu-26.04 sleep infinity

stop-delete-my-ubuntu:
	docker stop my-ubuntu || true
	docker rm my-ubuntu || true
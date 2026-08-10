ANSIBLE_CONFIG ?= ./W.cfg
PLAYBOOK_CMD = ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) ansible-playbook

.PHONY: deps docker traefik hermes registry-login pull-w-bridge run-w-bridge deploy-all

deps:
	ansible-galaxy collection install -r requirements.yml

docker:
	$(PLAYBOOK_CMD) playbooks/install_docker.yml

traefik:
	$(PLAYBOOK_CMD) playbooks/install_traefik.yml

hermes:
	$(PLAYBOOK_CMD) playbooks/install_hermes.yml

registry-login:
	$(PLAYBOOK_CMD) playbooks/docker_registry_login.yml

pull-w-bridge:
	$(PLAYBOOK_CMD) playbooks/pull_w_bridge_image.yml

run-w-bridge:
	$(PLAYBOOK_CMD) playbooks/run_w_bridge_container.yml

deploy-all:
	$(PLAYBOOK_CMD) playbooks/site.yml

run-base-image:
	docker run -d --name my-ubuntu --privileged --cgroupns=host dokken/ubuntu-26.04 sleep infinity

stop-delete-my-ubuntu:
	docker stop my-ubuntu || true
	docker rm my-ubuntu || true
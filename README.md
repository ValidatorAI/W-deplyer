# W-deplyer

Ansible-based deployer for W infrastructure.

## Playbooks

The repository now has dedicated playbooks for each step:

1. Install Docker: `playbooks/install_docker.yml`
2. Install Traefik (Docker Compose): `playbooks/install_traefik.yml`
3. Install Hermes: `playbooks/install_hermes.yml`
4. Log in to custom Docker registry: `playbooks/docker_registry_login.yml`
5. Pull `w-bridge:latest`: `playbooks/pull_w_bridge_image.yml`
6. Run `w-bridge` container: `playbooks/run_w_bridge_container.yml`

Also included:
- Full orchestrator: `playbooks/site.yml`
- Required collection list: `requirements.yml`

## Quick Start

1. Configure inventory in `inventory/W.ini`.
2. Install Ansible collections:

```bash
make deps
```

3. Run all steps:

```bash
make deploy-all
```

Or run one step at a time:

```bash
make docker
make traefik
make hermes
make registry-login
make pull-w-bridge
make run-w-bridge
```

## Runtime Variables

Common variables you should override:

- `docker_registry_url`
- `docker_registry_username`
- `docker_registry_password`
- `w_bridge_registry`
- `w_bridge_image_name` (default: `w-bridge`)
- `w_bridge_image_tag` (default: `latest`)
- `w_bridge_ports` (example: `["8080:8080"]`)

Example:

```bash
ANSIBLE_CONFIG=./W.cfg ansible-playbook playbooks/pull_w_bridge_image.yml \
	-e "w_bridge_registry=my-registry.example.com"
```

## Secret .env File: Secure Options

There are two supported ways to provide the container `.env` file in `playbooks/run_w_bridge_container.yml`.

### Option A: Ansible Vault (recommended)

1. Create an encrypted vars file:

```bash
ansible-vault create group_vars/w_servers/vault.yml
```

2. Add secrets inside:

```yaml
docker_registry_username: your-user
docker_registry_password: your-pass
w_bridge_env_content: |
	APP_ENV=production
	APP_KEY=super-secret-value
```

3. Run playbook with vault password:

```bash
ANSIBLE_CONFIG=./W.cfg ansible-playbook playbooks/site.yml --ask-vault-pass
```

### Option B: Download from secret URL

Use `secret_env_source=url` and provide `secret_env_url`.

```bash
ANSIBLE_CONFIG=./W.cfg ansible-playbook playbooks/run_w_bridge_container.yml \
	-e "secret_env_source=url" \
	-e "secret_env_url=https://example.com/secure/w-bridge.env"
```

If your endpoint needs headers/tokens, pass `secret_env_headers` from vaulted vars so tokens are not exposed in shell history.

## Notes

- `playbooks/install_hermes.yml` expects `hermes_binary_url` when `hermes_install_method=binary`.
- For local Docker test target:

```bash
docker run -d --name my-ubuntu dokken/ubuntu-26.04 sleep infinity
```
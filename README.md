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

## Password Prompts (Vault / Sudo)

Use Makefile passthrough args when Ansible needs a password prompt.

Prompt for Ansible Vault password:

```bash
make deploy-all ANSIBLE_ARGS='--ask-vault-pass'
```

Prompt for sudo/become password:

```bash
make deploy-all ANSIBLE_ARGS='--ask-become-pass'
```

Prompt for both:

```bash
make deploy-all ANSIBLE_ARGS='--ask-vault-pass --ask-become-pass'
```

You can combine these with variables, for example:

```bash
make hermes ANSIBLE_ARGS='--ask-vault-pass' EXTRA_VARS='-e hermes_api_server_key=YOUR_KEY'
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

1. Fill project secret files:

```bash
vi .ansible/vault-pass.txt
vi group_vars/w_servers/vault.yml
```

2. Encrypt vars file:

```bash
ansible-vault encrypt group_vars/w_servers/vault.yml
```

3. If you need to edit secrets later:

```bash
ansible-vault edit group_vars/w_servers/vault.yml
```

4. Run playbook (password is read from .ansible/vault-pass.txt via W.cfg):

```bash
make deploy-all
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

- `playbooks/install_hermes.yml` deploys Hermes as a Docker container (`nousresearch/hermes-agent gateway run`) with `~/.hermes` mounted to `/opt/data`.
- Provide only `hermes_api_server_key` via vars/inventory/extra-vars; other API server flags are set by the playbook.
- For local Docker test target:

```bash
docker run -d --name my-ubuntu dokken/ubuntu-26.04 sleep infinity
```

‍‍‍```bash
make hermes EXTRA_VARS='-e hermes_api_server_key=YOUR_KEY -e deepseek_api_key=sk-'
```
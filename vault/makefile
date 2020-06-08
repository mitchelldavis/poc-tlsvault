# In order to run these actions, you need to create an ssh tunnel to the vault server.

VALUES_FILE?=vault-values.yaml

.PHONY: install
install:
	helm install -f ${VALUES_FILE} vault hashicorp/vault --namespace vault --create-namespace
.PHONY: upgrade
upgrade:
	helm upgrade -f ${VALUES_FILE} vault hashicorp/vault --namespace vault
.PHONY: uninstall
uninstall:
	helm uninstall vault --namespace vault
.PHONY: vault_init
vault_init:
	kubectl exec vault-0 -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
.PHONY: vault_unseal
vault_unseal:
	kubectl exec vault-0 -n vault -- vault operator unseal $(shell cat cluster-keys.json | jq -r ".unseal_keys_b64[]")

.PHONY: terraform_init
terraform_init:
	terraform init
.PHONY: terraform_apply
terraform_apply:
	export VAULT_TOKEN=$(shell cat cluster-keys.json | jq -r '.root_token') && \
	export VAULT_ADDR=http://127.0.0.1:8200 && \
	terraform apply --auto-approve
.PHONY: terraform_destroy
terraform_destroy:
	export VAULT_TOKEN=$(shell cat cluster-keys.json | jq -r '.root_token') && \
	export VAULT_ADDR=http://127.0.0.1:8200 && \
	terraform destroy -force
.PHONY: vault_setsecret
vault_setsecret:
	export VAULT_TOKEN=$(shell cat cluster-keys.json | jq -r '.root_token') && \
	export VAULT_ADDR=http://127.0.0.1:8200 && \
	vault kv put secret/database/config username=databaseUsername password=databasePassword


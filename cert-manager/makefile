all: install

.PHONY: install
install:
	helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --values cert-manager-values.yaml
.PHONY: uninstall
uninstall:
	helm uninstall cert-manager --namespace cert-manager 
.PHONY: upgrade
upgrade:
	helm upgrade cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --values cert-manager-values.yaml
.PHONY: apply
apply:
	kubectl apply -f vault_issuer.yaml --namespace cert-manager
	kubectl apply -f vault_cert.yaml --namespace vault
.PHONY: delete
delete:
	kubectl delete -f vault_issuer.yaml --namespace cert-manager
	kubectl delete -f vault_cert.yaml --namespace vault


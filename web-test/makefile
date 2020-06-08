all: apply

.PHONY: apply
apply:
	kubectl get namespace | grep web-test || kubectl create namespace web-test
	kubectl get secrets -n web-test | grep vault-ca || kubectl get secret vault-ca --namespace=vault -oyaml | sed 's/namespace: vault/namespace: web-test/g' | kubectl apply --namespace=web-test -f -
	kubectl apply -f webapp.yaml -n web-test
.PHONY: delete
delete:
	kubectl delete -f webapp.yaml -n web-test

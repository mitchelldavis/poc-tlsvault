all: install

.PHONY:
install:
	helm install -f consul-values.yaml hashicorp hashicorp/consul --namespace consul --create-namespace
	kubectl wait --for=condition=Ready pods/consul-server-0 -n consul

.PHONY: prep
prep:
	export GOSSIP_KEY=$(shell consul keygen)
	kubectl get namespaces | grep consul || kubectl create namespace consul
	kubectl get secrets -n consul | grep consul-gossip-key || kubectl create secret generic consul-gossip-key --from-literal=key=${GOSSIP_KEY} -n consul
.PHONY: cert-manager
cert-manager:
	cd cert-manager && $(MAKE)
.PHONY: vault
vault:
	cd vault && $(MAKE)
.PHONY: consul
consul:
	cd consul && $(MAKE)
.PHONY: web-test
web-test:
	cd web-test && $(MAKE)

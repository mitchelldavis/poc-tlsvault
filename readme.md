# Vault TLS with Consul mTls

---

##The What

While researching how to get AWS EKS ready for production, we decided on the following requirements:

- We'll use Vault for Secret's Management.  Not only will it handle secrets securely, it can provide dynamic secrets for things such as other cloud providers.  This allows us to support cloud agnostic deployments.
- We'll use Consul Connect for mTls and cluster to cluster communication.  We need to isolate Vault in it's own EKS cluster, and Consul's [Mesh Gateways](https://www.consul.io/docs/connect/mesh_gateway) allow us to have completely isolated clusters and still maintain the service mesh.

One of the main Production ready requirements for Hashicorp [Vault](https://www.vaultproject.io/) is to make sure you use End-to-end TLS encryption for everything communicating with Vault.  So, while researching [Consul](https://consul.io) and Vault in Kubernetes, you learn about [Connect](https://www.consul.io/docs/connect) which has mTls and is super secure.  Cool, so, instead of dealing with certificates in Kubernetes, can we just use Consul Connect to manage our end-to-end encryption?

It turns out it's not that easy.

We can use Connect for service to service communication but anything that happens in [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) cannot use Connect.  The Connect sidecar isn't ready until after the Init Containers are done.  Wait, doesn't [Vault's Secrets Injector](https://www.vaultproject.io/docs/platform/k8s/injector) run in Init stages?  Well, yes and no.  It can inject secrets in the init stage, but also runs a sidecar that keeps secrets up to date.  However, if the Init Container can't communicate with Vault, Pods that need secrets injected won't start.  This causes Vault's quasi-default Helm deployment to need TLS certificate managment because the Secrets Injector communicates with vault before Connect is available in Pods.

So, we need TLS management on top of Consul Connect which produces another requirement.

- Vault [PKI](https://www.vaultproject.io/docs/secrets/pki) will be the TLS authority for communicating with Vault outside of Consul Connect.  We can use [Cert-Manager](https://cert-manager.io/) to handle the certificate issuing and automate the process.

---

##The Why

After scouring the internet for days, I was unable to find a walkthrough on how to use Hashicorp's Consul and Vault Helm charts to accomplish a setup with the requirements we had.  So, I wanted to make this available for anyone else who's requirements are similar.

---

##The How

---

###Start Minikube

```
minikube start --memory 8192
```

###Start Minikube Dashboard

```
minikube dashboard
```

This will bring up the kubernetes dashboard for minikube.

###Prep the Cluster

We need to make sure that a Gossip Encryption key is created so that Consul can use it.

*NOTE*: any future configuration that needs to run first should run in this step.

```
make prep
```

###Deploy Consul

```
make consul
```

We need to make sure that Consul Connect allows connections to Vault from Cert-Manager. The following extracts the bootstrap ACL token that is needed to communicate with Consul.  (This should only be used for bootstrap activities like this.)  Then it creates the needed connect intention.

```
ACL_TOKEN=$(kubectl get secret/consul-bootstrap-acl-token -n consul -o json | jq -r '.data.token' | base64 -d)
kubectl exec pod/consul-server-0 -n consul -- /bin/sh -c \
    "export CONSUL_HTTP_TOKEN=$ACL_TOKEN && consul intention create cert-manager vault"
```

###Deploy Vault

```
cd vault
make install VALUES_FILE=vault-values-init.yaml
```

Wait for the events on the vault-0 pod to show that it can't go any further because it needs to be initialized. It should say something like `Seal Type shamir Initialized false Sealed true` in the pod events.

The `vault_init` action will only need to be ran once, or as long as the `data-vault-0` Persistent Volume Claim exists between vault installs.

The `vault_unseal` will need to be ran every time we uninstall then reinstall vault.

```
make vault_init
make vault_unseal
```

That will initialize and unseal the vault server.  In a sepperate window run:

```
kubectl port-forward -n vault service/vault 8200:8200
```

This will open up a connection on port `8200` to the vault server so we can run the next command:

```
make teraform_init
make terraform_apply
make vault_setsecret
```

After we are done with this stage of vault configuration, we create a secret that can be accessed within the `default` namespace and has the vault ca.  Once it's available all services within the `default` namespace will be able to use it to securely communicate with vault.  When we're done exit from the directory.

```
export VAULT_CA=$(curl http://127.0.0.1:8200/v1/pki_vault/ca/pem)
kubectl create secret generic vault-ca -n vault --dry-run --from-literal=vault-ca.pem=$VAULT_CA -o yaml | kubectl apply -f -
cd ..
```

###Deploy Cert-Manager

```
cd cert-manager
make install
```

The ClusterIssuer needs the Cert-Manager service account token in order to authenticate with vault. However, the secret's name is random so we need to search for it then we apply the ClusterIssuer.

```
export SECRET=$(kubectl get sa/cert-manager -n cert-manager -o json | jq -r '.secrets[0].name')
cat vault_issuer.yaml | sed "s/<cert-manager-secret>/$SECRET/g" | kubectl apply -f -
kubectl apply -f vault_cert.yaml
cd ..
```

At this point, the Vault certificate should be ready to go. So we need to upgrade the vault helm chart with new values.

###Upgrade Vault

```
cd vault
make upgrade VALUES_FILE=vault-values.yaml
kubectl scale sts vault -n vault --replicas=0

# Wait for the vault pods to be removed.

kubectl scale sts vault -n vault --replicas=1

# Wait for the events on the vault-0 pod to show that 
# it can't go any further because it needs to be initiated.  
# It should say something like `Seal Type shamir Initialized 
# false Sealed true` in the pod events.

make vault_unseal
cd ..
```

At this point, Vault should be ready to go with Mtls through Consul Connect and TLS over it's http endpoint. You can test it by deploying the Web-Test application.

###Deploy Web-Test

```
cd web-test
make apply
```

You should be able to get into the pod and view the contents of the secret file.

```
# This will get the pod name

kubectl get pods -n web-test

# Copy the pod name into the next line

kubectl exec -n web-test pod/<pod name> -- cat /vault/secrets/database-config.txt
```

The output should be something like:

```
data: map[password:databasePassword username:databaseUsername]
```

Congrats.  It works!

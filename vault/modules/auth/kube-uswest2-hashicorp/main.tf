data "kubernetes_service_account" "_" {
  metadata {
    name = "vault"
    namespace = "vault"
  }
}

data "kubernetes_secret" "_" {
  metadata {
    name = data.kubernetes_service_account._.default_secret_name
    namespace = "vault"
  }
}

resource "vault_auth_backend" "_" {
  type = "kubernetes"
  path = "kube-uswest2-hashicorp"
  description = "This authentication backed uses the us-west-2 hashicorp kubernetes cluster to authenticate pods."
  #tune {
  #  default_lease_ttl = "3600s"
  #  max_lease_ttl = "43200s"
  #}
  default_lease_ttl_seconds = "3600"
  max_lease_ttl_seconds = "43200"
}

resource "vault_kubernetes_auth_backend_config" "_" {
  backend            = vault_auth_backend._.path
  kubernetes_host    = "https://172.17.0.3:8443"
  kubernetes_ca_cert = file("/home/mitch/.minikube/ca.crt")
  token_reviewer_jwt = data.kubernetes_secret._.data["token"]
}

resource "vault_kubernetes_auth_backend_role" "web-test" {
  backend                          = vault_auth_backend._.path
  role_name                        = "web-test"
  bound_service_account_names      = ["web-test"]
  bound_service_account_namespaces = ["web-test"]
  token_ttl                        = 3600
  token_policies                   = ["default", "admin"]
}

resource "vault_kubernetes_auth_backend_role" "cert-manager" {
  backend                          = vault_auth_backend._.path
  role_name                        = "cert-manager"
  bound_service_account_names      = ["cert-manager"]
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  token_policies                   = ["default", "admin", "pki_vault_admin"]
}

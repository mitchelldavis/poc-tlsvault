variable "data_root" {
  type  = "string"
}

variable "root_path" {
  type  = "string"
}

variable "path" {
  type    = "string"
  default = "pki_root"
}

variable "description" {
  type    = "string"
  default = "This is the Intermediate CA for Vault HTTPS communication"
}

resource "vault_mount" "_" {
  path        = "${var.path}"
  type        = "pki"
  description = "${var.description}"
  default_lease_ttl_seconds = 86400 # One Day
  max_lease_ttl_seconds = 157680000 # 5 Years
}

resource "vault_pki_secret_backend_intermediate_cert_request" "_" {
  backend = "${vault_mount._.path}"
  type = "internal"
  common_name = "vault Intermediate Authority"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "_" {
  backend = "${var.root_path}"
  csr = "${vault_pki_secret_backend_intermediate_cert_request._.csr}"
  common_name = "vault Intermediate CA"
  exclude_cn_from_sans = true
  ou = "SRFC Holdings"
  organization = "Engineering"
  ttl = 315360000
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" { 
  backend = "${vault_mount._.path}"
  certificate = "${vault_pki_secret_backend_root_sign_intermediate._.certificate}"
}

resource "vault_pki_secret_backend_role" "vault" {
  backend = "${vault_mount._.path}"
  name    = "vault"
  allowed_domains   = ["vault", "svc", "local", "localhost"]
  allow_localhost   = true
  allow_subdomains  = true
  allow_bare_domains = true
  ttl               = "24h"
  max_ttl           = "720h"
}

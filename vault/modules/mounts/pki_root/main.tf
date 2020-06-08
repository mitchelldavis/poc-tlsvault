variable "data_root" {
  type  = "string"
}

variable "path" {
  type    = "string"
  default = "pki_root"
}

variable "description" {
  type    = "string"
  default = "This is the root CA"
}

resource "vault_mount" "_" {
  path        = "${var.path}"
  type        = "pki"
  description = "${var.description}"
  default_lease_ttl_seconds = 86400 # One Day
  max_lease_ttl_seconds = 315360000 # Ten Years
}

resource "vault_pki_secret_backend_root_cert" "_" {
  backend = "${vault_mount._.path}"

  type = "internal"
  common_name = "Root CA"
  ttl = "315360000"
  format = "pem"
  private_key_format = "der"
  key_type = "rsa"
  key_bits = 4096
  exclude_cn_from_sans = true
  ou = "SRFC Holdings"
  organization = "Engineering"
}

resource "vault_pki_secret_backend_config_urls" "_" {
  backend                 = "${vault_mount._.path}"
  issuing_certificates    = ["http://127.0.0.1:8200/v1/pki/ca"]
  crl_distribution_points = ["http://127.0.0.1:8200/v1/pki/crl"]
}

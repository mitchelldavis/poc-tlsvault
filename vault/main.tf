module "policies" {
  source    = "./modules/sys/policy"
  data_root = "${abspath("./data")}"
}

module "secret" {
  source    = "./modules/mounts/secret"
}

module "pki_root" {
  source    = "./modules/mounts/pki_root"
  data_root = "${abspath("./data")}"
}

module "pki_vault" {
  source    = "./modules/mounts/pki_vault"
  data_root = "${abspath("./data")}"
  path      = "pki_vault"
  root_path = "pki_root"
}

module "kube" {
  source = "./modules/auth/kube-uswest2-hashicorp"
}

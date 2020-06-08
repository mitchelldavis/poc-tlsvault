variable "data_root" {
  type  = "string"
}

locals {
  policies = fileset(var.data_root, "sys/policy/*.hcl")
}

resource "vault_policy" "_" {
  for_each  = local.policies
  name      = "${split(".", basename(each.key))[0]}"
  policy    = "${file(join("/", [abspath(var.data_root), each.key]))}"
}

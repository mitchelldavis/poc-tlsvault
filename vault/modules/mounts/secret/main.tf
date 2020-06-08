resource "vault_mount" "example" {
  path        = "secret"
  type        = "kv-v2"
  description = "This is the general secrets key-value store"
}

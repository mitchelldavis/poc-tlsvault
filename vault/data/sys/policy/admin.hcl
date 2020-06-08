# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

# Manage audit engines
path "sys/audit/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing audit engines.
path "sys/audit"
{
  capabilities = ["read", "list", "sudo"]
}

# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# Enable provisioning of secrets
path "aws/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Enable provisioning of secrets
path "aws_comptel/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

resource "boundary_credential_store_vault" "vault_creds" {
  name        = "Vault Creds"
  description = "Vault credential store"
  address     = var.VAULT_ADDR
  token       = var.VAULT_TOKEN
  scope_id    = boundary_scope.project.id
  namespace   = "admin"
}

resource "boundary_credential_library_vault_ssh_certificate" "vault_lib" {
  name                = "Vault Library"
  description         = "Vault SSH certificate credential library"
  credential_store_id = boundary_credential_store_vault.vault_creds.id
  path                = "ssh/sign/ssh_role"
  username            = "ubuntu"
}
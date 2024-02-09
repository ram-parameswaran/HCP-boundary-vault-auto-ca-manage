terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.25.0"
    }
  }
}

# Use Vault provider.
provider "vault" {
  skip_tls_verify = true
  address = var.VAULT_ADDR
  token = var.VAULT_TOKEN
}

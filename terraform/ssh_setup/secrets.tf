#----------------------------------------------------------
# Enable secrets engines
#----------------------------------------------------------

#--------------------------------
# Enable ssh secret engine
#--------------------------------

# Enable the ssh mount
resource "vault_mount" "ssh" {
    type = "ssh"
    path = "ssh"
}

# Create the ssh CA
resource "vault_ssh_secret_backend_ca" "ssh_ca" {
    backend = vault_mount.ssh.path
    generate_signing_key = true
}

# Create the role
resource "vault_ssh_secret_backend_role" "ssh_role" {
    name                    = "ssh_role"
    backend                 = vault_mount.ssh.path
    key_type                = "ca"
    allow_user_certificates = true
    default_user  = "ubuntu"
    allowed_users = "ubuntu"
    default_extensions      = {"permit-pty" = ""}
}

# create a kvv2 secret mount
resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
  depends_on = [vault_ssh_secret_backend_role.ssh_role]
}

# Create a kvv2 secret containing the public key
resource "vault_kv_secret_v2" "public_key" {
  mount                      = vault_mount.kvv2.path
  name                       = "secret"
  data_json                  = jsonencode(
  {
    public_key       = vault_ssh_secret_backend_ca.ssh_ca.public_key
  }
  )
  lifecycle {
    replace_triggered_by = [
      vault_ssh_secret_backend_ca.ssh_ca
    ]
  }
}

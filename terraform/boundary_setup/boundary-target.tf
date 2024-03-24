resource "boundary_target" "ssh_foo" {
  name         = "demo_target"
  description  = "Demo target"
  type         = "ssh"
  default_port = "22"
  scope_id     = boundary_scope.project.id
  host_source_ids = [
    boundary_host_set_plugin.aws_host_set_demo.id
  ]
  injected_application_credential_source_ids = [
    boundary_credential_library_vault_ssh_certificate.vault_lib.id
  ]
}
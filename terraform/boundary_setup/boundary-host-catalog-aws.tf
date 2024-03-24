resource "boundary_host_catalog_plugin" "aws_demo" {
  name            = "AWS hosts"
  description     = "Dynamic AWS hosts"
  scope_id        = boundary_scope.project.id
  plugin_name     = "aws"
  attributes_json = jsonencode({ "region" = var.AWS_REGION, "disable_credential_rotation" = true })
  secrets_json = jsonencode({
    "access_key_id"     = var.AWS_ACCESS_KEY_ID,
    "secret_access_key" = var.AWS_SECRET_ACCESS_KEY
  })
}

resource "boundary_host_set_plugin" "aws_host_set_demo" {
  name                = "Host set plugin"
  host_catalog_id     = boundary_host_catalog_plugin.aws_demo.id
  preferred_endpoints = ["dns:*.ap-southeast-2.compute.amazonaws.com"]
  attributes_json = jsonencode({
    "filters" = ["tag:application=dev", "tag:service-type=demo"]
  })
}
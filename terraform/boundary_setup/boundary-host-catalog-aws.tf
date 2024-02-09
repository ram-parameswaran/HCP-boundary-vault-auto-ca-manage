resource "boundary_host_catalog_plugin" "aws_demo" {
  name            = "AWS hosts"
  description     = "Dynamic AWS hosts"
  scope_id        = boundary_scope.project.id
  plugin_name     = "aws"
  attributes_json = jsonencode({ "region" = var.AWS_REGION, "disable_credential_rotation" = true })

  # recommended to pass in aws secrets using a file() or using environment variables
  # the secrets below must be generated in aws by creating a aws iam user with programmatic access
  secrets_json = jsonencode({
    "access_key_id"     = var.AWS_ACCESS_KEY_ID,
    "secret_access_key" = var.AWS_SECRET_ACCESS_KEY
  })
}

resource "boundary_host_set_plugin" "aws_host_set_demo" {
  name                = "My foobar host set plugin"
  host_catalog_id     = boundary_host_catalog_plugin.aws_demo.id
  attributes_json = jsonencode({
    "filters" = ["tag-key=dev", "tag-key=demo"]
  })
}
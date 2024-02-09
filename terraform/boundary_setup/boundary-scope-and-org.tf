resource "boundary_scope" "org" {
  name                     = "DemoOps"
  description              = "DemoOps Org scope"
  scope_id                 = "global"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "project" {
  name                   = "demo_one"
  description            = "Demo scope"
  scope_id               = boundary_scope.org.id
  auto_create_admin_role = true
}
resource "boundary_auth_method" "password" {
  scope_id = boundary_scope.org.id
  type     = "password"
}

resource "boundary_account_password" "jeff" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "jeff"
  password       = "123456789"
}

resource "boundary_account_password" "garry" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "garry"
  password       = "123456789"
}

resource "boundary_account_password" "scott" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "scott"
  password       = "123456789"
}

resource "boundary_account_password" "drevil" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "drevil"
  password       = "123456789"
}

resource "boundary_account_password" "miniit" {
  auth_method_id = boundary_auth_method.password.id
  login_name     = "miniit"
  password       = "123456789"
}

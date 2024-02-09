terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.14"
    }
  }
}

# Use Boundary provider.
provider "boundary" {
  addr = var.BOUNDARY_ADDR
  auth_method_login_name = var.BOUNDARY_USER
  auth_method_password = var.BOUNDARY_PASS
}

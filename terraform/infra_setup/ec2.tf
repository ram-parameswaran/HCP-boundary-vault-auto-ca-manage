variable "instances" {
  default = [
    "boundary-1", 
    "boundary-2", 
    "boundary-3", 
  ]
}

variable "vm_tags" {
  default = [
    {"Name":"boundary-1","service-type":"demo","application":"dev"},
    {"Name":"boundary-2","service-type":"demo","application":"dev"},
    {"Name":"boundary-3","service-type":"demo","application":"dev"},
  ]
}

resource "aws_instance" "boundary_instance" {
  depends_on             = [ data.hcp_packer_artifact.packer-github-actions-boundary ]
  count                  = length(var.instances)
  ami                    = data.hcp_packer_artifact.packer-github-actions-boundary.external_identifier
  instance_type          = "t2.micro"
  tags                   = var.vm_tags[count.index]
}
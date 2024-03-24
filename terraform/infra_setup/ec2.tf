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
  vpc_security_group_ids = [aws_security_group.boundary.id]
}

data "aws_vpc" "main" {
  default = true
}

resource "aws_security_group" "boundary" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "boundary-access-sg"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary.id
}

resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary.id
}

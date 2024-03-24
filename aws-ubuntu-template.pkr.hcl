packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "packer-github-actions-boundary"
}

variable "TRUSTED_CA" {
  type    = string
}

variable "HCP_BUCKET" {
  type    = string
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-southeast-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = [ "source.amazon-ebs.ubuntu" ]
  hcp_packer_registry {
    bucket_name = "${var.HCP_BUCKET}"
    bucket_labels = {
      "owner"          = "platform-team"
      "os"             = "Ubuntu",
      "ubuntu-version" = "Focal 20.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }
  provisioner "shell" {
    inline = [
      "echo Installing signed SSH ",
      "sleep 5",
      "echo ${var.TRUSTED_CA} > /tmp/trusted-user-ca-keys.pem",
      "sudo cp /tmp/trusted-user-ca-keys.pem /etc/ssh/trusted-user-ca-keys.pem",
      "rm /tmp/trusted-user-ca-keys.pem",
      "sudo bash -c \"echo 'TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem' | tee -a /etc/ssh/sshd_config\"",
    ]
  }

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
    versionFingerprint = packer.versionFingerprint
    }
  }
}

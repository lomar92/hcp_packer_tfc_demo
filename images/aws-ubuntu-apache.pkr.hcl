packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


variable "ami_prefix" {
  type    = string
  default = "WebService_Apache"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

source "amazon-ebs" "eu-central-1" {
  ami_name      = var.ami_prefix
  instance_type = "t2.micro"
  region        = var.region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "Apache_Image"
  sources = [
    "source.amazon-ebs.eu-central-1"
  ]

  hcp_packer_registry {
    bucket_name = "apache"
    description = <<EOT
    This image is a Apache Web Service running on ubuntu
        EOT
    labels = {
      "target-use" = "webservice",
      "apache" = "v2.0.",
      "os" = "ubuntu",
      "environment" = "dev/test",
    }
  }

  provisioner "shell" {
    inline = [
      "sudo apt -y update",
      "sleep 15",
      "sudo apt -y update",
      "sudo apt -y install apache2",
      "sudo systemctl start apache2",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
      "sudo apt -y install cowsay",
      "cowsay -f tux I am not a Cow!",
    ]
  }
  provisioner "file" {
    source      = "file/"
    destination = "/var/www/html"
  }
}


packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "apache_v2"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

#Variable for your AMI-Name -> AMI-Name are unique!
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "eu-central-1" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"

  tags = {
    Name = "lomar"
  }
  snapshot_tags = {
    Name = "lomar"
  }
}

build {
  name = "hashitalk"
  sources = [
    "source.amazon-ebs.eu-central-1"
  ]

  hcp_packer_registry {
    bucket_name = "hashitalk"
    description = <<EOT
    This image is a Apache Web Service running on ubuntu
        EOT
    labels = {
      "target-use" = "Website",
      "service"    = "apache_server",
      "os"         = "ubuntu_latest_version",
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
      "cowsay -f tux Look after your Apache version!",
      "apache2 -v"
    ]
  }

  provisioner "file" {
    source      = "file/"
    destination = "/var/www/html"
  }
}
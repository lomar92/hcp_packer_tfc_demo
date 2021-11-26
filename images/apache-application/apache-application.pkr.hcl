#This Code Config query a specific base image's build iteration and build a new image using that base image. 
#Then, you will update the base image's channel to point to another iteration, and rebuild the downstream image on top of the new base image. 

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
  default = "apache_v2"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

#Put this local Variable for your AMI-Name to make it unique -> AMI-Name are always unique in AWS!
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

data "hcp-packer-iteration" "apache" {
  bucket_name = "apache"
  channel     = "production"
}

data "hcp-packer-image" "apache-image" {
  bucket_name    = "apache"
  iteration_id   = data.hcp-packer-iteration.apache.id
  cloud_provider = "aws"
  region         = "eu-central-1"
}

source "amazon-ebs" "eu-central-1" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  source_ami    = data.hcp-packer-image.apache-image.id
  instance_type = "t2.micro"
  region        = var.region
  ssh_username  = "ubuntu"

  tags = {
    Name = "lomar"
  }
  snapshot_tags = {
    Name = "lomar"
  }
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
      "target-use" = "Website",
      "service"    = "apache_server",
      "os"         = "ubuntu_latest_version",
    }
  }
}
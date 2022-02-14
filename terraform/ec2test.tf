provider "aws" {
  region = var.region
}

#Specify HCP Provider and HCP Packer Iteration
provider "hcp" {
}

resource "aws_vpc" "hashitalk" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "${var.environment}-vpc-${var.region}"
  }
}

resource "aws_subnet" "hashitalk" {
  vpc_id     = aws_vpc.hashitalk.id
  cidr_block = var.subnet_prefix

  tags = {
    name = "${var.environment}-subnet"
  }
}

resource "aws_security_group" "hashitalk" {
  name = "${var.environment}-security-group"

  vpc_id = aws_vpc.hashitalk.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.environment}-security-group"
  }
}

resource "aws_internet_gateway" "hashitalk" {
  vpc_id = aws_vpc.hashitalk.id

  tags = {
    Name = "${var.environment}-internet-gateway"
  }
}

resource "aws_route_table" "hashitalk" {
  vpc_id = aws_vpc.hashitalk.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hashitalk.id
  }
}

resource "aws_route_table_association" "hashitalk" {
  subnet_id      = aws_subnet.hashitalk.id
  route_table_id = aws_route_table.hashitalk.id
}

data "hcp_packer_iteration" "hashitalk" {
  bucket_name = var.bucket
  channel     = var.channel
}

data "hcp_packer_image" "hashitalk-image" {
  bucket_name    = var.bucket
  iteration_id   = data.hcp_packer_iteration.hashitalk.ulid
  cloud_provider = "aws"
  region         = var.region
}
resource "aws_instance" "hashitalk" {
  ami                         = data.hcp_packer_image.hashitalk-image.cloud_image_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.hashitalk.id
  vpc_security_group_ids      = [aws_security_group.hashitalk.id]

  tags = {
    Name = "${var.environment}-hashitalk-instance"
  }
}

output "WebService" {
  description = "Public IP of your EC2 instance"
  value       = aws_instance.hashitalk.public_ip
}

output "hashitalk-image-id" {
  value = data.hcp_packer_image.hashitalk-image.cloud_image_id
}

output "hashitalk-fingerprint-version" {
  value = data.hcp_packer_iteration.hashitalk.fingerprint
}

output "hashitalk-active-image" {
  value = data.hcp_packer_iteration.hashitalk.ulid
}
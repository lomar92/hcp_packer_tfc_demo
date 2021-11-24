
# Variables File

variable "environment" {
  description = "This prefix will be included in the name of most resources. Prod, Test/Dev"
  default     = "test"
}

variable "region" {
  description = "The region where the resources are created."
}

variable "AMI" {
  description = "The Packer Image for your WebApp."
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t2.micro"
}


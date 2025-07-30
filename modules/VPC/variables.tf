variable "public_cidr_block" {
  type        = list(string)
  description = "Public subnet CIDR blocks"
}

variable "private_cidr_block" {
  type        = list(string)
  description = "Private subnet CIDR blocks"
}

variable "enable_dns_hostnames" {
  description = "DNS hostnames in the VPC"
}

variable "vpc_cidr_block" {
  description = "To define vpc CIDR block"
}

variable "project_name" {
  description = "To define project name"
}

variable "env_suffix" {
  description = "To define project environment"
}

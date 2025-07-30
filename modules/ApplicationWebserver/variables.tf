variable "project_name" {
  description = "Define project name"
}

variable "env_suffix" {
  description = "Define project environment"
}

variable "ingress_port" {
  type        = list(number)
  description = "list of ingress ports"
}

variable "egress_port" {
  type        = list(number)
  description = "list of egress ports"
}
variable "instance_type" {
  description = "Application server instance type"
}

variable "key_pair_name" {
  description = "Instance ssh pem file name"
}

variable "ebs_volume_type" {
  description = "EC2 EBS type"
}

variable "ebs_volume_size" {
  description = "EBS volume size"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "ec2_monitoring" {
  description = "Instance monitoring option"
}

variable "ec2_subnet_id" {
  description = "Instance public subnet id"
}

variable "ami_name" {
  description = "Name of the instance AMI"
}

variable "ec2_count" {
  description = "Numbers of instances to create"
}

variable "region_name" {
  description = "Code Deploy agent region name"
}

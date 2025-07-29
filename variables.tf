variable "region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI"
  default     = "ami-0a0f1259dd1c90938" # Ubuntu 22.04 LTS (ap-south-1)
}

variable "enable_s3_bucket" {
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "Terraform-Nginx-ELB"
    Environment = "Dev"
  }
}

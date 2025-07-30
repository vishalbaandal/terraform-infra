#------------- AWS Provider Details -------------#
variable "aws_profile_name" {
  description = "Name of the AWS profile"
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

#------------- Project and variable -------------#
variable "project_name" {
  description = "Name of your project"
  default     = "Terraform-Project"
}

variable "env_suffix" {
  description = "Project Environment"
  default     = "Test"
}

#------------- Terraform Backend Module -------------#
variable "terraform_bucket_name" {
  type        = string
  default     = "terraform-sample-backend-bucket"
  description = "Terrafrom backend bucket name"
}

variable "terraform_bucket_versioning" {
  type        = string
  default     = "Enabled"
  description = "Terrafrom backend bucket versioning Enabled or Disabled"
}

variable "table_name" {
  type        = string
  default     = "terraform-backend-sample-tablename"
  description = "Terrafrom backend dynamoDB table name"
}

#------------- VPC -------------#
variable "vpc_cidr_block" {
  default     = "20.0.0.0/16"
  description = "Main VPC CIDR Block"
}

variable "public_cidr_block" {
  type        = list(string)
  default     = ["20.0.0.0/20", "20.0.16.0/20", "20.0.32.0/20"]
  description = "Public subnet CIDR blocks"
}

variable "private_cidr_block" {
  type        = list(string)
  default     = ["20.0.48.0/20", "20.0.64.0/20", "20.0.80.0/20"]
  description = "Private subnet CIDR blocks"
}

variable "ingress_port" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [80, 443, 3306]
}

variable "egress_port" {
  type        = list(number)
  description = "list of egress ports"
  default     = []
}
variable "enable_dns_hostnames" {
  default     = "true"
  description = "DNS hostnames in the VPC"
}

#------------- EC2 -------------#
variable "ec2_count" {
  description = "Number of ec2 instance to create"
  default     = "1"
}

variable "instance_type" {
  description = "Application server instance type"
  default     = "t3.micro"
}

variable "ebs_volume_type" {
  description = "EC2 EBS type"
  default     = "gp3"
}

variable "ebs_volume_size" {
  default     = "30"
  description = "EBS Storage Capacity/Size"
}

variable "key_pair_name" {
  default     = "pemkey"
  description = "Name of EC2 SSh Key Pair"
}

variable "ec2_monitoring" {
  description = "Instance monitoring option"
  default     = "true"
}


variable "ami_name" {
  description = "Instance AMI"
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy"
}

#------------- S3 Private Bucket -------------#
variable "private_bucket_name" {
  description = "Name of the private bucket"
  default     = "private-bucket-terraform-134d45tc"
}

variable "private_bucket_versioning" {
  default     = "Enabled"
  description = "Private bucket versioning Enabled/Disabled"
}

variable "private_destination_bucket_name" {
  description = "Private bucket replica bucket name"
  default     = "private-bucket-replica-bucket-ed4rtv"
}

variable "private_bucket_replication_option" {
  default     = "Disabled"
  description = "Private bucket replica Enabled/Disabled"
}

variable "private_replication_destination_region" {
  description = "Private bucket replica region"
  default     = "us-east-2"
}

variable "number_of_private_bucket" {
  description = "Number of private bucket to create"
  default     = "1"
}

variable "private_bucket_lifecycle_rule" {
  default     = "Disabled"
  description = "Private bucket bucket lifecycle rule option"
}

#------------- S3 Public Bucket -------------#
variable "public_bucket_name" {
  description = "Name of the public bucket"
  default     = "public-bucket-terraform-1ft5v5"
}

variable "public_bucket_versioning" {
  default     = "Enabled"
  description = "Public bucket versioning Enabled/Disabled"
}

variable "public_destination_bucket_name" {
  description = "Public bucket replica bucket name"
  default     = "public-bucket-replica-bucket-d3r4t5t"
}

variable "public_bucket_replication_option" {
  default     = "Disabled"
  description = "Public bucket replica Enabled/Disabled"
}

variable "public_replication_destination_region" {
  description = "Public bucket replica region"
  default     = "us-east-2"
}

variable "number_of_public_bucket" {
  description = "Number of public bucket to create"
  default     = "1"
}

variable "public_bucket_lifecycle_rule" {
  default     = "Disabled"
  description = "Public bucket bucket lifecycle rule option"
}

#------------- (Application Load Balancer) -------------#
#Target Group
variable "tg_name" {
  description = "Name of the target group"
  default     = "default-tg"
}

variable "tg_port" {
  description = "Target group port"
  default     = "80"
}

variable "tg_protocol" {
  description = "Target group protocol"
  default     = "HTTP"
}

variable "tg_target_type" {
  description = "Target group target type"
  default     = "instance"
}

# Health Check
variable "lb_tg_health_check_path" {
  description = "Target group health check path"
  default     = "/"
}

variable "lb_tg_health_check_port" {
  description = "Target group health check port"
  default     = "80"
}

variable "lb_tg_health_check_protocol" {
  description = "Target group health check protocol"
  default     = "HTTP"
}

variable "lb_tg_health_check_matcher" {
  description = "Target group health check status code"
  default     = "200"
}

# Load Balancer
variable "lb_name" {
  description = "Name of the load balancer"
  default     = "alb-terraform-1"
}

variable "lb_internal" {
  description = "false value will create public load balancer and true value will create internal load balancer"
  default     = "false"
}

variable "lb_type" {
  description = "Load balancer type. Valid values are 'application' or 'network'"
  default     = "application"
}

variable "lb_deletion_protection" {
  description = "Enable load balancer delete protection"
  default     = "true"
}

# Load Balancer Listener
variable "lb_listener_protocol" {
  description = "Load balancer listener protocol"
  default     = "HTTP"
}

variable "lb_listener_port" {
  description = "Load balancer listener port"
  default     = "80"
}

variable "alb_log_prefix" {
  description = "Load balancer logs prefix"
  default     = "ALB"
}

variable "alb_bucket_versioning" {
  description = "Load lalancer logs s3 bucket versioning"
  default     = "Enabled"
}

variable "alb_logs_bucket_name" {
  description = "Load balancer logs s3 bucket name"
  default     = "alb-logs-bucket-der4fv"
}

variable "alb_logs_enable" {
  description = "Enable load balancer access logs"
  default     = "true"
}

variable "alb_idle_timeout" {
  description = "Load balancer maximum idle timeout"
  default     = "120"
}


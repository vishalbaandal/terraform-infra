variable "project_name" {
  description = "Define project name"
}

variable "env_suffix" {
  description = "Define project environment"
}

# Target Group
variable "tg_name" {
  description = "Name of the target group"
}

variable "tg_port" {
  description = "Target group port"
}

variable "tg_protocol" {
  description = "Target group protocol (HTTP/HTTPS)"
}

variable "tg_target_type" {
  description = "Target group target type"
}

# Register Instance to Target Group
variable "lb_target_id" {
  description = "EC2 instance id to attach it with targer group"
}

# Health Check
variable "lb_tg_health_check_path" {
  description = "Default health check path"
}

variable "lb_tg_health_check_port" {
  description = "Default health check port"
}

variable "lb_tg_health_check_protocol" {
  description = "Load balancer health check protocol"
}

variable "lb_tg_health_check_matcher" {
  description = "HTTP codes to use when checking for a successful response from a target"
}

# Load Balancer
variable "lb_name" {
  description = "Name of the load balancer"
}

variable "lb_internal" {
  description = "Load balancer internal option"
}

variable "lb_type" {
  description = "Load balancer type"
}

variable "lb_deletion_protection" {
  description = "Load balancer delete protection option"
}

# Load Balancer Listener
variable "lb_listener_protocol" {
  description = "Load balancer listener default protocol"
}

variable "lb_listener_port" {
  description = "Load balancer listener default port"
}

variable "alb_vpc_id" {
  description = "VPC id for load balancer"
}

variable "lb_subnets" {
  description = "Public subets id for load balancer"
}

variable "alb_log_prefix" {
  description = "Load balancer logs prefix"
}

variable "alb_bucket_versioning" {
  description = "Load lalancer bucket versioning option"
}

variable "alb_logs_bucket_name" {
  description = "S3 bucket name for log store"
}

variable "alb_logs_enable" {
  description = "Load balancer access logs option"
}

variable "alb_idle_timeout" {
  description = "Load balancer default idle timeout"
}

variable "number_of_alb" {
  description = "Number of alb to create"
}

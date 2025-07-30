locals {
local_naming = var.project_name
  environment  = var.env_suffix
}

module "vpc" {
  source = "./modules/VPC"

  public_cidr_block    = var.public_cidr_block
  private_cidr_block   = var.private_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  vpc_cidr_block       = var.vpc_cidr_block
  project_name         = local.local_naming
  env_suffix           = local.environment
}

module "application_server" {
  source = "./modules/ApplicationWebserver"
  depends_on = [
    module.vpc
  ]
  ingress_port             = var.ingress_port
  egress_port              = var.egress_port
  ec2_count                = var.ec2_count
  instance_type            = var.instance_type
  ebs_volume_type          = var.ebs_volume_type
  ebs_volume_size          = var.ebs_volume_size
  key_pair_name            = var.key_pair_name
  project_name             = local.local_naming
  env_suffix               = local.environment
  vpc_id                   = module.vpc.vpc_id
  ec2_monitoring           = var.ec2_monitoring
  ec2_subnet_id            = module.vpc.ec2_public_subnet
  region_name              = var.aws_region
  ami_name                 = var.ami_name
}

module "load_balancer" {
  source = "./modules/LoadBalancer"
  depends_on = [
    module.application_server
  ]

  project_name                = local.local_naming
  env_suffix                  = local.environment
  alb_vpc_id                  = module.vpc.vpc_id
  lb_subnets                  = module.vpc.public_subnet
  tg_name                     = var.tg_name
  tg_port                     = var.tg_port
  tg_protocol                 = var.tg_protocol
  tg_target_type              = var.tg_target_type
  lb_tg_health_check_path     = var.lb_tg_health_check_path
  lb_tg_health_check_port     = var.lb_tg_health_check_port
  lb_tg_health_check_protocol = var.lb_tg_health_check_protocol
  lb_tg_health_check_matcher  = var.lb_tg_health_check_matcher
  lb_target_id                = module.application_server.web_instance_id
  lb_deletion_protection      = var.lb_deletion_protection
  lb_listener_protocol        = var.lb_listener_protocol
  lb_listener_port            = var.lb_listener_port
  lb_name                     = var.lb_name
  lb_internal                 = var.lb_internal
  lb_type                     = var.lb_type
  alb_log_prefix              = var.alb_log_prefix
  alb_bucket_versioning       = var.alb_bucket_versioning
  alb_logs_bucket_name        = var.alb_logs_bucket_name
  alb_logs_enable             = var.alb_logs_enable
  alb_idle_timeout            = var.alb_idle_timeout
  number_of_alb               = var.ec2_count
}


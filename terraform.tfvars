aws_profile_name = "default"
aws_region       = "us-east-1"

project_name = "terraform"
env_suffix   = "assignment"

vpc_cidr_block       = "20.0.0.0/16"
private_cidr_block   = ["20.0.0.0/20", "20.0.16.0/20", "20.0.32.0/20"]
public_cidr_block    = ["20.0.48.0/20", "20.0.64.0/20", "20.0.80.0/20"]
enable_dns_hostnames = "true"

ec2_count                = "2"
instance_type            = "t3.medium"
ebs_volume_type          = "gp3"
ebs_volume_size          = "30"
key_pair_name            = "test-private-key"
ec2_monitoring           = "true"
ami_name                 = "ubuntu/images/hvm-ssd/ubuntu-jammy" 

tg_name        = ["target-group"]
tg_port        = "80"
tg_protocol    = "HTTP"
tg_target_type = "instance"

lb_tg_health_check_path     = "/"
lb_tg_health_check_port     = "80"
lb_tg_health_check_protocol = "HTTP"
lb_tg_health_check_matcher  = "200"

lb_name                = ["alb" ]
lb_internal            = "false"
lb_type                = "application"
lb_deletion_protection = "true"

lb_listener_protocol = "HTTP"
lb_listener_port     = "80"

alb_log_prefix        = "ALB"
alb_bucket_versioning = "Enabled"
alb_logs_bucket_name  = ["alb-bucket-assignment"]
alb_logs_enable       = "true"
alb_idle_timeout      = "180"

data "aws_caller_identity" "account_id" {}

locals {
  account_id = data.aws_caller_identity.account_id.account_id
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.env_suffix}-LoadBalancer-SG"
  description = "Application Load Balancer - Security Group"
  vpc_id      = var.alb_vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "HTTP Traffic"
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "HTTPS Traffic"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all Traffic"
  }
  tags = {
    Name        = "${var.project_name}-${var.env_suffix}-Load-Balancer-SG"
    Environment = var.env_suffix
  }
}

# Create Target Group
resource "aws_alb_target_group" "application_tg" {
  count                = var.number_of_alb
  name                 = length(var.tg_name) > count.index ? var.tg_name[count.index] : "${var.project_name}-${var.env_suffix}-tg-${count.index}"
  port                 = var.tg_port
  protocol             = var.tg_protocol
  vpc_id               = var.alb_vpc_id
  target_type          = var.tg_target_type
  deregistration_delay = "120"
  health_check {
    path                = var.lb_tg_health_check_path
    interval            = 60
    port                = var.lb_tg_health_check_port
    protocol            = var.lb_tg_health_check_protocol
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = var.lb_tg_health_check_matcher
  }
  tags_all = {
    Name        = "${var.project_name}-${var.env_suffix}-TG-${count.index}"
    Environment = var.env_suffix
  }
}

# Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "register_instance_tg" {
  count            = var.number_of_alb
  target_group_arn = aws_alb_target_group.application_tg[count.index].arn
  target_id        = length(var.lb_target_id) > count.index ? var.lb_target_id[count.index] : null
  port             = 80

  depends_on = [
    aws_alb_target_group.application_tg
  ]
}

## Get ALB Account ID
data "aws_elb_service_account" "main" {}

## Create Bucket for ALB logs store
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "elb_logs" {
  count         = var.number_of_alb
  bucket        = length(var.alb_logs_bucket_name) > count.index ? var.alb_logs_bucket_name[count.index] : "${var.project_name}-${var.env_suffix}-alb-logs-${count.index}-${random_string.bucket_suffix[count.index].result}"
  force_destroy = true
}

# Generate random suffix for bucket names to ensure uniqueness
resource "random_string" "bucket_suffix" {
  count   = var.number_of_alb
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_public_access_block" "alb_access_block" {
  count                   = var.number_of_alb
  bucket                  = aws_s3_bucket.elb_logs[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## Enable bucket versioning
resource "aws_s3_bucket_versioning" "alb_public_bucket_versioning" {
  count  = var.number_of_alb
  bucket = aws_s3_bucket.elb_logs[count.index].id
  versioning_configuration {
    status = var.alb_bucket_versioning
  }
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_bucket_encryption" {
  count  = var.number_of_alb
  bucket = aws_s3_bucket.elb_logs[count.index].bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "allow_elb_logging" {
  count = var.number_of_alb
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.elb_logs[count.index].arn}/${var.alb_log_prefix}/AWSLogs/${local.account_id}/*"]
  }
}

resource "aws_s3_bucket_policy" "allow_elb_logging" {
  count  = var.number_of_alb
  bucket = aws_s3_bucket.elb_logs[count.index].id
  policy = data.aws_iam_policy_document.allow_elb_logging[count.index].json
}

# Fixed Bucket life cycle rule - added required filter
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_configuration" {
  count  = var.number_of_alb
  bucket = aws_s3_bucket.elb_logs[count.index].id

  rule {
    id     = length(var.alb_logs_bucket_name) > count.index ? var.alb_logs_bucket_name[count.index] : "lifecycle-rule-${count.index}"
    status = "Enabled"

    # Required: Either filter or prefix must be specified
    filter {
      prefix = var.alb_log_prefix != null ? var.alb_log_prefix : ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30 # This action permanently deletes noncurrent versions of objects after 30 days
    }

    expiration {
      days = 30 # This action expires current versions of objects after 30 days
    }
  }
}

# Create Application Load Balancer
#tfsec:ignore:aws-elb-alb-not-public
#tfsec:ignore:aws-elb-drop-invalid-headers
resource "aws_lb" "application_lb" {
  count                      = var.number_of_alb
  name                       = length(var.lb_name) > count.index ? var.lb_name[count.index] : "${var.project_name}-${var.env_suffix}-alb-${count.index}"
  internal                   = var.lb_internal
  load_balancer_type         = var.lb_type
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = var.lb_subnets
  enable_deletion_protection = var.lb_deletion_protection
  idle_timeout               = var.alb_idle_timeout

  access_logs {
    bucket  = aws_s3_bucket.elb_logs[count.index].id
    prefix  = var.alb_log_prefix
    enabled = var.alb_logs_enable
  }

  tags_all = {
    Name        = "${var.project_name}-${var.env_suffix}-ALB-${count.index}"
    Environment = var.env_suffix
  }
}

# Add ALB Listener
resource "aws_alb_listener" "application_lb_listener" {
  count             = var.number_of_alb
  load_balancer_arn = aws_lb.application_lb[count.index].arn
  protocol          = var.lb_listener_protocol
  port              = var.lb_listener_port
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.application_tg[count.index].arn
  }

  depends_on = [
    aws_alb_target_group.application_tg,
    aws_lb.application_lb
  ]
}

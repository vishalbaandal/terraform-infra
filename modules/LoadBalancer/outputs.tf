# ALB DNS Name
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.application_lb[*].dns_name
}

# ALB Zone ID
output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.application_lb[*].zone_id
}

# ALB ARN
output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.application_lb[*].arn
}

# Target Group ARNs
output "target_group_arns" {
  description = "ARNs of the target groups"
  value       = aws_alb_target_group.application_tg[*].arn
}

# ALB Security Group ID
output "alb_security_group_id" {
  description = "Security Group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

# S3 Bucket names for ALB logs
output "alb_logs_bucket_names" {
  description = "Names of the S3 buckets storing ALB logs"
  value       = aws_s3_bucket.elb_logs[*].id
}

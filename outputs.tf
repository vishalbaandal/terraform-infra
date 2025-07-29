output "elb_dns_name" {
  value = aws_lb.app_lb.dns_name
  description = "Load Balancer DNS"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.project_bucket[0].bucket
  description = "Optional S3 bucket name"
  condition   = var.enable_s3_bucket
}

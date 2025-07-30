output "application_instance_eip" {
  description = "Application instance Public IP address"
  value       = aws_eip.application_eip[*].public_ip
}

output "application_sg_id" {
  description = "Application security group id"
  value       = aws_security_group.application_sg.id
}

output "web_instance_id" {
  description = "Application server id"
  value       = aws_instance.web[*].id
}

output "ec2_private_key" {
  description = "SSH key"
  value       = tls_private_key.key.private_key_pem
  sensitive   = true
}

output "ec2_role_arn" {
  description = "EC2 role ARN"
  value       = aws_iam_role.ec2_s3_sm_access_role.arn
}

output "ec2_role_name" {
  description = "EC2 role Name"
  value       = aws_iam_role.ec2_s3_sm_access_role.name
}

output "ubuntu_ami_id" {
  description = "Ubuntu AMI ID"
  value       = data.aws_ami.instance_ami.id
}

output "ec2_profile_name" {
  description = "EC2 Profile Name"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "instance_ami_id" {
  description = "EC2 AMI "
  value       = data.aws_ami.instance_ami.id
}

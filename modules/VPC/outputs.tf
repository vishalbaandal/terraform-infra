output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "To get VPC id"
}

output "public_subnet" {
  value       = aws_subnet.public_subnet[*].id
  description = "To get public subnets"
}

output "ec2_public_subnet" {
  value       = flatten(aws_subnet.public_subnet[*].id)[0]
  description = "To get only one public subnet"
}

output "private_subnet" {
  value       = aws_subnet.private_subnet[*].id
  description = "To get private subnets"
}

output "available_zones" {
  value       = data.aws_availability_zones.available[*].names
  description = "To get available zones"
}

################################################################################
# Root Outputs
# Expose key infrastructure endpoints and identifiers
################################################################################

# --- Networking ---

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.networking.nat_gateway_public_ip
}

# --- ALB ---

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "Full URL to access the application"
  value       = module.alb.alb_url
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = module.alb.alb_security_group_id
}

# --- Compute ---

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.autoscaling_group_name
}

output "ec2_security_group_id" {
  description = "Security group ID of the EC2 instances"
  value       = module.compute.ec2_security_group_id
}

output "ami_id" {
  description = "AMI ID used for EC2 instances"
  value       = module.compute.ami_id
}

# --- IAM ---

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = module.iam.ec2_role_arn
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.iam.instance_profile_name
}

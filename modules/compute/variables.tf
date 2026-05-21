################################################################################
# Compute Module Variables
################################################################################

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EC2 instances"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB (for ingress rules)"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to attach the ASG to"
  type        = string
}

variable "instance_profile_arn" {
  description = "ARN of the IAM instance profile to attach to EC2 instances"
  type        = string
}

# --- Instance Configuration ---

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Custom AMI ID. Leave empty to use latest Amazon Linux 2023"
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 80
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed (1-minute) CloudWatch monitoring for EC2 instances"
  type        = bool
  default     = false
}

# --- Auto Scaling ---

variable "asg_desired" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}

variable "asg_min" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "asg_max" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 4
}

variable "health_check_grace_period" {
  description = "Seconds before ASG starts checking EC2 health after launch"
  type        = number
  default     = 300
}

# --- SSH Configuration ---

variable "enable_ssh" {
  description = "Enable SSH access to EC2 instances (not recommended — use SSM instead)"
  type        = bool
  default     = false
}

variable "ssh_cidr" {
  description = "CIDR block allowed for SSH access (only used if enable_ssh is true)"
  type        = string
  default     = "0.0.0.0/0"
}

# --- CloudWatch ---

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for CPU-based auto scaling"
  type        = bool
  default     = true
}

variable "cpu_high_threshold" {
  description = "CPU percentage threshold to trigger scale-up"
  type        = number
  default     = 70
}

variable "cpu_low_threshold" {
  description = "CPU percentage threshold to trigger scale-down"
  type        = number
  default     = 20
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB (for CloudWatch dashboard metrics)"
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the target group (for CloudWatch dashboard metrics)"
  type        = string
  default     = ""
}

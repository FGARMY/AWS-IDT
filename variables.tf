################################################################################
# Root Variables
# All configurable parameters for the infrastructure
################################################################################

# --- General ---

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging across all modules"
  type        = string
  default     = "aws-idt"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the resources (used in tags for cost tracking)"
  type        = string
  default     = "cloud-engineering-team"
}

# --- Networking ---

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ, minimum 2)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ, minimum 2)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic monitoring"
  type        = bool
  default     = true
}

# --- Compute ---

variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Custom AMI ID (leave empty to auto-select latest Amazon Linux 2023)"
  type        = string
  default     = ""
}

variable "asg_desired" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_min" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "root_volume_size" {
  description = "Size of EC2 root EBS volume in GB"
  type        = number
  default     = 20
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed (1-minute) CloudWatch monitoring for EC2"
  type        = bool
  default     = false
}

# --- Security ---

variable "enable_ssh" {
  description = "Enable SSH access to EC2 instances (recommend SSM Session Manager instead)"
  type        = bool
  default     = false
}

variable "ssh_cidr" {
  description = "CIDR block for SSH access (only used if enable_ssh = true)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_ssm" {
  description = "Enable SSM Session Manager for EC2 access (no SSH keys required)"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS (443) on the ALB security group"
  type        = bool
  default     = false
}

# --- ALB ---

variable "enable_alb_access_logs" {
  description = "Enable ALB access logs to S3"
  type        = bool
  default     = false
}

variable "alb_logs_retention_days" {
  description = "Number of days to retain ALB access logs"
  type        = number
  default     = 90
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "HTTP path for ALB health checks"
  type        = string
  default     = "/health"
}

# --- Monitoring ---

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms and dashboard"
  type        = bool
  default     = true
}

variable "cpu_high_threshold" {
  description = "CPU % threshold to trigger ASG scale-up"
  type        = number
  default     = 70
}

variable "cpu_low_threshold" {
  description = "CPU % threshold to trigger ASG scale-down"
  type        = number
  default     = 20
}

################################################################################
# IAM Module Variables
################################################################################

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "enable_ssm" {
  description = "Enable SSM Session Manager access for EC2 instances (eliminates need for SSH keys)"
  type        = bool
  default     = true
}

variable "enable_ecr_access" {
  description = "Enable ECR read-only access for pulling container images"
  type        = bool
  default     = false
}

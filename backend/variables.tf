################################################################################
# Backend Bootstrap Variables
################################################################################

variable "project_name" {
  description = "Project name (must match the main project)"
  type        = string
  default     = "aws-idt"
}

variable "aws_region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "us-east-1"
}

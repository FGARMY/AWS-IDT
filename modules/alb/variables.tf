################################################################################
# ALB Module Variables
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
  description = "ID of the VPC where the ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "enable_https" {
  description = "Enable HTTPS (port 443) ingress on the ALB security group"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB (recommended for production)"
  type        = bool
  default     = false
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logs to S3"
  type        = bool
  default     = false
}

variable "alb_logs_retention_days" {
  description = "Number of days to retain ALB access logs in S3"
  type        = number
  default     = 90
}

# --- Health Check Configuration ---

variable "health_check_path" {
  description = "HTTP path for ALB health checks"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Seconds between health checks"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Seconds before a health check times out"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Consecutive successful checks before marking healthy"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Consecutive failed checks before marking unhealthy"
  type        = number
  default     = 3
}

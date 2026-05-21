################################################################################
# Production Environment Variables
################################################################################

# --- General ---
aws_region   = "us-east-1"
project_name = "aws-idt"
environment  = "prod"
owner        = "platform-team"

# --- Networking ---
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24"]
enable_vpc_flow_logs = true

# --- Compute ---
instance_type              = "t3.small"
asg_desired                = 3
asg_min                    = 2
asg_max                    = 6
root_volume_size           = 30
enable_detailed_monitoring = true

# --- Security ---
enable_ssh   = false
enable_ssm   = true
enable_https = true

# --- ALB ---
enable_alb_access_logs     = true
alb_logs_retention_days    = 365
enable_deletion_protection = true
health_check_path          = "/health"

# --- Monitoring ---
enable_cloudwatch_alarms = true
cpu_high_threshold       = 70
cpu_low_threshold        = 30

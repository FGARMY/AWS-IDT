################################################################################
# Development Environment Variables
################################################################################

# --- General ---
aws_region   = "us-east-1"
project_name = "aws-idt"
environment  = "dev"
owner        = "dev-team"

# --- Networking ---
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
enable_vpc_flow_logs = false # Save costs in dev

# --- Compute ---
instance_type              = "t3.micro"
asg_desired                = 1
asg_min                    = 1
asg_max                    = 2
root_volume_size           = 20
enable_detailed_monitoring = false

# --- Security ---
enable_ssh   = false
enable_ssm   = true
enable_https = false

# --- ALB ---
enable_alb_access_logs     = false
enable_deletion_protection = false
health_check_path          = "/health"

# --- Monitoring ---
enable_cloudwatch_alarms = false # Save costs in dev
cpu_high_threshold       = 70
cpu_low_threshold        = 20

################################################################################
# Root Module — Infrastructure Orchestration
# Wires together all child modules with proper dependency ordering
################################################################################

# ==============================================================================
# 1. NETWORKING — Foundation layer (no dependencies)
# ==============================================================================
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_vpc_flow_logs = var.enable_vpc_flow_logs
}

# ==============================================================================
# 2. IAM — Identity layer (no infrastructure dependencies)
# ==============================================================================
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  enable_ssm   = var.enable_ssm
}

# ==============================================================================
# 3. ALB — Load balancing layer (depends on networking)
# ==============================================================================
module "alb" {
  source = "./modules/alb"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  public_subnet_ids          = module.networking.public_subnet_ids
  enable_https               = var.enable_https
  enable_deletion_protection = var.enable_deletion_protection
  enable_alb_access_logs     = var.enable_alb_access_logs
  alb_logs_retention_days    = var.alb_logs_retention_days
  health_check_path          = var.health_check_path
}

# ==============================================================================
# 4. COMPUTE — Application layer (depends on networking, iam, alb)
# ==============================================================================
module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  instance_profile_arn  = module.iam.instance_profile_arn

  # Instance configuration
  instance_type              = var.instance_type
  ami_id                     = var.ami_id
  root_volume_size           = var.root_volume_size
  enable_detailed_monitoring = var.enable_detailed_monitoring

  # Auto Scaling
  asg_desired = var.asg_desired
  asg_min     = var.asg_min
  asg_max     = var.asg_max

  # Security
  enable_ssh = var.enable_ssh
  ssh_cidr   = var.ssh_cidr

  # CloudWatch
  enable_cloudwatch_alarms = var.enable_cloudwatch_alarms
  cpu_high_threshold       = var.cpu_high_threshold
  cpu_low_threshold        = var.cpu_low_threshold
  alb_arn_suffix           = module.alb.alb_arn_suffix
  target_group_arn_suffix  = module.alb.target_group_arn_suffix
}

################################################################################
# Backend Configuration (S3 + DynamoDB)
#
# SETUP INSTRUCTIONS:
# 1. First deploy the backend resources using: cd backend && terraform init && terraform apply
# 2. Then uncomment the backend block below
# 3. Run: terraform init -migrate-state
#
# This two-step process is required because Terraform cannot create the
# S3 bucket/DynamoDB table AND use them as backend in the same apply.
################################################################################

# Uncomment after deploying the backend infrastructure:
#
# terraform {
#   backend "s3" {
#     bucket         = "aws-idt-terraform-state-ACCOUNT_ID"
#     key            = "infrastructure/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "aws-idt-terraform-locks"
#     encrypt        = true
#   }
# }

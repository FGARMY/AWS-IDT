# 🛡️ AWS Infrastructure as Code — Production-Grade Terraform Project

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-7B42BC?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=github-actions)](/.github/workflows/terraform.yml)

A **production-ready, modular AWS infrastructure** project built entirely with Terraform. Designed to demonstrate cloud engineering competency, security-first architecture, and Infrastructure as Code best practices.

---

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Architecture Diagram](#-architecture-diagram)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Backend Setup (Remote State)](#-backend-setup-remote-state)
- [Deployment Guide](#-deployment-guide)
- [Environment Management](#-environment-management)
- [Security Design](#-security-design)
- [Monitoring & Observability](#-monitoring--observability)
- [Terraform Commands Reference](#-terraform-commands-reference)
- [Destroy Infrastructure](#-destroy-infrastructure)
- [Troubleshooting](#-troubleshooting)
- [Architecture Decisions](#-architecture-decisions)
- [Interview Preparation](#-interview-preparation)
- [Resume Bullet Points](#-resume-bullet-points)

---

## 🏗️ Architecture Overview

This project provisions a **highly available, secure web application infrastructure** on AWS using a modular Terraform design:

| Component | Resources | Purpose |
|-----------|-----------|---------|
| **Networking** | VPC, 2 Public + 2 Private Subnets, IGW, NAT GW, Route Tables | Network isolation and internet access |
| **Compute** | Launch Template, Auto Scaling Group, EC2 (Amazon Linux 2023) | Application hosting with auto-scaling |
| **Load Balancer** | ALB, Target Group, Listener, Health Checks | Traffic distribution and high availability |
| **IAM** | EC2 Role, Instance Profile, Least-Privilege Policies | Secure identity and access management |
| **Security** | Security Groups (ALB + EC2), IMDSv2, Encrypted EBS, VPC Flow Logs | Defense-in-depth security layers |
| **Monitoring** | CloudWatch Alarms, Dashboard, ALB Access Logs | Observability and auto-scaling triggers |

---

## 🗺️ Architecture Diagram

```
                           ┌──────────────────────────────────────────────────────────┐
                           │                        AWS Cloud                         │
                           │  ┌────────────────────────────────────────────────────┐  │
                           │  │                   VPC (10.0.0.0/16)                │  │
                           │  │                                                    │  │
          Internet         │  │  ┌─────────────────┐    ┌─────────────────┐       │  │
            │              │  │  │  Public Subnet   │    │  Public Subnet   │       │  │
            │              │  │  │  AZ-a (10.0.1.0) │    │  AZ-b (10.0.2.0) │       │  │
            ▼              │  │  │                  │    │                  │       │  │
       ┌─────────┐         │  │  │  ┌────────────┐ │    │ ┌────────────┐  │       │  │
       │  IGW    │◄────────┤  │  │  │    ALB     │◄┼────┼─┤    ALB     │  │       │  │
       └─────────┘         │  │  │  │  (public)  │ │    │ │  (public)  │  │       │  │
                           │  │  │  └──────┬─────┘ │    │ └──────┬─────┘  │       │  │
                           │  │  │         │       │    │        │        │       │  │
                           │  │  │  ┌──────┴────┐  │    │        │        │       │  │
                           │  │  │  │  NAT GW   │  │    │        │        │       │  │
                           │  │  │  │  + EIP    │  │    │        │        │       │  │
                           │  │  │  └──────┬────┘  │    │        │        │       │  │
                           │  │  └─────────┼───────┘    └────────┼────────┘       │  │
                           │  │            │                     │                │  │
                           │  │  ┌─────────┼───────┐    ┌────────┼────────┐       │  │
                           │  │  │  Private│Subnet │    │ Private│Subnet  │       │  │
                           │  │  │  AZ-a   │       │    │  AZ-b  │        │       │  │
                           │  │  │  (10.0.10.0)    │    │  (10.0.20.0)    │       │  │
                           │  │  │         ▼       │    │        ▼        │       │  │
                           │  │  │  ┌────────────┐ │    │ ┌────────────┐  │       │  │
                           │  │  │  │    EC2     │ │    │ │    EC2     │  │       │  │
                           │  │  │  │  (nginx)   │ │    │ │  (nginx)   │  │       │  │
                           │  │  │  │  ASG       │ │    │ │  ASG       │  │       │  │
                           │  │  │  └────────────┘ │    │ └────────────┘  │       │  │
                           │  │  └─────────────────┘    └─────────────────┘       │  │
                           │  │                                                    │  │
                           │  │  ┌──────────────────────────────────────────────┐  │  │
                           │  │  │  CloudWatch: Alarms │ Dashboard │ Flow Logs  │  │  │
                           │  │  └──────────────────────────────────────────────┘  │  │
                           │  └────────────────────────────────────────────────────┘  │
                           │                                                          │
                           │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
                           │  │  S3 (State)  │  │  DynamoDB    │  │  S3 (ALB     │   │
                           │  │  + Versioning│  │  (Lock)      │  │   Logs)      │   │
                           │  └──────────────┘  └──────────────┘  └──────────────┘   │
                           └──────────────────────────────────────────────────────────┘

Traffic Flow:
  User → Internet → IGW → ALB (Public SG: 80/443) → EC2 (Private SG: 80 from ALB only)
  EC2 → NAT GW → IGW → Internet (for updates)
```

---

## 📁 Project Structure

```
AWS-IDT/
├── main.tf                          # Root module — orchestrates all child modules
├── variables.tf                     # Root-level input variables
├── outputs.tf                       # Root-level outputs
├── provider.tf                      # AWS provider configuration
├── versions.tf                      # Terraform & provider version constraints
├── backend.tf                       # Remote backend configuration (S3)
├── terraform.tfvars.example         # Example variable values
│
├── modules/
│   ├── networking/                  # VPC, Subnets, IGW, NAT, Routes
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/                     # Launch Template, ASG, SG, CloudWatch
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── templates/
│   │       └── user_data.sh         # EC2 bootstrap script (nginx)
│   ├── alb/                         # ALB, Target Group, Listener, SG
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/                         # IAM Role, Instance Profile, Policies
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── backend/                         # Backend bootstrap (S3 + DynamoDB)
│   ├── main.tf
│   └── variables.tf
│
├── envs/                            # Environment-specific configurations
│   ├── dev.tfvars
│   └── prod.tfvars
│
├── .github/
│   └── workflows/
│       └── terraform.yml            # CI/CD: validate, plan, apply, security scan
│
├── Makefile                         # Workflow automation
├── .gitignore
└── README.md                        # This file
```

---

## ✅ Prerequisites

| Requirement | Version | Purpose |
|-------------|---------|---------|
| [Terraform](https://www.terraform.io/downloads) | >= 1.5.0 | Infrastructure provisioning |
| [AWS CLI](https://aws.amazon.com/cli/) | v2 | AWS authentication |
| [Git](https://git-scm.com/) | Latest | Version control |
| AWS Account | — | Target cloud environment |
| IAM User/Role | — | With sufficient permissions |

### AWS Permissions Required

The deploying IAM principal needs permissions for:
- EC2 (VPC, Subnets, SGs, Launch Templates, ASG)
- ELB (ALB, Target Groups, Listeners)
- IAM (Roles, Policies, Instance Profiles)
- S3 (Buckets for state and logs)
- DynamoDB (Lock table)
- CloudWatch (Alarms, Dashboards, Log Groups)

> 💡 **Tip:** Use the `AdministratorAccess` policy for initial setup, then create a scoped-down policy for ongoing use.

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/AWS-IDT.git
cd AWS-IDT

# 2. Configure AWS credentials
aws configure
# OR export environment variables:
# export AWS_ACCESS_KEY_ID="your-key"
# export AWS_SECRET_ACCESS_KEY="your-secret"
# export AWS_DEFAULT_REGION="us-east-1"

# 3. Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 4. Initialize Terraform
terraform init

# 5. Preview changes
terraform plan -var-file=terraform.tfvars

# 6. Deploy
terraform apply -var-file=terraform.tfvars

# 7. Access the application
terraform output alb_url
```

---

## 🗄️ Backend Setup (Remote State)

Remote state is critical for team collaboration and state locking.

### Step 1: Deploy Backend Infrastructure

```bash
cd backend
terraform init
terraform apply -var="project_name=aws-idt" -var="aws_region=us-east-1"
```

This creates:
- **S3 Bucket** — Encrypted, versioned state storage
- **DynamoDB Table** — State locking to prevent concurrent modifications

### Step 2: Configure the Main Project

1. Copy the `backend_config` output from Step 1
2. Uncomment and update the `backend "s3"` block in `backend.tf`
3. Migrate state:

```bash
cd ..
terraform init -migrate-state
```

### Step 3: Verify

```bash
# Confirm state is stored remotely
terraform state list
```

---

## 📦 Deployment Guide

### Using Makefile (Recommended)

```bash
# Development
make init
make plan ENV=dev
make apply ENV=dev

# Production
make plan ENV=prod
make apply ENV=prod
```

### Using Terraform Directly

```bash
# Development
terraform init
terraform plan -var-file=envs/dev.tfvars -out=tfplan
terraform apply tfplan

# Production
terraform plan -var-file=envs/prod.tfvars -out=tfplan
terraform apply tfplan
```

### Post-Deployment Verification

```bash
# Get the ALB URL
terraform output alb_url

# Test the endpoint
curl $(terraform output -raw alb_dns_name)

# Check ASG instance count
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $(terraform output -raw autoscaling_group_name) \
  --query 'AutoScalingGroups[0].Instances[*].InstanceId'
```

---

## 🌍 Environment Management

| Setting | Dev | Prod |
|---------|-----|------|
| Instance Type | t3.micro | t3.small |
| ASG Desired | 1 | 3 |
| ASG Min/Max | 1/2 | 2/6 |
| Detailed Monitoring | ❌ | ✅ |
| VPC Flow Logs | ❌ | ✅ |
| ALB Access Logs | ❌ | ✅ |
| CloudWatch Alarms | ❌ | ✅ |
| Deletion Protection | ❌ | ✅ |
| HTTPS | ❌ | ✅ |

---

## 🔒 Security Design

This project implements **defense-in-depth** security:

### Network Security
- **Private Subnets** — EC2 instances have no public IP addresses
- **NAT Gateway** — Controlled outbound internet access for updates
- **VPC Flow Logs** — All network traffic logged to CloudWatch

### Compute Security
- **IMDSv2 Enforced** — Prevents SSRF-based credential theft
- **Encrypted EBS** — Data-at-rest encryption on all volumes
- **No SSH Keys** — SSM Session Manager for shell access (no port 22)

### Access Security
- **Least-Privilege IAM** — EC2 role limited to CloudWatch and SSM only
- **No Hardcoded Credentials** — Uses IAM roles and instance profiles
- **Security Group Chaining** — EC2 SG only accepts traffic from ALB SG

### Data Security
- **S3 Encryption** — State files encrypted with AWS KMS
- **S3 Versioning** — State file version history for recovery
- **Public Access Block** — All S3 buckets block public access

---

## 📊 Monitoring & Observability

### CloudWatch Alarms
| Alarm | Threshold | Action |
|-------|-----------|--------|
| High CPU | > 70% for 4 min | Scale Up (+1 instance) |
| Low CPU | < 20% for 4 min | Scale Down (-1 instance) |

### CloudWatch Dashboard
A pre-built dashboard displays:
- EC2 CPU utilization (per ASG)
- ALB request count
- Target group health (healthy/unhealthy hosts)
- ALB response time (p99)

### ALB Access Logs (Production)
- Stored in encrypted S3 bucket
- Lifecycle policy: 365-day retention
- Contains: client IP, request path, response code, latency

---

## 📖 Terraform Commands Reference

| Command | Purpose |
|---------|---------|
| `terraform init` | Initialize providers and modules |
| `terraform plan -var-file=envs/dev.tfvars` | Preview changes |
| `terraform apply -var-file=envs/dev.tfvars` | Deploy infrastructure |
| `terraform destroy -var-file=envs/dev.tfvars` | Tear down infrastructure |
| `terraform output` | View output values |
| `terraform state list` | List managed resources |
| `terraform fmt -recursive` | Format all `.tf` files |
| `terraform validate` | Validate configuration syntax |
| `terraform graph \| dot -Tpng > graph.png` | Generate dependency graph |

---

## 💣 Destroy Infrastructure

### Development

```bash
# Using Makefile
make destroy ENV=dev

# Using Terraform directly
terraform destroy -var-file=envs/dev.tfvars
```

### Production

```bash
# 1. Disable deletion protection first
terraform apply -var-file=envs/prod.tfvars -var="enable_deletion_protection=false"

# 2. Destroy
terraform destroy -var-file=envs/prod.tfvars
```

### Clean Up Backend (if needed)

```bash
cd backend
terraform destroy -var="project_name=aws-idt"
```

> ⚠️ **Warning:** Destroying the backend will permanently delete your state file. Ensure all infrastructure is destroyed first.

---

## 🔧 Troubleshooting

### Common Issues

<details>
<summary><strong>Error: "Error acquiring the state lock"</strong></summary>

Another Terraform process holds the lock. If you're sure no other process is running:

```bash
terraform force-unlock LOCK_ID
```
</details>

<details>
<summary><strong>Error: "insufficient permissions"</strong></summary>

Verify your AWS credentials and permissions:
```bash
aws sts get-caller-identity
aws iam simulate-principal-policy --policy-source-arn YOUR_ARN --action-names ec2:CreateVpc
```
</details>

<details>
<summary><strong>EC2 instances not passing health checks</strong></summary>

1. Check the user_data bootstrap completed:
   ```bash
   aws ssm start-session --target INSTANCE_ID
   # Then check: sudo systemctl status nginx
   ```
2. Verify security group allows traffic from ALB
3. Check the health check path matches nginx config (`/health`)
</details>

<details>
<summary><strong>ALB returning 502/503 errors</strong></summary>

1. Check target group health:
   ```bash
   aws elbv2 describe-target-health --target-group-arn TG_ARN
   ```
2. Verify EC2 instances are in `InService` state in ASG
3. Wait for the health check grace period (default: 300s)
</details>

<details>
<summary><strong>NAT Gateway charges</strong></summary>

NAT Gateways cost ~$0.045/hr (~$32/month). For dev environments:
- Use `t3.micro` instances
- Set `asg_desired = 1`
- Destroy when not testing: `make destroy ENV=dev`
</details>

---

## 🧠 Architecture Decisions

### Why Private Subnets for EC2?
EC2 instances in private subnets have **no public IP addresses**, reducing the attack surface. All inbound traffic flows through the ALB, which acts as a reverse proxy and security boundary. Outbound traffic (for package updates) routes through the NAT Gateway.

### Why IMDSv2 Only?
IMDSv1 is vulnerable to SSRF attacks (e.g., the 2019 Capital One breach). By enforcing IMDSv2 with `http_tokens = "required"`, instances must use a session token to access metadata, preventing credential exfiltration via SSRF.

### Why SSM Over SSH?
SSM Session Manager eliminates the need for:
- SSH key management and rotation
- Port 22 in security groups
- Bastion hosts
- VPN tunnels

All sessions are logged to CloudWatch for audit compliance.

### Why Security Group Chaining?
Instead of allowing `0.0.0.0/0` on port 80 for EC2, we reference the ALB's security group ID. This ensures only the ALB can send traffic to EC2 instances — even if someone discovers the private IP.

### Why Separate Backend Bootstrap?
Terraform cannot create the S3 bucket it stores state in during the same apply. The `backend/` directory is a standalone mini-project that provisions state storage first, enabling the main project to use remote state.

### Why Rolling Instance Refresh?
The ASG's `instance_refresh` with 50% `min_healthy_percentage` ensures zero-downtime deployments when the launch template changes. At least half the fleet stays healthy while the other half is replaced.

---

## 🎤 Interview Preparation

### "Walk me through this architecture."

> "This is a production-grade AWS infrastructure deployed via Terraform with four modules. Traffic enters through an internet-facing ALB in public subnets, which distributes requests across EC2 instances running nginx in private subnets — those instances have no public IPs, reducing the attack surface. The Auto Scaling Group maintains desired capacity and scales based on CPU CloudWatch alarms. IAM follows least-privilege — the EC2 role only has CloudWatch and SSM permissions, with no hardcoded credentials anywhere. State is stored remotely in an encrypted, versioned S3 bucket with DynamoDB locking for team collaboration. The CI/CD pipeline validates formatting, runs security scans with tfsec and checkov, and auto-applies to dev on merge."

### "How does the networking work?"

> "The VPC uses a /16 CIDR with four subnets across two AZs for high availability. Public subnets host the ALB and NAT Gateway — they have an Internet Gateway route. Private subnets host EC2 instances — they route outbound traffic through the NAT Gateway for package updates but receive no direct inbound internet traffic. This separation is fundamental to defense-in-depth."

### "How did you handle security?"

> "Multiple layers: network isolation via private subnets, security group chaining so EC2 only accepts ALB traffic, IMDSv2 enforced to prevent SSRF credential theft, encrypted EBS volumes, no SSH keys — we use SSM Session Manager instead, and VPC Flow Logs for network audit trails. IAM follows least-privilege with only CloudWatch and SSM permissions on the EC2 role."

### "What happens when traffic increases?"

> "The Auto Scaling Group monitors CPU via CloudWatch alarms. When CPU exceeds 70% for two consecutive 2-minute periods, it adds an instance. When CPU drops below 20%, it removes one. The ASG respects the min/max bounds I've configured per environment. The ALB automatically detects new healthy targets via health checks and starts routing traffic to them."

### "How would you add HTTPS?"

> "I'd request an ACM certificate for the domain, add an HTTPS listener on port 443 referencing the certificate ARN, and modify the HTTP listener to redirect 301 to HTTPS. The `enable_https` variable already opens port 443 on the ALB security group."

---

## 📝 Resume Bullet Points

Use these on your resume, tailored to the role:

- **Designed and deployed production-grade AWS infrastructure** using Terraform IaC with modular architecture (VPC, ALB, ASG, IAM), implementing defense-in-depth security across 4 layers

- **Implemented auto-scaling web infrastructure** with Application Load Balancer, Launch Templates, and CloudWatch-driven scaling policies achieving high availability across 2 AZs

- **Enforced security best practices** including private subnet isolation, IMDSv2 enforcement, security group chaining, encrypted EBS volumes, least-privilege IAM, and VPC Flow Logs

- **Built CI/CD pipeline** for Terraform with GitHub Actions featuring automated validation, planning, security scanning (tfsec/checkov), and auto-deployment with OIDC-based keyless AWS authentication

- **Configured remote state management** with encrypted S3 backend, DynamoDB state locking, and version-controlled infrastructure supporting multi-environment (dev/prod) deployments

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

> Built with ☁️ by a cloud engineering student passionate about infrastructure automation and cybersecurity.
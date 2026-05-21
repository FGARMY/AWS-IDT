################################################################################
# IAM Module
# Creates: EC2 IAM Role, Instance Profile, Least-Privilege Policies
################################################################################

# ------------------------------------------------------------------------------
# EC2 IAM Role (Assume Role for EC2 Service)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-role"
  }
}

# ------------------------------------------------------------------------------
# Instance Profile
# ------------------------------------------------------------------------------
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-profile"
  }
}

# ------------------------------------------------------------------------------
# CloudWatch Metrics & Logs Policy (Least Privilege)
# Allows EC2 instances to push custom metrics and logs
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy" "cloudwatch" {
  name = "${var.project_name}-${var.environment}-cloudwatch-policy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchMetrics"
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = "${var.project_name}/${var.environment}"
          }
        }
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/${var.project_name}/${var.environment}/*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# SSM Session Manager Policy (Secure Shell Alternative — No SSH Keys)
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.enable_ssm ? 1 : 0

  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ------------------------------------------------------------------------------
# ECR Read-Only Policy (Pull Container Images)
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy" "ecr_readonly" {
  count = var.enable_ecr_access ? 1 : 0

  name = "${var.project_name}-${var.environment}-ecr-readonly"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRReadOnly"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

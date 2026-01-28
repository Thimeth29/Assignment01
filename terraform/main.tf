################################
# PROVIDER
################################
provider "aws" {
  region = "us-east-1"
}

################################
# VPC
################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "assignment-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = false
}

################################
# EXISTING RESOURCES (DATA)
################################
data "aws_ecr_repository" "app_repo" {
  name = "node-fargate-app"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

################################
# ECS CLUSTER
################################
resource "aws_ecs_cluster" "main" {
  name = "fargate-cluster"
}

################################
# IAM TASK ROLE (FOR S3 UPLOAD)
################################
resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRoleS3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

################################
# S3 BUCKET
################################
resource "aws_s3_bucket" "upload_bucket" {
  bucket        = "thimeth-file-upload-bucket"
  force_destroy = true
}

################################
# S3 POLICY FOR TASK ROLE
################################
resource "aws_iam_policy" "s3_upload_policy" {
  name = "ecs-s3-upload-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.upload_bucket.arn,
        "${aws_s3_bucket.upload_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_s3_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_upload_policy.arn
}

################################
# EXECUTION ROLE POLICY ATTACH
################################
resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = data.aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

################################
# SECURITY GROUP (PORT 8080)
################################
resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################
# ECS TASK DEFINITION (PORT 8080)
################################
resource "aws_ecs_task_definition" "node_task" {
  family                   = "node-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "node-app"
      image     = "${data.aws_ecr_repository.app_repo.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}

################################
# ECS SERVICE
################################
resource "aws_ecs_service" "node_service" {
  name            = "node-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.node_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_exec_policy,
    aws_iam_role_policy_attachment.task_s3_attach
  ]
}

################################
# OUTPUT
################################
output "ecr_repository_url" {
  value = data.aws_ecr_repository.app_repo.repository_url
}

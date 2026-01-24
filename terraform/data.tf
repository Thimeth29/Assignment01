data "aws_ecr_repository" "app_repo" {
  name = "node-fargate-app"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}


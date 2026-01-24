output "ecr_repository_url" {
  value = data.aws_ecr_repository.app_repo.repository_url
}

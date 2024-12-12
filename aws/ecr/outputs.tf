output "private_repositories" {
  value = var.private_registry != null ? (
    {
      for k, v in var.private_registry.repositories :
      k => {
        arn            = aws_ecr_repository.private_repositories[k].arn
        registry_id    = aws_ecr_repository.private_repositories[k].registry_id
        repository_url = aws_ecr_repository.private_repositories[k].repository_url
      }
    }
  ) : {}
}

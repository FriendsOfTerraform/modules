output "private_repositories" {
  description = <<EOT
    Map of all private repositories

    @type map(object({
      /// The ARN of the repository.
      /// @since 1.0.0
      arn            = string

      /// The account ID where the repository is created
      /// @since 1.0.0
      registry_id    = string

      /// The URL of the repository. In the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`
      /// @since 1.0.0
      repository_url = string
    }))
    @since 1.0.0
  EOT
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

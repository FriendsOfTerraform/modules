resource "aws_ecr_repository_policy" "private_repository_policies" {
  for_each = var.private_registry != null ? { for k, v in var.private_registry.repositories : k => v if v.permissions != null } : {}

  repository = aws_ecr_repository.private_repositories[each.key].name
  policy     = each.value.permissions
}

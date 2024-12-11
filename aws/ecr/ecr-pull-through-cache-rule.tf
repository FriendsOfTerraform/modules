resource "aws_ecr_pull_through_cache_rule" "pull_through_cache_rules" {
  for_each = var.private_registry != null ? var.private_registry.pull_through_cache_rules : {}

  ecr_repository_prefix = each.key
  upstream_registry_url = each.value.upstream_registry_url
  credential_arn        = each.value.credential_arn
}

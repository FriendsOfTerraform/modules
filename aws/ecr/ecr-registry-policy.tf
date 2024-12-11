resource "aws_ecr_registry_policy" "private_registry_policy" {
  count = var.private_registry != null ? (var.private_registry.permissions != null ? 1 : 0) : 0

  policy = var.private_registry.permissions
}

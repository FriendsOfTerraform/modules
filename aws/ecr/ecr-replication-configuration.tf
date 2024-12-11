resource "aws_ecr_replication_configuration" "ecr_replication_rules" {
  count = var.private_registry != null ? (length(var.private_registry.replication_rules) != 0 ? 1 : 0) : 0

  replication_configuration {
    dynamic "rule" {
      for_each = var.private_registry.replication_rules

      content {
        dynamic "destination" {
          for_each = rule.value.destinations

          content {
            region      = length(split("/", destination.value)) > 1 ? split("/", destination.value)[1] : destination.value
            registry_id = length(split("/", destination.value)) > 1 ? split("/", destination.value)[0] : data.aws_caller_identity.current.account_id
          }
        }

        dynamic "repository_filter" {
          for_each = rule.value.filters

          content {
            filter      = repository_filter.value
            filter_type = "PREFIX_MATCH"
          }
        }
      }
    }
  }
}

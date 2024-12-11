locals {
  scanning_rules = var.private_registry != null ? (
    var.private_registry.scanning_configuration != null ? (
      merge(
        var.private_registry.scanning_configuration.scan_on_push != null ? (
          {
            SCAN_ON_PUSH = { filters = var.private_registry.scanning_configuration.scan_on_push.filters }
          }
        ) : {},
        var.private_registry.scanning_configuration.continuous_scanning != null ? (
          {
            CONTINUOUS_SCAN = { filters = var.private_registry.scanning_configuration.continuous_scanning.filters }
          }
        ) : {}
      )
    ) : {}
  ) : {}
}

resource "aws_ecr_registry_scanning_configuration" "scanning_configuration" {
  count = var.private_registry != null ? (var.private_registry.scanning_configuration != null ? 1 : 0) : 0

  scan_type = var.private_registry.scanning_configuration.scan_type

  dynamic "rule" {
    for_each = local.scanning_rules

    content {
      scan_frequency = rule.key

      dynamic "repository_filter" {
        for_each = rule.value.filters

        content {
          filter      = repository_filter.value
          filter_type = "WILDCARD"
        }
      }
    }
  }
}

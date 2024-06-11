# Query the default namespace for its ARN if it is specified
data "aws_service_discovery_http_namespace" "namespace_query" {
  count = var.default_service_connect_namespace != null ? 1 : 0

  name = var.default_service_connect_namespace
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.name

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.default_service_connect_namespace != null ? [1] : []

    content {
      namespace = data.aws_service_discovery_http_namespace.namespace_query.arn
    }
  }

  setting {
    name = "containerInsights"
    value = var.monitoring != null ? (
      var.monitoring.enable_container_insights ? "enabled" : "disabled"
    ) : "disabled"
  }

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}

locals {
  event_targets = flatten([
    for rule_name, rule_value in var.rules : [
      for target_name, target_value in rule_value.targets :
      {
        rule_name              = rule_name
        target_name            = target_name
        arn                    = target_value.arn
        iam_role_arn           = target_value.iam_role_arn
        configure_target_input = target_value.configure_target_input
        ecs_target_config      = target_value.ecs_target_config
        http_target_config     = target_value.http_target_config
        redshift_target_config = target_value.redshift_target_config
        retry_policy           = target_value.retry_policy
      }
    ]
  ])
}

resource "aws_cloudwatch_event_target" "event_targets" {
  for_each = tomap({ for target in local.event_targets : "${target.rule_name}-${target.target_name}" => target })

  arn            = each.value.arn
  rule           = aws_cloudwatch_event_rule.event_rules[each.value.rule_name].name
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name
  role_arn       = each.value.iam_role_arn
  input          = each.value.configure_target_input != null ? each.value.configure_target_input.constant : null

  dynamic "ecs_target" {
    for_each = each.value.ecs_target_config != null ? [1] : []

    content {
      task_definition_arn     = each.value.ecs_target_config.task_definition_arn
      enable_ecs_managed_tags = each.value.ecs_target_config.enable_ecs_managed_tags
      enable_execute_command  = each.value.ecs_target_config.enable_execute_command
      launch_type             = each.value.ecs_target_config.launch_type
      platform_version        = each.value.ecs_target_config.platform_version
      propagate_tags          = each.value.ecs_target_config.propagate_tags_from_task_definition ? "TASK_DEFINITION" : null
      task_count              = each.value.ecs_target_config.count

      tags = merge(
        local.common_tags,
        each.value.ecs_target_config.additional_tags,
        var.additional_tags_all
      )

      network_configuration {
        subnets          = each.value.ecs_target_config.network_config.subnet_ids
        security_groups  = each.value.ecs_target_config.network_config.security_group_ids
        assign_public_ip = each.value.ecs_target_config.network_config.auto_assign_public_ip
      }

      dynamic "capacity_provider_strategy" {
        for_each = each.value.ecs_target_config.capacity_provider_strategy

        content {
          capacity_provider = capacity_provider_strategy.key
          weight            = capacity_provider_strategy.value.weight
          base              = capacity_provider_strategy.value.base
        }
      }
    }
  }

  dynamic "http_target" {
    for_each = each.value.http_target_config != null ? [1] : []

    content {
      header_parameters       = each.value.http_target_config.header_parameters
      query_string_parameters = each.value.http_target_config.query_string_parameters
    }
  }

  dynamic "redshift_target" {
    for_each = each.value.redshift_target_config != null ? [1] : []

    content {
      database            = each.value.redshift_target_config.database_name
      db_user             = each.value.redshift_target_config.database_user
      secrets_manager_arn = each.value.redshift_target_config.secret_manager_arn
      sql                 = each.value.redshift_target_config.sql_statement
      statement_name      = "${each.value.rule_name}-${each.value.target_name}"
      with_event          = each.value.redshift_target_config.with_event
    }
  }

  dynamic "input_transformer" {
    for_each = each.value.configure_target_input != null ? (each.value.configure_target_input.input_transformer != null ? [1] : []) : []

    content {
      input_paths    = each.value.configure_target_input.input_transformer.input_paths
      input_template = each.value.configure_target_input.input_transformer.template
    }
  }

  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [1] : []

    content {
      maximum_event_age_in_seconds = each.value.retry_policy.maximum_age_of_event
      maximum_retry_attempts       = each.value.retry_policy.retry_attempts
    }
  }

  dynamic "dead_letter_config" {
    for_each = each.value.retry_policy != null ? (each.value.retry_policy.dead_letter_queue != null ? [1] : []) : []

    content {
      arn = each.value.retry_policy.dead_letter_queue
    }
  }
}

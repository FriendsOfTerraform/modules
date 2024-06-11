resource "aws_autoscaling_group" "ecs_autoscaling_groups" {
  for_each = var.ec2_capacity_providers

  desired_capacity    = each.value.desired_instances
  max_size            = each.value.max_desired_instances != null ? each.value.max_desired_instances : each.value.desired_instances
  min_size            = each.value.min_desired_instances != null ? each.value.min_desired_instances : each.value.desired_instances
  name                = "${aws_ecs_cluster.ecs_cluster.name}-${each.key}-asg" # The name is a combination of <cluster_name>-<capacity_provider_name>-asg
  vpc_zone_identifier = each.value.subnet_ids

  # Use launch template if spot instances are not requested
  dynamic "launch_template" {
    for_each = each.value.spot_instance_allocation_strategy != null ? [] : [1]

    content {
      id      = aws_launch_template.launch_templates[each.key].id
      version = "$Latest"
    }
  }

  # Use mixed instances policy if spot instances are requested
  dynamic "mixed_instances_policy" {
    for_each = each.value.spot_instance_allocation_strategy != null ? [1] : []

    content {
      instances_distribution {
        spot_allocation_strategy = each.value.spot_instance_allocation_strategy
      }

      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.launch_templates[each.key].id
          version            = "$Latest"
        }
      }
    }
  }

  dynamic "tag" {
    for_each = merge(
      {
        Name             = "ECS Instance - ${aws_ecs_cluster.ecs_cluster.name}"
        AmazonECSManaged = "true"
      },
      local.common_tags,
      each.value.additional_tags,
      var.additional_tags_all
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

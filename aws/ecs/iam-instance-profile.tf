# Default instance profile, creates only if at least one capacity provider provides no instance_iam_role
resource "aws_iam_instance_profile" "default_ecs_role_profile" {
  count = length([
    for provider in var.ec2_capacity_providers :
    provider.instance_iam_role if provider.instance_iam_role == null
  ]) > 0 ? 1 : 0

  name = aws_iam_role.default_ecs_role[0].name
  role = aws_iam_role.default_ecs_role[0].name

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

resource "aws_iam_instance_profile" "instance_profiles" {
  for_each = {
    for name, provider in var.ec2_capacity_providers :
    name => provider.instance_iam_role if provider.instance_iam_role != null
  }

  name = "${var.name}-${each.key}-${each.value}"
  role = each.value

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

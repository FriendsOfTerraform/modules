# Assume role policy for the default_ecs_role
data "aws_iam_policy_document" "default_ecs_role_assume_role_policy" {
  count = length([
    for provider in var.ec2_capacity_providers :
    provider.instance_iam_role if provider.instance_iam_role == null
  ]) > 0 ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Default IAM role for the EC2 capacity providers
resource "aws_iam_role" "default_ecs_role" {
  count = length([
    for provider in var.ec2_capacity_providers :
    provider.instance_iam_role if provider.instance_iam_role == null
  ]) > 0 ? 1 : 0

  name               = "${var.name}-default-ecs-role"
  assume_role_policy = data.aws_iam_policy_document.default_ecs_role_assume_role_policy[0].json

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

resource "aws_iam_role_policy_attachment" "default_ecs_role_policy_attachment" {
  count = length([
    for provider in var.ec2_capacity_providers :
    provider.instance_iam_role if provider.instance_iam_role == null
  ]) > 0 ? 1 : 0

  role       = aws_iam_role.default_ecs_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

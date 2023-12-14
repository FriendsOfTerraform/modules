resource "aws_iam_instance_profile" "iam_instance_profile" {
  count = var.iam_role_name != null ? 1 : 0

  name = "${var.name}-${var.iam_role_name}"
  role = var.iam_role_name
}

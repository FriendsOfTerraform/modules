resource "aws_security_group" "security_group" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    { Name = var.name },
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}

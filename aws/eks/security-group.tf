data "aws_subnet" "control_plane_subnet" {
  id = var.vpc_config.subnet_ids[0]
}

# This is only needed for private only endpoint. To control access from particular CIDRs
resource "aws_security_group" "control_plane_security_group" {
  name                   = "${var.name}-control-plane-security-group"
  description            = "Allow API access to the ${var.name} cluster"
  vpc_id                 = data.aws_subnet.control_plane_subnet.vpc_id
  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = var.apiserver_allowed_cidrs
  security_group_id = aws_security_group.control_plane_security_group.id
}
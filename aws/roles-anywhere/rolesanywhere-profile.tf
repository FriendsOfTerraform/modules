resource "aws_rolesanywhere_profile" "profiles" {
  for_each = var.profiles
  depends_on = [
    aws_iam_role.iam_roles
  ]

  name = each.key

  role_arns = [
    for role_name, role_value in each.value.roles : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${each.key}-${role_value.trust_anchor_name}-${role_name}"
  ]

  duration_seconds            = each.value.session_duration_seconds
  enabled                     = true
  managed_policy_arns         = each.value.session_policy != null ? each.value.session_policy.managed_policy_arns : null
  require_instance_properties = each.value.require_instance_properties
  session_policy              = each.value.session_policy != null ? each.value.session_policy.inline_policy : null

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )
}

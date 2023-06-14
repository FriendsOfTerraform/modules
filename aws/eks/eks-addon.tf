resource "aws_eks_addon" "addons" {
  for_each = var.add_ons

  addon_name                  = each.key
  cluster_name                = aws_eks_cluster.eks_cluster.id
  addon_version               = each.value.version
  configuration_values        = each.value.configuration
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  preserve                    = each.value.preserve

  service_account_role_arn = each.value.iam_role_arn != null ? each.value.iam_role_arn : (
    contains(keys(local.addons_service_account_to_iam_role_mappings), each.key) ? (
      aws_iam_role.service_account_roles[keys(local.addons_service_account_to_iam_role_mappings[each.key])[0]].arn
    ) : null
  )

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    each.value.additional_tags
  )
}
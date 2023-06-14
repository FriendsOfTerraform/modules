resource "aws_eks_node_group" "eks_node_groups" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.eks_cluster.id
  node_group_name = each.key
  node_role_arn   = aws_iam_role.eks_node_instance_role.arn

  scaling_config {
    desired_size = each.value.desired_instances
    min_size     = each.value.min_instances != null ? each.value.min_instances : each.value.desired_instances
    max_size     = each.value.max_instances != null ? each.value.max_instances : each.value.desired_instances
  }

  subnet_ids           = each.value.subnet_ids
  ami_type             = each.value.ami_type
  capacity_type        = each.value.capacity_type
  disk_size            = each.value.disk_size
  force_update_version = each.value.ignores_pod_disruption_budget
  instance_types       = [each.value.instance_type]
  labels               = each.value.kubernetes_labels
  release_version      = each.value.ami_release_version

  tags = merge(
    local.common_tags,
    each.value.additional_tags,
    var.additional_tags_all
  )

  dynamic "taint" {
    for_each = each.value.kubernetes_taints != null ? toset([
      for k, v in each.value.kubernetes_taints : {
        key    = k
        value  = split(":", v)[0]
        effect = split(":", v)[1]
      }
    ]) : []

    content {
      key    = taint.key.key
      value  = taint.key.value
      effect = taint.key.effect
    }
  }

  dynamic "update_config" {
    for_each = each.value.max_unavailable_instances_during_update != null ? [1] : []

    content {
      max_unavailable            = endswith(each.value.max_unavailable_instances_during_update, "%") ? null : tonumber(each.value.max_unavailable_instances_during_update)
      max_unavailable_percentage = endswith(each.value.max_unavailable_instances_during_update, "%") ? tonumber(trimsuffix(each.value.max_unavailable_instances_during_update, "%")) : null
    }
  }

  version = each.value.kubernetes_version
}
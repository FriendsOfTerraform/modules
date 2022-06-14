resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = local.additional_node_pools

  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetes_cluster.id
  name                  = each.key
  vm_size               = each.value.vm_size

  enable_auto_scaling = each.value.min_instances != null ? (
    each.value.max_instances != null ? true : false
  ) : false

  max_pods             = each.value.max_pods_per_node
  orchestrator_version = each.value.kubernetes_version
  os_disk_size_gb      = each.value.disk_size

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    each.value.additional_tags
  )

  vnet_subnet_id = each.value.vnet_subnet_id

  max_count  = each.value.max_instances
  min_count  = each.value.min_instances
  node_count = each.value.desired_instances
  zones      = each.value.zones
}

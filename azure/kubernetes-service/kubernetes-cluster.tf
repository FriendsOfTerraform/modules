locals {
  default_node_pool = { keys(var.node_pools)[0] = var.node_pools[keys(var.node_pools)[0]] }

  additional_node_pools = length(var.node_pools) > 1 ? {
    for k in slice(keys(var.node_pools), 1, length(var.node_pools)) : k => var.node_pools[k]
  } : {}
}

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.name
  location            = local.location
  resource_group_name = data.azurerm_resource_group.current.name

  dynamic "default_node_pool" {
    for_each = local.default_node_pool

    content {
      name    = default_node_pool.key
      vm_size = default_node_pool.value.vm_size

      # enable auto scaling if both min_instances and max_instances are specified
      enable_auto_scaling = default_node_pool.value.min_instances != null ? (
        default_node_pool.value.max_instances != null ? true : false
      ) : false

      max_pods             = default_node_pool.value.max_pods_per_node
      orchestrator_version = default_node_pool.value.kubernetes_version
      os_disk_size_gb      = default_node_pool.value.disk_size

      tags = merge(
        local.common_tags,
        var.additional_tags_all,
        default_node_pool.value.additional_tags
      )

      vnet_subnet_id = default_node_pool.value.vnet_subnet_id
      max_count      = default_node_pool.value.max_instances
      min_count      = default_node_pool.value.min_instances
      node_count     = default_node_pool.value.desired_instances
      zones          = default_node_pool.value.zones
    }
  }

  dns_prefix                      = var.enable_private_cluster ? null : var.name
  dns_prefix_private_cluster      = var.enable_private_cluster ? var.name : null
  api_server_authorized_ip_ranges = var.enable_private_cluster ? null : var.apiserver_authorized_ip_ranges

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.cluster_admin_active_directory_group_ids
    azure_rbac_enabled     = true
  }

  azure_policy_enabled = local.add_ons.azure_policy_enabled

  identity {
    type         = length(var.user_assigned_managed_identity_ids) > 0 ? "UserAssigned" : "SystemAssigned"
    identity_ids = length(var.user_assigned_managed_identity_ids) > 0 ? var.user_assigned_managed_identity_ids : null
  }

  dynamic "key_vault_secrets_provider" {
    for_each = local.add_ons.azure_key_vault_secrets_provider_enabled ? [1] : []

    content {
      secret_rotation_enabled  = true
      secret_rotation_interval = var.add_ons.azure_key_vault_secrets_provider.secret_rotation_interval_minutes != null ? "${var.add_ons.azure_key_vault_secrets_provider.secret_rotation_interval_minutes}m" : null
    }
  }

  # This is required for some reason, but we are using managed identity so marking all values null
  kubelet_identity {
    client_id                 = null
    object_id                 = null
    user_assigned_identity_id = null
  }

  kubernetes_version     = var.kubernetes_version
  local_account_disabled = true

  network_profile {
    # defaults to Azure CNI if plugin isn't specified
    network_plugin = var.networking_config != null ? (
      var.networking_config.plugin != null ? var.networking_config.plugin : "azure"
    ) : "azure"

    # use calico if plugin is kubenet, otherwise defaults to azure
    network_policy = var.networking_config != null ? (
      var.networking_config.plugin != null ? (
        var.networking_config.plugin == "kubenet" ? "calico" : "azure"
      ) : "azure"
    ) : "azure"

    dns_service_ip     = var.networking_config != null ? var.networking_config.kubernetes_dns_service_ip_address : null
    docker_bridge_cidr = var.networking_config != null ? var.networking_config.docker_bridge_address : null
    outbound_type      = "loadBalancer"

    # ignore this setting if plugin is not kubenet
    pod_cidr = var.networking_config != null ? (
      var.networking_config.plugin != null ? (
        var.networking_config.plugin == "kubenet" ? var.networking_config.kubernetes_pod_address_range : null
      ) : null
    ) : null

    service_cidr = var.networking_config != null ? var.networking_config.kubernetes_service_address_range : null

    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.outbound_lb_public_ip.id]
    }
  }

  node_resource_group = null  # let's see what the default is
  oidc_issuer_enabled = false # disabling at the time being because it is a preview feat

  dynamic "oms_agent" {
    for_each = local.add_ons.monitoring_enabled ? [1] : []

    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace[0].id
    }
  }

  private_cluster_enabled       = var.enable_private_cluster
  private_dns_zone_id           = var.enable_private_cluster ? "System" : null
  public_network_access_enabled = !var.enable_private_cluster

  tags = merge(
    local.common_tags,
    var.additional_tags_all,
    var.additional_tags
  )
}

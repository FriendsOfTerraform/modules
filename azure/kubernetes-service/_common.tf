data "azurerm_resource_group" "current" {
  name = var.azure.resource_group_name
}

locals {
  add_ons = {
    azure_key_vault_secrets_provider_enabled = var.add_ons != null ? (
      var.add_ons.azure_key_vault_secrets_provider != null ? var.add_ons.azure_key_vault_secrets_provider.enabled : false
    ) : false

    azure_policy_enabled = var.add_ons != null ? (
      var.add_ons.azure_policy != null ? var.add_ons.azure_policy.enabled : false
    ) : false

    monitoring_enabled = var.add_ons != null ? (
      var.add_ons.monitoring != null ? var.add_ons.monitoring.enabled : false
    ) : false
  }

  common_tags = {
    managed-by = "Terraform"
  }

  location = var.azure.location != null ? var.azure.location : data.azurerm_resource_group.current.location
}

data "azurerm_resource_group" "current" {
  name = var.azure.resource_group_name
}

locals {
  common_tags = {
    managed-by = "Terraform"
  }

  location = var.azure.location != null ? var.azure.location : data.azurerm_resource_group.current.location
}

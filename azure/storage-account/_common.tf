data "azurerm_resource_group" "current" {
  name = var.azure.resource_group_name
}

locals {
  common_tags = {
    managed-by = "Terraform"
  }

  # true if the storage account type supports blob storage
  isBlockStorageSupported = local.isGeneralStorage ? true : (local.isBlockBlobStorage ? true : false)

  # true if the storage account type supports file share
  isFileShareSupported = local.isGeneralStorage ? true : (local.isFileStorage ? true : false)

  isBlockBlobStorage = var.storage_account_type == "BlockBlobStorage"
  isFileStorage      = var.storage_account_type == "FileStorage"
  isGeneralStorage   = var.storage_account_type == "StorageV2"

  # only BlockBlobStorage and FileStorage support premium
  isPremiumAccessTier = local.isBlockBlobStorage ? true : (local.isFileStorage ? true : false)

  location = var.azure.location != null ? var.azure.location : data.azurerm_resource_group.current.location
}

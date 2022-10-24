locals {
  is_azure = lower(var.secret_engine) == "azure"
}

resource "vault_azure_secret_backend" "azure_secret_backend" {
  count = local.is_azure ? 1 : 0

  path                      = var.mount_path
  description               = var.description

  use_microsoft_graph_api = true
  environment             = "AzurePublicCloud"
  subscription_id         = var.azure_config.subscription_id
  tenant_id               = var.azure_config.tenant_id
  client_id               = var.azure_config.client_id
  client_secret           = var.azure_config.client_secret
}
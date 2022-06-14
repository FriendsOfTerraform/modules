resource "azurerm_role_assignment" "acr_integration" {
  for_each = toset(var.azure_container_registry_attachments)

  principal_id                     = azurerm_kubernetes_cluster.kubernetes_cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = each.key
  skip_service_principal_aad_check = true
}

resource "vault_azure_secret_backend_role" "azure_secret_backend_roles" {
  for_each = local.is_azure ? var.azure_secret_backend_roles : {}

  backend = vault_azure_secret_backend.azure_secret_backend[0].path
  role    = each.key

  dynamic "azure_roles" {
    for_each = each.value.azure_roles != null ? (
      toset(each.value.azure_roles)
    ) : toset([])

    content {
      role_id   = azure_roles.value.role_id
      role_name = azure_roles.value.role_name
      scope     = azure_roles.value.scope
    }
  }

  dynamic "azure_groups" {
    for_each = each.value.azure_groups != null ? (
      toset(each.value.azure_groups)
    ) : toset([])

    content {
      group_name = azure_groups.value.group_name
      object_id  = azure_groups.value.object_id
    }
  }

  application_object_id = each.value.application_object_id
  ttl                   = each.value.ttl_seconds
  max_ttl               = each.value.max_ttl_seconds
}
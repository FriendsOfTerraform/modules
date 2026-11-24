output "pipeline" {
  value = {
    name     = azuredevops_build_definition.this.name
    id       = azuredevops_build_definition.this.id
    revision = azuredevops_build_definition.this.revision
    status   = azuredevops_build_definition.this.queue_status
  }
}

resource "azuredevops_git_repository" "this" {
  project_id           = data.azuredevops_project.this.id
  name                 = var.name
  parent_repository_id = var.fork != null ? var.fork.parent_repository_id : null
  disabled             = !var.enabled
  default_branch       = "refs/heads/${trimprefix(var.default_branch, "refs/heads/")}"

  initialization {
    init_type = (
      var.import != null ? "Import" :
      var.fork != null ? "Fork" :
      "Clean"
    )

    source_type           = var.import != null ? "Git" : null
    source_url            = var.import != null ? var.import.source_repo_url : null
    service_connection_id = var.import != null ? var.import.service_connection_id : null
    username              = var.import != null ? var.import.username : null
    password              = var.import != null ? var.import.password : null
  }
}

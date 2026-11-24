output "repository" {
  value = {
    name           = azuredevops_git_repository.this.name
    default_branch = azuredevops_git_repository.this.default_branch
    id             = azuredevops_git_repository.this.id
    is_fork        = azuredevops_git_repository.this.is_fork
    remote_url     = azuredevops_git_repository.this.remote_url
    ssh_url        = azuredevops_git_repository.this.ssh_url
    url            = azuredevops_git_repository.this.url
    web_url        = azuredevops_git_repository.this.web_url
  }
}

output "branches" {
  description = "Created branch resources keyed by their branches input keys; excludes the default branch and wildcard policy entries."
  value = {
    for name, branch in azuredevops_git_repository_branch.this : name => {
      id             = branch.id
      last_commit_id = branch.last_commit_id
    }
  }
}